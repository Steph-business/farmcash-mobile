import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/prevision.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/snackbars.dart';

// ─── Couleurs accent (conformes au mockup) ───────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kWarnSoft = Color(0xFFFFF8E1);
const Color _kWarn = Color(0xFFB26A00);

const String _kHeroPhotoFallback =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=600&h=400&fit=crop&auto=format';

// ─── Mock acheteurs réservants ───────────────────────────────────────────

class _MockReservant {
  final String nom;
  final String info;
  final String avatarUrl;

  const _MockReservant({
    required this.nom,
    required this.info,
    required this.avatarUrl,
  });
}

const List<_MockReservant> _kMockReservants = [
  _MockReservant(
    nom: 'Restaurant Le Baoulé',
    info: '200 kg · acompte 10% payé · 7 000 F en escrow',
    avatarUrl:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop&auto=format',
  ),
  _MockReservant(
    nom: 'Marie Yao',
    info: '200 kg · acompte 10% payé · 7 000 F en escrow',
    avatarUrl:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=200&fit=crop&auto=format',
  ),
  _MockReservant(
    nom: 'Hôtel Beau Rivage',
    info: '200 kg · acompte 10% payé · 7 000 F en escrow',
    avatarUrl:
        'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=200&h=200&fit=crop&auto=format',
  ),
];

/// Bundle pour la page : la prévision (optionnelle si l'id n'existe pas
/// dans `listPrevisions`) + un fallback "mock" pour rester aligné au
/// visuel de la maquette quand le back ne renvoie pas encore l'objet.
class _PrevisionData {
  final Prevision? prevision;
  const _PrevisionData({this.prevision});
}

/// Provider familial. Comme `MarketplaceService.getPrevision(id)` n'existe
/// pas dans la version actuelle du service, on liste tout puis on filtre
/// côté client. Si l'id n'est pas trouvé (ex: id mock "prev-1") on garde
/// `prevision == null` et la page affiche les valeurs par défaut de la
/// maquette.
final _previsionDetailProvider = FutureProvider.autoDispose
    .family<_PrevisionData, String>((ref, id) async {
  try {
    final list = await ref.read(marketplaceServiceProvider).listPrevisions();
    final p = list.where((e) => e.id == id).firstOrNull;
    return _PrevisionData(prevision: p);
  } catch (_) {
    return const _PrevisionData(prevision: null);
  }
});

/// Détail d'une prévision producteur — hero, info card, progression
/// réservations, liste réservants, actions, sticky bouton désactivé.
class PrevisionDetailPage extends ConsumerWidget {
  const PrevisionDetailPage({required this.previsionId, super.key});

  final String previsionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_previsionDetailProvider(previsionId));

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        bottom: false,
        child: async.maybeWhen(
          orElse: () => Column(
            children: [
              _Header(
                onMenu: () => Snackbars.showInfo(context, 'Menu — à venir'),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
          data: (data) => _Content(prevision: data.prevision),
        ),
      ),
    );
  }
}

// ─── Header (fond blanc, border-bottom) ──────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.onMenu});

  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
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
              'Ma prévision',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          InkWell(
            onTap: onMenu,
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

// ─── Contenu ─────────────────────────────────────────────────────────────

class _Content extends StatelessWidget {
  const _Content({required this.prevision});

  final Prevision? prevision;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Header(
          onMenu: () => Snackbars.showInfo(context, 'Menu — à venir'),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 130),
            children: [
              _Hero(prevision: prevision),
              _InfoCard(),
              _SectionReservations(),
              _SectionReservants(),
              _SectionActions(
                onModifierDate: () => Snackbars.showInfo(
                  context,
                  'Modifier la date — à venir',
                ),
                onAnnuler: () => Snackbars.showInfo(
                  context,
                  'Annuler la prévision — à venir',
                ),
              ),
            ],
          ),
        ),
        _StickyConvertir(
          onConvertir: () => Snackbars.showInfo(
            context,
            'Disponible à partir du 10 juin',
          ),
        ),
      ],
    );
  }
}

