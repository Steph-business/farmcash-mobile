import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../models/publication_coop.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/acheteur/marche/badge_prix_negocie_coop.dart';
import '../../../widgets/acheteur/marche/sheet_negocier_publication_coop.dart';
import '../../../widgets/communs/badge_prix_marche.dart';
import '../../../widgets/communs/bandeau_intervalle_recolte.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/entete_page_standard.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

/// Détail d'une publication coop côté ACHETEUR.
///
/// Distinct de la fiche annonce solo (`AnnonceDetailAcheteurPage`) :
/// les publications coop sont des lots agrégés stockés dans une table
/// dédiée (`publications_stock_coop`). Le hard work des garanties
/// (carte « Garanties coop », bandeau confiance escrow, bon de
/// commande PDF) est déjà fait — on les compose ici.
///
/// V1 minimal : photo + infos + intervalle récolte + CTA « Commander ».
/// Le flow commande complet (panier, paiement) sera branché en V2 via
/// le service orders qui supporte déjà publication_coop_id.
class PublicationCoopDetailAcheteurPage extends ConsumerWidget {
  const PublicationCoopDetailAcheteurPage({super.key, required this.id});

  final String id;

  static final _provider =
      FutureProvider.autoDispose.family<PublicationCoop, String>(
    (ref, id) => ref.read(cooperativesServiceProvider).getPublication(id),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_provider(id));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePageStandard(titre: 'Lot coopérative'),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger la publication. $e',
                    onRetry: () => ref.invalidate(_provider(id)),
                  ),
                ),
                data: (pub) => _Contenu(pub: pub),
              ),
            ),
            async.when(
              data: (pub) => _StickyCommander(
                pub: pub,
                onCommander: () => _commander(context, pub),
                onNegocier: () => _negocier(context, ref, pub),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  void _commander(BuildContext context, PublicationCoop pub) {
    // Placeholder V1 — le flow commande via publication_coop_id sera
    // câblé dans une PR séparée (besoin de modifier paiement_commande
    // pour accepter source_type = PUBLICATION_COOP).
    Snackbars.showInfo(
      context,
      'Commande de lot coop — bientôt disponible.',
    );
  }

  /// Ouvre la bottom sheet de saisie d'une contre-offre. À l'envoi
  /// (sheet `pop(true)`), on invalide le provider du badge pour qu'il
  /// rafraîchisse si la coop accepte juste après.
  Future<void> _negocier(
    BuildContext context,
    WidgetRef ref,
    PublicationCoop pub,
  ) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SheetNegocierPublicationCoop(publication: pub),
    );
    if (ok == true) {
      // Invalidate pour rafraîchir l'éventuel badge si la coop accepte
      // immédiatement (peu probable mais cohérent avec le flow annonce).
      ref.invalidate(mesContreOffresCoopAccepteesProvider(pub.id));
    }
  }
}

// ─── Contenu scrollable ─────────────────────────────────────────────

class _Contenu extends StatelessWidget {
  const _Contenu({required this.pub});
  final PublicationCoop pub;

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0', 'fr_FR');
    final total = pub.quantiteKg * pub.prixParKg;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      children: [
        if (pub.photos.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: pub.photos.first,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  color: AppColors.surfaceSoft,
                ),
                errorWidget: (_, _, _) => Container(
                  color: AppColors.surfaceSoft,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.textSubtle,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
        Text(
          pub.titre,
          style: AppTextStyles.titleLarge.copyWith(
            fontFamily: 'Poppins',
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
            letterSpacing: -0.3,
          ),
        ),
        // Badge premium « Prix négocié » — visible UNIQUEMENT si
        // l'acheteur a une contre-offre ACCEPTED sur cette publication.
        BadgePrixNegocieCoop(
          publicationCoopId: pub.id,
          prixMarcheKg: pub.prixParKg,
        ),
        // Badge « Prix marché » — situe le prix du lot par rapport à la
        // médiane des ventes récentes. Pas de regionId au niveau du
        // lot coop (les contributions peuvent venir de plusieurs régions),
        // le backend retombe sur le marché national.
        BadgePrixMarche(
          produitId: pub.produitId,
          qualite: pub.qualite.apiValue,
          prixActuelKg: pub.prixParKg,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(
              Icons.groups_rounded,
              size: 14,
              color: AppColors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              'Lot agrégé par une coopérative',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        BandeauIntervalleRecolte(publication: pub),
        const SizedBox(height: 14),
        _InfoCard(
          title: 'Informations',
          lignes: [
            _Ligne(
              'Quantité disponible',
              '${nf.format(pub.quantiteKg.round())} kg',
            ),
            _Ligne(
              'Prix unitaire',
              '${nf.format(pub.prixParKg.round())} F CFA / kg',
            ),
            _Ligne(
              'Montant total max',
              '${nf.format(total.round())} F CFA',
              highlight: true,
            ),
          ],
        ),
        if (pub.description != null && pub.description!.trim().isNotEmpty) ...[
          const SizedBox(height: 14),
          _InfoCard(
            title: 'Description',
            child: Text(
              pub.description!.trim(),
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
        const SizedBox(height: 14),
        _BandeauGarantieEscrow(),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, this.lignes = const [], this.child});
  final String title;
  final List<_Ligne> lignes;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleSmall.copyWith(
              fontFamily: 'Poppins',
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          if (child != null) child!,
          for (final l in lignes) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l.label,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    l.value,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: l.highlight ? 14 : 13,
                      fontWeight:
                          l.highlight ? FontWeight.w800 : FontWeight.w600,
                      color: l.highlight ? AppColors.primary : AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Ligne {
  const _Ligne(this.label, this.value, {this.highlight = false});
  final String label;
  final String value;
  final bool highlight;
}

class _BandeauGarantieEscrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.20),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          const Icon(Icons.shield_rounded, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Paiement protégé par escrow FarmCash. Refund auto sous 7 j '
              'si non-livré.',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
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

class _StickyCommander extends StatelessWidget {
  const _StickyCommander({
    required this.pub,
    required this.onCommander,
    required this.onNegocier,
  });
  final PublicationCoop pub;
  final VoidCallback onCommander;
  final VoidCallback onNegocier;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
          // 2 CTAs côte à côte : « Négocier » (outline, gauche ~40 %) +
          // « Commander » (plein, droite ~60 %). Pattern identique au
          // sticky annonce solo (sticky_bottom_annonce.dart).
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: InkWell(
                  onTap: onNegocier,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: AppDimens.buttonHeight,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary,
                        width: AppDimens.borderThin,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.handshake_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Négocier',
                          style: AppTextStyles.button.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 6,
                child: SizedBox(
                  height: AppDimens.buttonHeight,
                  child: ElevatedButton.icon(
                    onPressed: onCommander,
                    icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                    label: Text(
                      'Commander',
                      style: AppTextStyles.button.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppDimens.brButton,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
