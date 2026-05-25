import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/annonce_vente.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/acheteur/marche/annonce_detail_constants.dart';
import '../../../widgets/acheteur/marche/header_annonce_detail.dart';
import '../../../widgets/acheteur/marche/hero_annonce.dart';
import '../../../widgets/acheteur/marche/section_certifications_annonce.dart';
import '../../../widgets/acheteur/marche/section_description_annonce.dart';
import '../../../widgets/acheteur/marche/section_infos_annonce.dart';
import '../../../widgets/acheteur/marche/section_origine_annonce.dart';
import '../../../widgets/acheteur/marche/section_tracabilite_annonce.dart';
import '../../../widgets/acheteur/marche/section_vendeur_annonce.dart';
import '../../../widgets/acheteur/marche/sticky_bottom_annonce.dart';
import '../../../widgets/acheteur/marche/title_card_annonce.dart';
import '../../../widgets/communs/chargement.dart';
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
              HeaderAnnonceDetail(title: 'Chargement…'),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const HeaderAnnonceDetail(title: 'Annonce'),
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
        HeaderAnnonceDetail(title: titreHeader),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              HeroAnnonce(photos: annonce.photos),
              TitleCardAnnonce(
                nom: nom,
                prixParKg: prix,
                qteDispo: qteDispo,
                qualite: annonce.qualite,
              ),
              SectionVendeurAnnonce(annonce: annonce),
              SectionOrigineAnnonce(annonce: annonce),
              // Section traçabilité : argument premium "from-farm-to-fork".
              // Affichée systématiquement — y compris quand aucun traitement
              // n'est déclaré (= signal positif "production naturelle").
              SectionTracabiliteAnnonce(traitements: annonce.traitements),
              if (annonce.description != null &&
                  annonce.description!.trim().isNotEmpty)
                SectionDescriptionAnnonce(description: annonce.description!),
              SectionInfosAnnonce(annonce: annonce, qteMinKg: qteMin),
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
          onCommander: () => _commander(annonce, qte),
        ),
      ],
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
      if (!mounted) return;
      Snackbars.showSucces(context, '$qte kg ajouté au panier');
    } on ApiException catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _commander(AnnonceVente annonce, int qte) async {
    // Le paiement reprend l'annonce + la quantité courante via le contexte
    // de la page paiement (qui re-fetch l'annonce + recalcule). Pour cette
    // V1, on passe par `acheteurPaiementCommandePathFor(annonceId)` et la
    // page paiement saura quoi faire.
    context.push(
      RouteNames.acheteurPaiementCommandePathFor(annonce.id),
      extra: {'quantiteKg': qte},
    );
  }
}
