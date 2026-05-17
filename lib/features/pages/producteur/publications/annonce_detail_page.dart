import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../models/enums.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── Couleurs accent (conformes au mockup) ───────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

const String _kHeroPhotoFallback =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=600&h=400&fit=crop&auto=format';

// ─── Mock acheteurs intéressés (calqué sur la maquette) ──────────────────

class _MockBuyer {
  final String nom;
  final String demande;
  final String avatarUrl;

  const _MockBuyer({
    required this.nom,
    required this.demande,
    required this.avatarUrl,
  });
}

const List<_MockBuyer> _kMockBuyers = [
  _MockBuyer(
    nom: 'Restaurant Le Baoulé',
    demande: 'Demande 100 kg',
    avatarUrl:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop&auto=format',
  ),
  _MockBuyer(
    nom: 'Marie Yao',
    demande: 'Demande 100 kg',
    avatarUrl:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=200&fit=crop&auto=format',
  ),
  _MockBuyer(
    nom: 'Hôtel Beau Rivage',
    demande: 'Demande 100 kg',
    avatarUrl:
        'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=200&h=200&fit=crop&auto=format',
  ),
];

/// Provider familial : récupère une annonce de vente par id.
final _annonceDetailProvider = FutureProvider.autoDispose
    .family<AnnonceVente, String>((ref, id) async {
  return ref.watch(marketplaceServiceProvider).getAnnonceVente(id);
});

/// Détail d'une annonce de vente côté producteur — hero, KPIs, caracs,
/// acheteurs intéressés, sticky bouton.
class AnnonceDetailPage extends ConsumerWidget {
  const AnnonceDetailPage({required this.annonceId, super.key});

  final String annonceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_annonceDetailProvider(annonceId));

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Column(
            children: [
              _Header(),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const _Header(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger l\'annonce.',
                    onRetry: () =>
                        ref.invalidate(_annonceDetailProvider(annonceId)),
                  ),
                ),
              ),
            ],
          ),
          data: (annonce) => _Content(annonce: annonce),
        ),
      ),
    );
  }
}

// ─── Header (fond blanc, border-bottom) ──────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({this.onEdit});

  final VoidCallback? onEdit;

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
              'Mon annonce',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onEdit != null)
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(20),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.edit_outlined,
                  size: 20,
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
  const _Content({required this.annonce});

  final AnnonceVente annonce;

  @override
  Widget build(BuildContext context) {
    final messagesCount = 5;
    final commandesCount = 2;

    return Column(
      children: [
        _Header(
          onEdit: () => Snackbars.showInfo(context, 'Édition — à venir'),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              _Hero(annonce: annonce),
              _KpiRow(
                vues: annonce.viewsCount,
                messages: messagesCount,
                commandes: commandesCount,
              ),
              _SectionCaracteristiques(annonce: annonce),
              _SectionAcheteursInteresses(
                buyers: _kMockBuyers,
                onRepondre: (b) => Snackbars.showInfo(
                  context,
                  'Répondre à ${b.nom} — à venir',
                ),
              ),
            ],
          ),
        ),
        _StickyButtons(
          onPause: () => Snackbars.showInfo(context, 'Mise en pause — à venir'),
          onModifier: () => Snackbars.showInfo(context, 'Modifier — à venir'),
        ),
      ],
    );
  }
}

// ─── Hero ────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({required this.annonce});

  final AnnonceVente annonce;

  @override
  Widget build(BuildContext context) {
    final photoUrl = annonce.photos.isNotEmpty
        ? annonce.photos.first
        : _kHeroPhotoFallback;
    final titreComplet = _titreComplet(annonce);

    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: CachedNetworkImage(
              imageUrl: photoUrl,
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
                  titreComplet,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                _ChipStatut(status: annonce.status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _titreComplet(AnnonceVente a) {
    final qualite = _qualiteLabel(a.qualite);
    if (qualite == null) return a.titre;
    if (a.titre.toLowerCase().contains(qualite.toLowerCase())) return a.titre;
    return '${a.titre} — qualité $qualite';
  }
}

class _ChipStatut extends StatelessWidget {
  const _ChipStatut({required this.status});

  final ProductStatus status;

  @override
  Widget build(BuildContext context) {
    final label = _statusLabel(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── KPI row 3 colonnes ──────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  const _KpiRow({
    required this.vues,
    required this.messages,
    required this.commandes,
  });

  final int vues;
  final int messages;
  final int commandes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
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
          Expanded(child: _KpiCol(value: vues.toString(), label: 'Vues')),
          const _Divider(),
          Expanded(child: _KpiCol(value: messages.toString(), label: 'Messages')),
          const _Divider(),
          Expanded(
            child: _KpiCol(value: commandes.toString(), label: 'Commandes'),
          ),
        ],
      ),
    );
  }
}

