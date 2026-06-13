import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/annonce_vente.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../state/badges_state.dart';
import '../../../widgets/acheteur/marche/annonce_detail_constants.dart';
import '../../../widgets/acheteur/marche/hero_annonce.dart';
import '../../../widgets/acheteur/marche/section_certifications_annonce.dart';
import '../../../widgets/acheteur/marche/section_description_annonce.dart';
import '../../../widgets/acheteur/marche/section_infos_annonce.dart';
import '../../../widgets/acheteur/marche/section_tracabilite_annonce.dart';
import '../../../widgets/acheteur/marche/sheet_negocier_annonce.dart';
import '../../../widgets/acheteur/marche/sticky_bottom_annonce.dart';
import '../../../widgets/acheteur/marche/badge_prix_negocie.dart';
import '../../../widgets/acheteur/marche/title_card_annonce.dart';
import '../../../widgets/communs/badge_prix_marche.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/entete_page_standard.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── Provider ────────────────────────────────────────────────────────

final _annonceAcheteurDetailProvider = FutureProvider.autoDispose
    .family<AnnonceVente, String>((ref, id) async {
  return ref.read(marketplaceServiceProvider).getAnnonceVente(id);
});

/// Détail d'une annonce de vente côté ACHETEUR. Toutes les données
/// proviennent de `GET /marketplace/annonces/vente/:id`.
class AnnonceDetailAcheteurPage extends ConsumerStatefulWidget {
  const AnnonceDetailAcheteurPage({required this.annonceId, super.key});

  final String annonceId;

  @override
  ConsumerState<AnnonceDetailAcheteurPage> createState() =>
      _AnnonceDetailAcheteurPageState();
}

class _AnnonceDetailAcheteurPageState
    extends ConsumerState<AnnonceDetailAcheteurPage> {
  /// Quantité courante. Initialisée à la quantité minimale (ou à 1 si pas
  /// défini) à la première reception du détail.
  int? _qte;

  /// État du bouton "Ajouter au panier".
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_annonceAcheteurDetailProvider(widget.annonceId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Column(
            children: [
              EntetePageStandard(titre: 'Chargement…'),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const EntetePageStandard(titre: 'Annonce'),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger l\'annonce. $e',
                    onRetry: () => ref.invalidate(
                      _annonceAcheteurDetailProvider(widget.annonceId),
                    ),
                  ),
                ),
              ),
            ],
          ),
          data: (annonce) => _buildContent(annonce),
        ),
      ),
    );
  }

  Widget _buildContent(AnnonceVente annonce) {
    final qteDispo = annonce.quantiteKg.round();
    final qteMin = (annonce.quantiteMinKg ?? 1).round().clamp(1, qteDispo);
    _qte ??= qteMin;
    final qte = _qte!.clamp(qteMin, qteDispo);
    final prix = annonce.prixParKg.round();
    final montant = qte * prix;

    final nom = annonce.produitLabel;
    final titreHeader =
        '$nom · ${formatKgAnnonceDetail(qteDispo.toDouble())}';

    return Column(
      children: [
        EntetePageStandard(titre: titreHeader),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              HeroAnnonce(photos: annonce.photos),
              // Titre compact : nom + chip qualité + prix + vendeur + lieu
              // tout en un seul header (style mockup référence).
              TitleCardAnnonce(annonce: annonce, qteDispo: qteDispo),
              // Badge « ton prix négocié » — visible uniquement si
              // l'acheteur courant a une candidature ACCEPTED sur cette
              // annonce. Vue marché personnalisée — pour les autres
              // acheteurs, le prix marché d'origine reste affiché.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BadgePrixNegocie(
                  annonceId: annonce.id,
                  prixMarcheKg: annonce.prixParKg,
                ),
              ),
              // Badge « Prix marché » — situe le prix d'affichage par
              // rapport à la médiane des ventes récentes. Permet à
              // l'acheteur de jauger sa marge de négociation. Silencieux
              // si le backend n'a pas assez de signal.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BadgePrixMarche(
                  produitId: annonce.produitId,
                  regionId: annonce.regionId,
                  qualite: annonce.qualite.apiValue,
                  prixActuelKg: annonce.prixParKg,
                ),
              ),
              // Tableau d'informations clé/valeur (quantité, prix, etc).
              SectionInfosAnnonce(annonce: annonce),
              if (annonce.description != null &&
                  annonce.description!.trim().isNotEmpty)
                SectionDescriptionAnnonce(description: annonce.description!),
              // Sections premium en bas — moins prioritaires que le tableau
              // d'infos, mais utiles pour l'argument qualité.
              SectionTracabiliteAnnonce(traitements: annonce.traitements),
              if (annonce.certifications.isNotEmpty)
                SectionCertificationsAnnonce(
                  certifications: annonce.certifications,
                ),
            ],
          ),
        ),
        StickyBottomAnnonce(
          qte: qte,
          montant: montant,
          maxQte: qteDispo,
          minQte: qteMin,
          busy: _busy,
          onMinus: () => setState(() {
            if (_qte != null && _qte! > qteMin) _qte = _qte! - 1;
          }),
          onPlus: () => setState(() {
            if (_qte != null && _qte! < qteDispo) _qte = _qte! + 1;
          }),
          onAjouterPanier: () => _ajouterAuPanier(annonce, qte),
          onNegocier: () => _negocier(annonce),
        ),
      ],
    );
  }

  /// Ouvre la bottom sheet de négociation : l'acheteur propose son
  /// propre prix + quantité → crée une candidature côté backend. Le
  /// vendeur peut accepter/refuser/contre-proposer. L'annonce publique
  /// garde son prix d'origine sur le marché (négociation privée).
  Future<void> _negocier(AnnonceVente annonce) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SheetNegocierAnnonce(annonce: annonce),
    );
  }

  Future<void> _ajouterAuPanier(AnnonceVente annonce, int qte) async {
    if (_busy) return;
    setState(() => _busy = true);
    final svc = ref.read(marketplaceServiceProvider);
    try {
      await svc.addToPanier(
        annonceId: annonce.id,
        quantiteKg: qte.toDouble(),
      );
      // Invalide le badge panier global pour qu'il se mette à jour
      // immédiatement dans le header (pattern e-commerce : feedback
      // visuel instantané sur l'icône panier).
      ref.invalidate(cartCountProvider);
      if (!mounted) return;
      // Snackbar pro avec action « Voir mon panier » — pattern
      // Amazon / Jumia. L'acheteur peut sauter directement au panier
      // sans devoir le retrouver dans le header.
      Snackbars.showSuccesAction(
        context,
        message: '$qte kg ajouté au panier',
        actionLabel: 'Voir mon panier',
        onAction: () => context.push(RouteNames.acheteurPanierPath),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // Méthode `_commander` retirée : le bouton « Commander » direct sur
  // le détail annonce n'existe plus. L'acheteur passe systématiquement
  // par le panier (pattern e-commerce). La page panier conserve le
  // bouton « Passer commande » qui orchestre le paiement.
}
