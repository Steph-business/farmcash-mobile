import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'section_legale.dart';

/// Contenu statique de la Politique de confidentialité FarmCash.
///
/// Texte placeholder structuré (8 sections) — à remplacer par le texte
/// définitif validé légalement avant prod (compatible RGPD + lois ivoiriennes).
class ContenuConfidentialite extends StatelessWidget {
  /// Construit le contenu de la politique de confidentialité.
  const ContenuConfidentialite({super.key});

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
          'Politique de confidentialité',
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
          titre: 'Données que nous collectons',
          paragraphes: [
            'Identité : nom, prénom, photo de profil, numéro de téléphone, '
                'email (facultatif), date de naissance.',
            'Documents : pièce d\'identité, justificatif d\'adresse, '
                'documents véhicule (transporteur), agrément coopérative.',
            'Activité : annonces publiées, commandes, paiements, '
                'positions GPS lors des livraisons (transporteur), '
                'parcelles déclarées.',
            'Données techniques : modèle d\'appareil, OS, adresse IP, '
                'journaux d\'utilisation, identifiant publicitaire (si '
                'autorisé).',
          ],
        ),
        const SectionLegale(
          numero: '2',
          titre: 'Comment nous utilisons tes données',
          paragraphes: [
            'Fournir et améliorer le service (création de compte, mise en '
                'relation, paiements escrow, suivi des livraisons).',
            'Vérification d\'identité (KYC) conformément aux obligations '
                'légales anti-blanchiment.',
            'Communication : notifications transactionnelles (commandes, '
                'paiements), messages support, alertes de sécurité.',
            'Statistiques agrégées et anonymisées pour comprendre les '
                'usages et améliorer l\'expérience.',
          ],
        ),
        const SectionLegale(
          numero: '3',
          titre: 'Partage avec des tiers',
          paragraphes: [
            'Avec les autres utilisateurs : informations strictement '
                'nécessaires à la transaction (nom, téléphone, adresse de '
                'livraison) — pas plus.',
            'Avec nos prestataires techniques (hébergeur, mobile money) '
                'sous contrat de confidentialité strict.',
            'Avec les autorités compétentes en cas d\'obligation légale '
                '(enquête judiciaire, contrôle fiscal).',
            'Nous ne vendons JAMAIS tes données à des tiers à des fins '
                'commerciales ou publicitaires.',
          ],
        ),
        const SectionLegale(
          numero: '4',
          titre: 'Durée de conservation',
          paragraphes: [
            'Compte actif : pendant toute la durée d\'utilisation.',
            'Après suppression : les données d\'identité et de transactions '
                'sont conservées 5 ans pour répondre aux obligations légales '
                '(comptabilité, anti-blanchiment).',
            'Les données techniques (logs) sont conservées 12 mois maximum.',
          ],
        ),
        const SectionLegale(
          numero: '5',
          titre: 'Tes droits',
          paragraphes: [
            'Tu disposes d\'un droit d\'accès, de rectification et de '
                'suppression de tes données personnelles. Tu peux exercer '
                'ces droits depuis ton profil ou en contactant le support.',
            'Tu peux également t\'opposer au traitement de tes données ou '
                'demander leur portabilité (export dans un format '
                'standard).',
            'Pour toute réclamation, tu peux nous contacter à '
                'privacy@farmcash.app ou saisir l\'autorité de protection '
                'des données compétente.',
          ],
        ),
        const SectionLegale(
          numero: '6',
          titre: 'Sécurité',
          paragraphes: [
            'Tes données sont stockées sur des serveurs sécurisés en Europe '
                'avec chiffrement au repos et en transit (HTTPS/TLS).',
            'Ton code PIN n\'est jamais stocké en clair — uniquement un '
                'hash cryptographique fort (Argon2).',
            'L\'accès interne aux données utilisateur est strictement '
                'limité au personnel autorisé et tracé.',
          ],
        ),
        const SectionLegale(
          numero: '7',
          titre: 'Cookies et traceurs',
          paragraphes: [
            'L\'application mobile n\'utilise pas de cookies au sens '
                'classique mais peut utiliser des identifiants techniques '
                'pour le bon fonctionnement de l\'app.',
            'Les outils d\'analyse (mesure d\'audience anonyme) peuvent '
                'être désactivés depuis Paramètres → Notifications & '
                'analytique.',
          ],
        ),
        const SectionLegale(
          numero: '8',
          titre: 'Modifications',
          paragraphes: [
            'Cette politique peut être mise à jour pour refléter des '
                'évolutions légales ou techniques. Tu seras notifié·e par '
                'push et email en cas de modification substantielle.',
            'Pour toute question : privacy@farmcash.app — réponse sous 30 '
                'jours conformément à la réglementation.',
          ],
        ),
      ],
    );
  }
}