class _KpiCol extends StatelessWidget {
  const _KpiCol({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimens.borderThin,
      height: 32,
      color: AppColors.border,
    );
  }
}

// ─── Section caractéristiques ────────────────────────────────────────────

class _SectionCaracteristiques extends StatelessWidget {
  const _SectionCaracteristiques({required this.annonce});

  final AnnonceVente annonce;

  @override
  Widget build(BuildContext context) {
    final qte = NumberFormat('#,##0', 'fr_FR').format(annonce.quantiteKg);
    final prix = NumberFormat('#,##0', 'fr_FR').format(annonce.prixParKg);
    final dispoDate = annonce.dateRecolte;
    final dispoTexte = dispoDate == null
        ? 'Immédiate'
        : DateFormat('d MMM y', 'fr_FR').format(dispoDate);

    return _SectionCard(
      title: 'Caractéristiques',
      children: [
        _Feat(label: 'Produit', value: annonce.titre),
        _Feat(label: 'Qualité', value: _qualiteLabel(annonce.qualite) ?? '—'),
        _Feat(label: 'Quantité', value: '$qte kg'),
        _Feat(label: 'Prix', value: '$prix F/kg'),
        _Feat(label: 'Date dispo', value: dispoTexte),
        _Feat(label: 'Parcelle source', value: 'Parcelle Nord (4 ha)'),
      ],
    );
  }
}

class _Feat extends StatelessWidget {
  const _Feat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section acheteurs intéressés ────────────────────────────────────────

class _SectionAcheteursInteresses extends StatelessWidget {
  const _SectionAcheteursInteresses({
    required this.buyers,
    required this.onRepondre,
  });

  final List<_MockBuyer> buyers;
  final ValueChanged<_MockBuyer> onRepondre;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Acheteurs intéressés',
      children: [
        for (var i = 0; i < buyers.length; i++)
          _BuyerRow(
            buyer: buyers[i],
            isLast: i == buyers.length - 1,
            onRepondre: () => onRepondre(buyers[i]),
          ),
      ],
    );
  }
}

class _BuyerRow extends StatelessWidget {
  const _BuyerRow({
    required this.buyer,
    required this.isLast,
    required this.onRepondre,
  });

  final _MockBuyer buyer;
  final bool isLast;
  final VoidCallback onRepondre;

  @override
  Widget build(BuildContext context) {
    final nomTronque = _troncTrop(buyer.nom);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
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
              imageUrl: buyer.avatarUrl,
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
                const SizedBox(height: 2),
                Text(
                  buyer.demande,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onRepondre,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary,
                  width: AppDimens.borderThin,
                ),
              ),
              child: Text(
                'Répondre',
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

  /// Tronque "Restaurant Le Baoulé" → tel quel, mais raccourcit "Aya Roberta"
  /// → "Aya R." si > 14 caractères pour suivre le pattern de la maquette
  /// (exemple : "Aya R.").
  String _troncTrop(String n) {
    if (n.length <= 18) return n;
    final parts = n.split(' ');
    if (parts.length < 2) return '${n.substring(0, 16)}…';
    return '${parts.first} ${parts.last.substring(0, 1)}.';
  }
}

// ─── Sticky bouttons ─────────────────────────────────────────────────────

class _StickyButtons extends StatelessWidget {
  const _StickyButtons({required this.onPause, required this.onModifier});

  final VoidCallback onPause;
  final VoidCallback onModifier;

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
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onPause,
              borderRadius: AppDimens.brButton,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppDimens.brButton,
                  border: Border.all(
                    color: AppColors.border,
                    width: AppDimens.borderThin,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Mettre en pause',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 14,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: onModifier,
              borderRadius: AppDimens.brButton,
              child: Container(
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
                  'Modifier',
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
    );
  }
}

// ─── Carte section générique (titre uppercase + children) ────────────────

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

// ─── Helpers ─────────────────────────────────────────────────────────────

String _statusLabel(ProductStatus s) {
  switch (s) {
    case ProductStatus.active:
      return 'Active';
    case ProductStatus.paused:
      return 'En pause';
    case ProductStatus.sold:
      return 'Vendue';
    case ProductStatus.draft:
      return 'Brouillon';
    case ProductStatus.expired:
      return 'Expirée';
    case ProductStatus.unknown:
      return 'Active';
  }
}

String? _qualiteLabel(ProductQuality q) {
  switch (q) {
    case ProductQuality.standard:
      return 'Standard';
    case ProductQuality.premium:
      return 'Premium';
    case ProductQuality.bio:
      return 'Bio';
    case ProductQuality.equitable:
      return 'Équitable';
    case ProductQuality.unknown:
      return null;
  }
}