// ─── Hero ────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({required this.prevision});

  final Prevision? prevision;

  @override
  Widget build(BuildContext context) {
    final nom = 'Maïs blanc · 1 tonne prévue le 15 juin';

    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: CachedNetworkImage(
              imageUrl: _kHeroPhotoFallback,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: AppColors.surfaceSoft),
              errorWidget: (_, _, _) =>
                  Container(color: AppColors.surfaceSoft),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
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
                Text(
                  nom,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                _ChipPrevision(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipPrevision extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: _kWarnSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Prévision · J-23',
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _kWarn,
        ),
      ),
    );
  }
}

// ─── Info card (notif "Tu seras notifié …") ──────────────────────────────

class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.info_outline,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tu seras notifié 5 jours avant la date prévue. '
              'Tu pourras alors confirmer la conversion en annonce active.',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                color: AppColors.text,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Réservations reçues (progression) ───────────────────────────

class _SectionReservations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Réservations reçues',
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '600 / 1 000 kg réservés',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            Text(
              '60%',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: SizedBox(
            height: 8,
            child: Stack(
              children: [
                Container(color: AppColors.surfaceSoft),
                FractionallySizedBox(
                  widthFactor: 0.6,
                  child: Container(color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '3 acheteurs ont déjà versé leur acompte',
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ─── Section Acheteurs réservants ────────────────────────────────────────

class _SectionReservants extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Acheteurs réservants',
      children: [
        for (var i = 0; i < _kMockReservants.length; i++)
          _ReservantRow(
            reservant: _kMockReservants[i],
            isLast: i == _kMockReservants.length - 1,
          ),
      ],
    );
  }
}

class _ReservantRow extends StatelessWidget {
  const _ReservantRow({required this.reservant, required this.isLast});

  final _MockReservant reservant;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final nomTronque = _troncTrop(reservant.nom);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: CachedNetworkImage(
              imageUrl: reservant.avatarUrl,
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
                Text(
                  nomTronque,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  reservant.info,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _troncTrop(String n) {
    if (n.length <= 22) return n;
    final parts = n.split(' ');
    if (parts.length < 2) return '${n.substring(0, 20)}…';
    return '${parts.first} ${parts.last.substring(0, 1)}.';
  }
}

// ─── Section Actions (boutons outline plein largeur) ─────────────────────

class _SectionActions extends StatelessWidget {
  const _SectionActions({
    required this.onModifierDate,
    required this.onAnnuler,
  });

  final VoidCallback onModifierDate;
  final VoidCallback onAnnuler;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Actions',
      children: [
        _ActionButton(
          icon: Icons.calendar_today_outlined,
          label: 'Modifier la date de récolte',
          variant: _ActionVariant.outlineGreen,
          onTap: onModifierDate,
        ),
        const SizedBox(height: 10),
        _ActionButton(
          icon: Icons.cancel_outlined,
          label: 'Annuler la prévision (remboursement automatique)',
          variant: _ActionVariant.outlineGrey,
          onTap: onAnnuler,
        ),
      ],
    );
  }
}

enum _ActionVariant { outlineGreen, outlineGrey }

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.variant,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final _ActionVariant variant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isGreen = variant == _ActionVariant.outlineGreen;
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimens.brButton,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppDimens.brButton,
          border: Border.all(
            color: isGreen ? AppColors.primary : AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppDimens.iconM,
              color: isGreen ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.button.copyWith(
                  fontSize: 14,
                  color: isGreen ? AppColors.primary : AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sticky bottom : bouton désactivé "Convertir maintenant" ─────────────

class _StickyConvertir extends StatelessWidget {
  const _StickyConvertir({required this.onConvertir});

  final VoidCallback onConvertir;

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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: 0.5,
            child: InkWell(
              onTap: onConvertir,
              borderRadius: AppDimens.brButton,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppDimens.brButton,
                  border: Border.all(
                    color: AppColors.primary,
                    width: AppDimens.borderThin,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Convertir maintenant',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 14,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Disponible à partir du 10 juin',
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Carte section générique ─────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              title.toUpperCase(),
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
