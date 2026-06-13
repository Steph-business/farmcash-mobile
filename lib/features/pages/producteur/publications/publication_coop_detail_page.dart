import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/communs/entete_page_standard.dart';
import '../../../widgets/producteur/publications/contribution_card_publication_coop.dart';
import '../../../widgets/producteur/publications/header_card_publication_coop.dart';
import '../../../widgets/producteur/publications/prix_card_publication_coop.dart';
import '../../../widgets/producteur/publications/publication_coop_constants.dart';
import '../../../widgets/producteur/publications/quantite_card_publication_coop.dart';
import '../../../widgets/producteur/publications/section_title_publication_coop.dart';
import '../../../widgets/producteur/publications/status_card_publication_coop.dart';

/// Détail d'une publication coopérative — vue côté producteur membre.
///
/// Indique l'agrégat coop, la quote-part du membre, le prix unitaire, le
/// statut et la contribution propre. Mock data en attendant que
/// `cooperativesService.getPublication(id)` soit branché.
class PublicationCoopDetailPage extends ConsumerWidget {
  const PublicationCoopDetailPage({super.key, required this.id});

  /// Identifiant de la publication coop — conservé pour brancher l'API
  /// `cooperativesService.getPublication(id)` ultérieurement.
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock-first : valeurs figées sur une publication de maïs blanc.
    const titre = 'Maïs grain blanc — récolte mai 2026';
    const coopNom = 'COOP-AGRI Lagunes';
    const datePublication = 'Publié le 10 mai 2026';
    const dateLimite = 'Clôture le 30 mai 2026';
    const quantiteAggregee = '4 500 kg';
    const quantiteMembre = '500 kg';
    const prixUnitaire = '350 F/kg';
    const totalMembre = '175 000 F';
    const status = PubStatusPublicationCoop.enCours;
    const qualite = 'Standard';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePageStandard(titre: 'Publication coop'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  0,
                  AppDimens.pagePaddingH,
                  AppDimens.space24,
                ),
                children: [
                  HeaderCardPublicationCoop(
                    titre: titre,
                    coop: coopNom,
                    datePub: datePublication,
                    dateLimite: dateLimite,
                  ),
                  AppDimens.vGap16,
                  const SectionTitlePublicationCoop('Quantité agrégée'),
                  AppDimens.vGap12,
                  const QuantiteCardPublicationCoop(
                    agregee: quantiteAggregee,
                    maPart: quantiteMembre,
                  ),
                  AppDimens.vGap16,
                  const SectionTitlePublicationCoop('Prix'),
                  AppDimens.vGap12,
                  const PrixCardPublicationCoop(
                    prixUnitaire: prixUnitaire,
                    totalMembre: totalMembre,
                  ),
                  AppDimens.vGap16,
                  const SectionTitlePublicationCoop('Statut'),
                  AppDimens.vGap12,
                  const StatusCardPublicationCoop(status: status),
                  AppDimens.vGap16,
                  const SectionTitlePublicationCoop('Ma contribution'),
                  AppDimens.vGap12,
                  const ContributionCardPublicationCoop(
                    quantite: quantiteMembre,
                    qualite: qualite,
                    statut: 'Engagé · en attente de livraison',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
