import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'section_legale.dart';

/// Contenu statique des Conditions générales d'utilisation FarmCash.
///
/// Texte placeholder structuré (10 sections numérotées) — à remplacer par
/// le texte juridique définitif validé par l'équipe légale avant prod.
class ContenuCgu extends StatelessWidget {
  /// Construit le contenu CGU.
  const ContenuCgu({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space16,
        AppDimens.pagePaddingH,
        AppDimens.space24,
      ),
      children: [
        Text(
          'Conditions générales d\'utilisation',
          style: AppTextStyles.titleMedium.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        AppDimens.vGap4,
        Text(
          'Dernière mise à jour : 25 mai 2026',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSubtle,
          ),
        ),
        AppDimens.vGap16,
        const SectionLegale(
          numero: '1',
          titre: 'Objet et acceptation',
          paragraphes: [
            'Les présentes Conditions Générales d\'Utilisation (CGU) '
                'régissent l\'utilisation de l\'application FarmCash, '
                'plateforme de mise en relation entre producteurs, '
                'coopératives, acheteurs et transporteurs agricoles.',
            'En créant un compte ou en utilisant FarmCash, tu acceptes sans '
                'réserve l\'intégralité des présentes CGU. Si tu n\'acceptes '
                'pas ces conditions, tu dois cesser d\'utiliser le service.',
          ],
        ),
        const SectionLegale(
          numero: '2',
          titre: 'Création et gestion du compte',
          paragraphes: [
            'L\'inscription se fait par numéro de téléphone vérifié par code '
                'OTP. Tu choisis ensuite un code PIN à 4-6 chiffres qui '
                'sera ton moyen d\'authentification principal.',
            'Tu t\'engages à fournir des informations exactes et à les tenir '
                'à jour. Tout compte créé sur la base d\'informations '
                'frauduleuses pourra être suspendu sans préavis.',
            'Tu es seul·e responsable de la confidentialité de ton code PIN. '
                'En cas de perte ou de compromission, contacte immédiatement '
                'le support pour bloquer ton compte.',
          ],
        ),
        const SectionLegale(
          numero: '3',
          titre: 'Description du service',
          paragraphes: [
            'FarmCash propose une marketplace agricole sécurisée par escrow, '
                'des outils de gestion (parcelles, stocks, paiements), un '
                'wallet intégré et une mise en relation avec des '
                'transporteurs locaux.',
            'Les fonctionnalités disponibles dépendent de ton rôle '
                '(producteur, acheteur, coopérative, transporteur) déclaré '
                'à l\'inscription.',
          ],
        ),
        const SectionLegale(
          numero: '4',
          titre: 'Paiements et escrow',
          paragraphes: [
            'Tout achat sur FarmCash transite par un système d\'escrow '
                '(séquestre) : le paiement de l\'acheteur est bloqué '
                'jusqu\'à confirmation de la livraison par scan du QR.',
            'En cas de litige, le séquestre est conservé jusqu\'à résolution '
                'par notre équipe support ou décision de médiation.',
            'Les retraits sont soumis à un délai de traitement de 24 à 48h '
                'ouvrées selon le mode de paiement choisi.',
          ],
        ),
        const SectionLegale(
          numero: '5',
          titre: 'Obligations des utilisateurs',
          paragraphes: [
            'Tu t\'engages à ne pas publier de contenu illicite, frauduleux '
                'ou trompeur, et à respecter les règles de bonne conduite '
                'envers les autres utilisateurs.',
            'Les transactions hors-plateforme (paiement en cash entre '
                'utilisateurs FarmCash) sont strictement interdites et '
                'peuvent entraîner la suspension du compte.',
          ],
        ),
        const SectionLegale(
          numero: '6',
          titre: 'Commissions et frais',
          paragraphes: [
            'FarmCash prélève une commission sur chaque transaction réussie. '
                'Le taux exact est affiché avant validation du paiement.',
            'L\'inscription, la création d\'annonces et l\'utilisation des '
                'fonctionnalités principales sont gratuites.',
          ],
        ),
        const SectionLegale(
          numero: '7',
          titre: 'Suspension et résiliation',
          paragraphes: [
            'Nous nous réservons le droit de suspendre ou de supprimer tout '
                'compte ne respectant pas les présentes CGU, avec ou sans '
                'préavis selon la gravité.',
            'Tu peux supprimer ton compte à tout moment depuis la page '
                'Profil. Les transactions en cours doivent être achevées '
                'avant suppression.',
          ],
        ),
        const SectionLegale(
          numero: '8',
          titre: 'Propriété intellectuelle',
          paragraphes: [
            'L\'application FarmCash, son code, sa marque et ses contenus '
                'éditoriaux sont protégés par le droit d\'auteur. Toute '
                'reproduction non autorisée est interdite.',
            'Tu conserves les droits sur les contenus que tu publies '
                '(photos, descriptions) mais accordes à FarmCash une '
                'licence d\'utilisation non exclusive pour les besoins du '
                'service.',
          ],
        ),
        const SectionLegale(
          numero: '9',
          titre: 'Responsabilité',
          paragraphes: [
            'FarmCash agit en tant qu\'intermédiaire technique entre les '
                'utilisateurs. Nous ne sommes pas partie aux transactions '
                'commerciales conclues entre producteurs, acheteurs ou '
                'transporteurs.',
            'Nous mettons en œuvre des moyens raisonnables pour assurer la '
                'sécurité et la disponibilité du service, sans pouvoir '
                'garantir une absence totale d\'interruption.',
          ],
        ),
        const SectionLegale(
          numero: '10',
          titre: 'Droit applicable et juridiction',
          paragraphes: [
            'Les présentes CGU sont régies par le droit de la République de '
                'Côte d\'Ivoire. Tout litige relatif à leur interprétation '
                'ou exécution relève de la compétence exclusive des '
                'tribunaux d\'Abidjan.',
            'Avant toute procédure judiciaire, les parties s\'efforceront '
                'de résoudre amiablement le litige par l\'intermédiaire du '
                'support FarmCash.',
          ],
        ),
      ],
    );
  }
}
