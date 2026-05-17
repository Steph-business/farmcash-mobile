import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/snackbars.dart';

// ─── Couleurs accent ─────────────────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kOrangeSoft = Color(0xFFFFF3E0);
const Color _kOrange = Color(0xFFE65100);
const Color _kBlueSoft = Color(0xFFE3F2FD);
const Color _kBlue = Color(0xFF1565C0);

enum _ReplyRole { membre, coop, indep }

enum _ReplyMode { now, later }

/// Une réponse fournisseur à une sollicitation. **Membres en FULL** (règle
/// 3b du chantier), **externes anonymisés** (coops + indép).
class _MockReply {
  final String avatar;
  final String nom; // FULL si membre, abrégé sinon
  final _ReplyRole role;
  final int qtyKg;
  final _ReplyMode mode;
  final String? modeLabel; // "Dans 5j", "Dans 12j" pour later
  final bool deja; // accepté

  const _MockReply({
    required this.avatar,
    required this.nom,
    required this.role,
    required this.qtyKg,
    required this.mode,
    this.modeLabel,
    required this.deja,
  });
}

const List<_MockReply> _kMockReplies = [
  // Membres — nom FULL
  _MockReply(
    avatar:
        'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=120&h=120&fit=crop&auto=format',
    nom: 'Yao Konan',
    role: _ReplyRole.membre,
    qtyKg: 500,
    mode: _ReplyMode.now,
    deja: false,
  ),
  // Coop externe — anonymisée
  _MockReply(
    avatar:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=120&h=120&fit=crop&auto=format',
    nom: 'Coop CEMAC',
    role: _ReplyRole.coop,
    qtyKg: 400,
    mode: _ReplyMode.later,
    modeLabel: 'Dans 5j',
    deja: false,
  ),
  // Membre — nom FULL
  _MockReply(
    avatar:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=120&h=120&fit=crop&auto=format',
    nom: "Aya N'Guessan",
    role: _ReplyRole.membre,
    qtyKg: 300,
    mode: _ReplyMode.later,
    modeLabel: 'Dans 12j',
    deja: false,
  ),
  // Membre — déjà accepté
  _MockReply(
    avatar:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120&h=120&fit=crop&auto=format',
    nom: 'Kouadio Bertin',
    role: _ReplyRole.membre,
    qtyKg: 250,
    mode: _ReplyMode.now,
    deja: true,
  ),
  // Coop externe — anonymisée
  _MockReply(
    avatar:
        'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=120&h=120&fit=crop&auto=format',
    nom: 'Coop Yamoussoukro',
    role: _ReplyRole.coop,
    qtyKg: 200,
    mode: _ReplyMode.now,
    deja: true,
  ),
  // Indépendante — anonymisée
  _MockReply(
    avatar:
        'https://images.unsplash.com/photo-1493612276216-ee3925520721?w=120&h=120&fit=crop&auto=format',
    nom: 'Diabaté Awa',
    role: _ReplyRole.indep,
    qtyKg: 180,
    mode: _ReplyMode.later,
    modeLabel: 'Dans 8j',
    deja: true,
  ),
  // Membre — déjà accepté
  _MockReply(
    avatar:
        'https://images.unsplash.com/photo-1601412436009-d964bd02edbc?w=120&h=120&fit=crop&auto=format',
    nom: 'Traoré Salif',
    role: _ReplyRole.membre,
    qtyKg: 120,
    mode: _ReplyMode.now,
    deja: true,
  ),
  // Membre — déjà accepté
  _MockReply(
    avatar:
        'https://images.unsplash.com/photo-1573497019418-b400bb3ab074?w=120&h=120&fit=crop&auto=format',
    nom: 'Adjoua Brigitte',
    role: _ReplyRole.membre,
    qtyKg: 60,
    mode: _ReplyMode.now,
    deja: true,
  ),
];

/// Fetch optionnel — `getSollicitation` renvoie une Map riche du back.
/// Mock-fallback strict pour la maquette (le payload back ne contient pas
/// l'agrégat exact en V1).
final _sollicitationSuiviProvider = FutureProvider.autoDispose
    .family<List<_MockReply>, String>((ref, id) async {
  try {
    await ref.watch(cooperativesServiceProvider).getSollicitation(id);
    // En V1 on retombe sur les mocks pour préserver le pixel-perfect.
    return _kMockReplies;
  } catch (_) {
    return _kMockReplies;
  }
});

/// Suivi d'une sollicitation envoyée par la coop : progression du
/// remplissage, liste des réponses, actions (relancer / confirmer).
class SollicitationSuiviPage extends ConsumerWidget {
  const SollicitationSuiviPage({required this.sollicitationId, super.key});

  final String sollicitationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_sollicitationSuiviProvider(sollicitationId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                error: (_, _) => const _Body(replies: _kMockReplies),
                data: (replies) => _Body(replies: replies),
              ),
            ),
            const _Sticky(),
          ],
        ),
      ),
    );
  }
}

