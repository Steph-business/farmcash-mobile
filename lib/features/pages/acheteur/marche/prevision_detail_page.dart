import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/prevision.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── Constantes ───────────────────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kWarn = Color(0xFFF9A825);
const Color _kBadgePrevisionOrange = Color(0xFFFB923C);

const String _kHeroPhotoFallback =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=800&h=450&fit=crop&auto=format';

// ─── Mock de fallback (fidèle à la maquette HTML) ─────────────────────

class _MockPrevision {
  const _MockPrevision({
    required this.nom,
    required this.qualite,
    required this.prixPrev,
    required this.qteTotalePrev,
    required this.qteReservee,
    required this.disponibleLe,
    required this.acompte10pct,
    required this.vendeurAnonymise,
  });

  final String nom;
  final String qualite;
  final int prixPrev;
  final int qteTotalePrev;
  final int qteReservee;
  final String disponibleLe;
  final int acompte10pct;
  final String vendeurAnonymise;
}

const _MockPrevision _kMockPrevision = _MockPrevision(
  nom: 'Maïs blanc',
  qualite: 'Standard',
  prixPrev: 350,
  qteTotalePrev: 1000,
  qteReservee: 600,
  disponibleLe: 'Disponible le 15 juin',
  acompte10pct: 17500,
  vendeurAnonymise: 'Yao K.',
);

// ─── Provider ─────────────────────────────────────────────────────────

final _previsionAcheteurDetailProvider = FutureProvider.autoDispose
    .family<Prevision?, String>((ref, id) async {
  try {
    final all = await ref.read(marketplaceServiceProvider).listPrevisions();
    return all.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('not found'),
    );
  } catch (_) {
    return null;
  }
});

/// Détail d'une prévision côté ACHETEUR — hero + badge orange, recap,
/// info acompte 10%, barre progression, vendeur anonymisé, 3 steps,
/// sticky qty + bouton réserver.
class PrevisionDetailAcheteurPage extends ConsumerStatefulWidget {
  const PrevisionDetailAcheteurPage({required this.previsionId, super.key});

  final String previsionId;

  @override
  ConsumerState<PrevisionDetailAcheteurPage> createState() =>
      _PrevisionDetailAcheteurPageState();
}

class _PrevisionDetailAcheteurPageState
    extends ConsumerState<PrevisionDetailAcheteurPage> {
  int _qte = 200;

  @override
  Widget build(BuildContext context) {
    final async =
        ref.watch(_previsionAcheteurDetailProvider(widget.previsionId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Column(
            children: [
              _Header(title: 'Chargement…'),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const _Header(title: 'Prévision'),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger la prévision.',
                    onRetry: () => ref.invalidate(
                      _previsionAcheteurDetailProvider(widget.previsionId),
                    ),
                  ),
                ),
              ),
            ],
          ),
          data: (p) => _buildContent(p),
        ),
      ),
    );
  }

  Widget _buildContent(Prevision? p) {
    // Fallback aux valeurs de la maquette si pas de backend.
    final nom = _kMockPrevision.nom;
    final qualite = _kMockPrevision.qualite;
    final prix = p?.prixCibleKg?.round() ?? _kMockPrevision.prixPrev;
    final qteTotale =
        p?.quantitePrevKg.round() ?? _kMockPrevision.qteTotalePrev;
    final qteReservee = _kMockPrevision.qteReservee;
    final progress = qteTotale > 0 ? qteReservee / qteTotale : 0.6;
    final dispoLe = p?.dateRecoltePrev != null
        ? 'Disponible le ${DateFormat('d MMM', 'fr_FR').format(p!.dateRecoltePrev!)}'
        : _kMockPrevision.disponibleLe;
    final acompteAffiche = (qteTotale * prix * 0.10).round();

    return Column(
      children: [
        _Header(title: 'Prévision · $nom'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              _HeroPrevision(
                photoUrl: _kHeroPhotoFallback,
                badgeText: 'Prévision · $dispoLe',
              ),
              _TitleCard(
                nom: nom,
                qualite: qualite,
                prixPrevu: prix,
                qteTotale: qteTotale,
              ),
              _InfoAcompteCard(acompte: acompteAffiche),
              _ProgressBar(
                qteReservee: qteReservee,
                qteTotale: qteTotale,
                progress: progress,
              ),
              _SectionVendeur(nom: _kMockPrevision.vendeurAnonymise),
              const _SectionCommentCaMarche(),
            ],
          ),
        ),
        _StickyBottom(
          qte: _qte,
          onMinus: () {
            if (_qte > 1) setState(() => _qte--);
          },
          onPlus: () => setState(() => _qte++),
          onReserver: () => context.push(
            RouteNames.acheteurReservationPaiementPathFor(widget.previsionId),
          ),
        ),
      ],
    );
  }
}