// ─── Header (avec menu ⋮) ────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  void _menuStub(BuildContext context) {
    Snackbars.showInfo(context, 'Menu — à venir');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space16,
        AppDimens.space8,
        AppDimens.space16,
        AppDimens.space12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.text,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Suivi sollicitation',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          InkWell(
            onTap: () => _menuStub(context),
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.more_vert,
                size: 22,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Body ────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({required this.replies});

  final List<_MockReply> replies;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        0,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      children: [
        _SectionTitle(title: 'Récap'),
        AppDimens.vGap12,
        const _RecapCard(),
        AppDimens.vGap24,
        _SectionTitle(title: 'Progression du remplissage'),
        AppDimens.vGap12,
        const _ProgressCard(),
        AppDimens.vGap24,
        _SectionTitle(title: 'Réponses reçues (${replies.length})'),
        AppDimens.vGap12,
        for (final r in replies) ...[
          _ReplyTile(reply: r),
          AppDimens.vGap8,
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.titleSmall.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
    );
  }
}

// ─── Récap card (sous-titre anonymisé) ───────────────────────────────────

class _RecapCard extends StatelessWidget {
  const _RecapCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manioc · 3 000 kg manquants',
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            // Acheteur anonymisé : "Industries A." (anti-contournement)
            'Pour Industries A. · Livraison 25 juin',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            child: Text(
              'Sollicitation envoyée à 47 farmers + 12 coops',
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Progress card (barre + 2 mini-stats) ────────────────────────────────

class _ProgressCard extends StatelessWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '2 010 / 3 000 kg engagés',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '67%',
                style: AppTextStyles.titleLarge.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Barre de progression custom (16px height)
          Container(
            width: double.infinity,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.67,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: _MiniStat(
                  label: 'Stock immédiat',
                  value: '1 200 kg',
                  ok: true,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  label: 'Engagé à venir',
                  value: '810 kg · max 18 juin',
                  ok: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.ok,
  });

  final String label;
  final String value;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: ok ? AppColors.primary : _kOrange,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reply tile ──────────────────────────────────────────────────────────

class _ReplyTile extends StatelessWidget {
  const _ReplyTile({required this.reply});

  final _MockReply reply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          ClipOval(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.hardEdge,
              child: CachedNetworkImage(
                imageUrl: reply.avatar,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    Container(color: AppColors.surfaceSoft),
                errorWidget: (_, _, _) =>
                    Container(color: AppColors.surfaceSoft),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        reply.nom,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _RoleTag(role: reply.role),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${reply.qtyKg} kg',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _ModeChip(
                      mode: reply.mode,
                      label: reply.mode == _ReplyMode.now
                          ? 'Maintenant'
                          : (reply.modeLabel ?? 'Dans Xj'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          reply.deja
              ? const _DoneChip()
              : _AcceptBtn(onTap: () {
                  Snackbars.showSucces(context, 'Réponse acceptée');
                }),
        ],
      ),
    );
  }
}

class _RoleTag extends StatelessWidget {
  const _RoleTag({required this.role});

  final _ReplyRole role;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    BoxBorder? border;
    switch (role) {
      case _ReplyRole.membre:
        bg = _kPrimarySoft;
        fg = AppColors.primary;
        label = 'Membre';
        border = null;
        break;
      case _ReplyRole.coop:
        bg = _kBlueSoft;
        fg = _kBlue;
        label = 'Coop';
        border = null;
        break;
      case _ReplyRole.indep:
        bg = AppColors.surfaceSoft;
        fg = AppColors.textSecondary;
        label = 'Indépendant';
        border = Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        );
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: border,
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.mode, required this.label});

  final _ReplyMode mode;
  final String label;

  @override
  Widget build(BuildContext context) {
    final bg = mode == _ReplyMode.now ? _kPrimarySoft : _kOrangeSoft;
    final fg = mode == _ReplyMode.now ? AppColors.primary : _kOrange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

class _AcceptBtn extends StatelessWidget {
  const _AcceptBtn({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: AppColors.primary,
            width: AppDimens.borderThin,
          ),
        ),
        child: Text(
          'Accepter',
          style: AppTextStyles.button.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _DoneChip extends StatelessWidget {
  const _DoneChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Text(
        'Acceptée',
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ─── Sticky 2 boutons ────────────────────────────────────────────────────

class _Sticky extends StatelessWidget {
  const _Sticky();

  void _relancer(BuildContext context) {
    Snackbars.showInfo(context, 'Relance envoyée aux non-répondants');
  }

  void _confirmer(BuildContext context) {
    Snackbars.showInfo(context, 'Confirmer à 100% du remplissage requis');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 12),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _relancer(context),
              borderRadius: BorderRadius.circular(AppDimens.radiusCard),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                  border: Border.all(
                    color: AppColors.primary,
                    width: AppDimens.borderThin,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Relancer non-répondants',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: () => _confirmer(context),
              borderRadius: BorderRadius.circular(AppDimens.radiusCard),
              child: Opacity(
                opacity: 0.6,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusCard),
                    border: Border.all(
                      color: AppColors.primary,
                      width: AppDimens.borderThin,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Confirmer à l'acheteur (67%)",
                    style: AppTextStyles.button.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