// ─── Header ────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      decoration: const BoxDecoration(color: AppColors.background),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
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
              title,
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero photo + badge orange "Prévision" ────────────────────────────

class _HeroPrevision extends StatelessWidget {
  const _HeroPrevision({required this.photoUrl, required this.badgeText});

  final String photoUrl;
  final String badgeText;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: CachedNetworkImage(
            imageUrl: photoUrl,
            fit: BoxFit.cover,
            placeholder: (_, _) => Container(color: AppColors.surfaceSoft),
            errorWidget: (_, _, _) => Container(color: AppColors.surfaceSoft),
          ),
        ),
        Positioned(
          top: 14,
          left: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _kBadgePrevisionOrange,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  badgeText,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Title card (nom, qualité, prix prévu, qty) ───────────────────────

class _TitleCard extends StatelessWidget {
  const _TitleCard({
    required this.nom,
    required this.qualite,
    required this.prixPrevu,
    required this.qteTotale,
  });

  final String nom;
  final String qualite;
  final int prixPrevu;
  final int qteTotale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  nom,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _kPrimarySoft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _kPrimarySoft),
                ),
                child: Text(
                  qualite,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${_nf.format(prixPrevu)} F/kg ',
                  style: AppTextStyles.displaySmall.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: -0.4,
                  ),
                ),
                TextSpan(
                  text: 'prévu',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${_nf.format(qteTotale)} kg prévus',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info card acompte 10% ────────────────────────────────────────────

class _InfoAcompteCard extends StatelessWidget {
  const _InfoAcompteCard({required this.acompte});

  final int acompte;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.info_outline,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.text,
                ),
                children: [
                  const TextSpan(text: 'Tu peux '),
                  TextSpan(
                    text: 'réserver dès maintenant',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const TextSpan(text: '. Tu paies juste '),
                  TextSpan(
                    text: '10% d\'acompte (${_nf.format(acompte)} F)',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const TextSpan(text: ', le reste à la livraison.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Progress bar ─────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.qteReservee,
    required this.qteTotale,
    required this.progress,
  });

  final int qteReservee;
  final int qteTotale;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$pct% réservé',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              Text(
                '$qteReservee / $qteTotale kg',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(color: AppColors.primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section vendeur anonymisé ────────────────────────────────────────

class _SectionVendeur extends StatelessWidget {
  const _SectionVendeur({required this.nom});

  final String nom;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Vendeur',
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: CachedNetworkImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=200&h=200&fit=crop&auto=format',
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: AppColors.surfaceSoft),
              errorWidget: (_, _, _) =>
                  Container(color: AppColors.surfaceSoft),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      nom,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _kPrimarySoft,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Coop',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      '★',
                      style: TextStyle(color: _kWarn, fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '4.8 · 47 ventes',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => Snackbars.showInfo(context, 'Messagerie — à venir'),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary,
                  width: AppDimens.borderThin,
                ),
              ),
              child: Text(
                'Message',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section "Comment ça marche" 3 steps ──────────────────────────────

class _SectionCommentCaMarche extends StatelessWidget {
  const _SectionCommentCaMarche();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Comment ça marche ?',
      child: Row(
        children: const [
          Expanded(
            child: _StepCard(num: '1', label: 'Réserve avec 10% d\'acompte'),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _StepCard(num: '2', label: 'Le producteur récolte'),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _StepCard(num: '3', label: 'Paie le solde à la livraison'),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.num, required this.label});

  final String num;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            alignment: Alignment.center,
            child: Text(
              num,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sticky bottom (qty + bouton réserver) ────────────────────────────

class _StickyBottom extends StatelessWidget {
  const _StickyBottom({
    required this.qte,
    required this.onMinus,
    required this.onPlus,
    required this.onReserver,
  });

  final int qte;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onReserver;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border, width: AppDimens.borderThin),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  InkWell(
                    onTap: onMinus,
                    child: Container(
                      width: 36,
                      height: 44,
                      color: AppColors.surfaceSoft,
                      alignment: Alignment.center,
                      child: const Text(
                        '−',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 54,
                    height: 44,
                    alignment: Alignment.center,
                    child: Text(
                      '$qte',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onPlus,
                    child: Container(
                      width: 36,
                      height: 44,
                      color: AppColors.surfaceSoft,
                      alignment: Alignment.center,
                      child: const Text(
                        '+',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: onReserver,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Réserver (acompte 10%)',
                    style: AppTextStyles.button.copyWith(
                      fontSize: 14,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Wrapper section ──────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              title.toUpperCase(),
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                color: AppColors.text,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────

final _nf = NumberFormat('#,##0', 'fr_FR');
