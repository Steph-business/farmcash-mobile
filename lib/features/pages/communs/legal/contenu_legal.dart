/// Contenu placeholder des 4 documents légaux FarmCash.
///
/// CGU, CGV, Politique de Confidentialité, Mentions légales.
///
/// Texte provisoire — sera remplacé par la version finalisée par notre
/// cabinet juridique avant le lancement officiel. Référence la loi
/// ivoirienne 2013-450 sur la protection des données, la BCEAO pour les
/// paiements mobile money, le soft-delete 30 jours, etc.
library;

// ─── Identifiants de document (utilisés dans le routing) ───────────────

class LegalDocType {
  LegalDocType._();

  static const String cgu = 'cgu';
  static const String cgv = 'cgv';
  static const String privacy = 'privacy';
  static const String mentions = 'mentions';

  static const Set<String> all = {cgu, cgv, privacy, mentions};
}

// ─── Versions courantes (à incrémenter à chaque révision) ──────────────

/// Version courante des CGU. Comparée à la dernière version acceptée par
/// l'utilisateur (`getConsentStatus`) — si différent, on re-demande.
const String kCurrentTermsVersion = '1.0.0';

/// Version courante de la Politique de Confidentialité.
const String kCurrentPrivacyVersion = '1.0.0';

/// Date de dernière mise à jour affichée en tête de chaque document.
const String kLastUpdatedDate = '11 juin 2026';

// ─── Disclaimer affiché en bas de chaque document ──────────────────────

const String kDisclaimerLegal =
    'Version provisoire — sera finalisée par notre cabinet juridique '
    'avant le lancement officiel.';

// ─── Métadonnées d'un document (titre, sous-titre, corps) ──────────────

class LegalDocument {
  const LegalDocument({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.version,
  });

  final String title;
  final String subtitle;
  final String body;
  final String version;
}

/// Catalogue indexé par `LegalDocType.*`. Le texte est volontairement
/// long et structuré pour donner une impression réaliste avant la
/// validation juridique finale.
const Map<String, LegalDocument> kLegalDocuments = {
  LegalDocType.cgu: LegalDocument(
    title: 'Conditions Générales d\'Utilisation',
    subtitle: 'Version $kCurrentTermsVersion · Mise à jour le $kLastUpdatedDate',
    version: kCurrentTermsVersion,
    body: '''1. Objet du service

FarmCash est une plateforme numérique éditée en République de Côte d'Ivoire qui met en relation des producteurs agricoles, des coopératives, des acheteurs et des transporteurs autour d'un marché protégé par un système de séquestre (escrow).

FarmCash agit en qualité d'intermédiaire technique. Nous ne sommes pas partie aux transactions commerciales conclues entre les utilisateurs et nous ne garantissons ni la qualité physique des produits ni l'exécution effective des prestations de transport, hors les obligations de séquestre et de médiation décrites ci-dessous.

2. Acceptation et opposabilité

En créant un compte ou en utilisant l'application, tu acceptes sans réserve les présentes Conditions Générales d'Utilisation. Le simple fait de cocher la case d'acceptation lors du premier lancement vaut signature électronique opposable conformément à l'ordonnance ivoirienne sur les transactions électroniques.

Les présentes CGU sont versionnées. Toute modification substantielle entraîne une nouvelle demande de consentement au prochain lancement de l'application.

3. Inscription et identification

L'inscription s'effectue par numéro de téléphone vérifié par code OTP, puis par la définition d'un code PIN à 4-6 chiffres. Selon ton rôle (producteur, coopérative, acheteur, transporteur), des justificatifs complémentaires peuvent être demandés au titre du KYC : pièce d'identité, RCCM, agrément coopératif, permis de conduire et carte grise.

Tu déclares être majeur·e au sens du droit ivoirien et, si tu agis pour le compte d'une personne morale, disposer du pouvoir de l'engager.

4. Paiements et séquestre

Tous les paiements transitent par notre partenaire prestataire de services de paiement et sont placés sous séquestre conformément aux principes posés par la BCEAO en matière d'émission de monnaie électronique et de mobile money.

Les fonds de l'acheteur sont bloqués jusqu'à confirmation de la livraison par scan du QR-code de remise. En cas de litige déclaré dans les délais, le séquestre est conservé jusqu'à résolution par notre équipe de médiation ou décision arbitrale.

Les retraits vers un wallet mobile money sont traités sous 24 à 48 heures ouvrées. Les frais éventuels prélevés par l'opérateur ne sont pas imputables à FarmCash.

5. Commissions FarmCash

FarmCash prélève une commission sur chaque transaction finalisée. Le taux exact est affiché à l'utilisateur avant validation du paiement et est susceptible de varier selon la catégorie de produit et le volume.

L'inscription, la création d'annonces, la consultation du marché et la messagerie sont gratuites.

6. Obligations des utilisateurs

Tu t'engages à ne publier que des annonces véridiques, conformes à la réglementation phytosanitaire et douanière en vigueur, et à ne pas contourner le système de paiement de la plateforme par des arrangements de gré-à-gré en espèces entre utilisateurs FarmCash.

Tu t'interdis tout contenu illicite, frauduleux, diffamatoire ou portant atteinte aux droits d'autrui. Tout comportement contraire pourra entraîner la suspension ou la suppression du compte sans préavis et sans préjudice de poursuites.

7. Cycle de vie du compte et suppression

Tu peux à tout moment demander la suppression de ton compte depuis Profil → Légal → Supprimer mon compte. Conformément au principe de minimisation des données, la suppression est immédiate côté interface mais ouvre une période de 30 jours dits de soft-delete pendant laquelle le compte peut être restauré et au terme de laquelle les données sont effectivement purgées.

Les obligations légales de conservation comptable et fiscale peuvent justifier la conservation au-delà de cette période de certaines pièces justificatives anonymisées (factures, journaux d'escrow).

8. Propriété intellectuelle

L'application FarmCash, son code source, ses interfaces, sa marque et ses contenus éditoriaux sont protégés par le droit d'auteur et le droit des marques. Toute reproduction, distribution ou rétro-ingénierie non autorisée est interdite.

Tu conserves les droits sur les contenus que tu publies (descriptions, photos, notes vocales) mais tu nous concèdes une licence non exclusive et gratuite pour les besoins du fonctionnement du service.

9. Responsabilité et limitations

FarmCash met en œuvre des moyens raisonnables pour assurer la sécurité, l'intégrité et la disponibilité du service. Notre responsabilité ne saurait être engagée en cas de force majeure, d'interruption de service de nos partenaires (mobile money, hébergeur, opérateur télécom) ou d'utilisation non conforme par un tiers.

En tout état de cause, notre responsabilité totale au titre des présentes ne pourra excéder le montant total des commissions perçues par FarmCash sur les opérations litigieuses sur les douze mois précédant le fait générateur.

10. Droit applicable et juridiction

Les présentes Conditions Générales d'Utilisation sont régies par le droit ivoirien. Tout litige relatif à leur formation, leur interprétation ou leur exécution relève en premier ressort de la compétence des tribunaux d'Abidjan, sous réserve d'une tentative préalable de règlement amiable par l'intermédiaire de notre support.

$kDisclaimerLegal''',
  ),

  LegalDocType.cgv: LegalDocument(
    title: 'Conditions Générales de Vente',
    subtitle: 'Version 1.0.0 · Mise à jour le $kLastUpdatedDate',
    version: '1.0.0',
    body: '''1. Champ d'application

Les présentes Conditions Générales de Vente régissent l'ensemble des transactions conclues sur la marketplace FarmCash entre les utilisateurs vendeurs (producteurs, coopératives) et les utilisateurs acheteurs, dès lors qu'elles transitent par le système de séquestre de la plateforme.

FarmCash n'est pas vendeur des produits proposés sur la plateforme et n'est partie aux contrats de vente conclus qu'à raison de son rôle d'intermédiaire technique et de séquestre.

2. Formation du contrat

Le contrat de vente est formé entre vendeur et acheteur lors de la validation du paiement par l'acheteur, après acceptation expresse de la fiche produit, du prix, des quantités et des modalités de livraison. La confirmation est matérialisée par un récapitulatif de commande envoyé par notification dans l'application.

Pour les commandes coopératives supérieures à 500 kilogrammes, un bon de commande au format PDF est automatiquement généré et accessible depuis le détail de la commande.

3. Prix et conditions financières

Les prix sont affichés en francs CFA, hors frais de transport et hors commission FarmCash. Le détail du décompte est présenté à l'acheteur avant validation du paiement.

Les paiements sont effectués via les opérateurs mobile money agréés par la BCEAO ou par tout autre moyen de paiement supporté par notre prestataire de services de paiement. Le paiement déclenche un séquestre sur le wallet plateforme.

4. Modalités de livraison

La livraison est assurée soit par un transporteur tiers référencé sur FarmCash, soit par la coopérative elle-même dans le cas d'un transport interne, soit en retrait direct par l'acheteur sur un point de remise convenu.

Le suivi en temps réel est disponible dans le détail de la commande. La remise effective est constatée par scan du QR-code de livraison, qui constitue l'événement déclencheur de la libération du séquestre au profit du vendeur.

5. Conformité, contestations et litiges

L'acheteur dispose d'un délai de 48 heures à compter de la remise effective pour signaler tout défaut de conformité depuis l'écran de détail de la commande ou via le module Signaler un problème.

L'ouverture d'un litige suspend la libération du séquestre. Notre équipe de médiation instruit le dossier et tente de proposer une résolution amiable. À défaut d'accord, la décision finale appartient au médiateur désigné par FarmCash, sans préjudice du droit pour les parties de saisir les juridictions compétentes.

6. Garanties et assurances

FarmCash ne garantit pas la qualité phytosanitaire des produits au-delà des contrôles déclaratifs effectués lors de la publication. La garantie commerciale demeure de la responsabilité du vendeur dans les conditions du droit commun.

Pour les commandes coopératives, des garanties qualité spécifiques peuvent être affichées sur la fiche produit lorsqu'elles sont engagées par la coopérative émettrice.

7. Annulation et remboursement

L'acheteur peut annuler une commande tant qu'elle est au statut PENDING. Au-delà, l'annulation suppose l'accord du vendeur ou la résolution du litige. Les remboursements sont effectués sur le wallet FarmCash de l'acheteur dans un délai maximal de 7 jours ouvrés.

Un cron automatique de remboursement s'applique aux commandes acceptées non livrées au-delà de 7 jours, sauf paiement étagé en cours d'exécution.

8. Données et confidentialité

Les données échangées dans le cadre de la vente (coordonnées, montants, traçabilité) sont traitées conformément à notre Politique de Confidentialité et à la loi ivoirienne n° 2013-450 sur la protection des données à caractère personnel.

9. Force majeure

Aucune des parties ne saurait être tenue responsable d'un manquement à ses obligations en cas de force majeure au sens du droit ivoirien, incluant les troubles à l'ordre public, les ruptures d'infrastructure télécom ou les épidémies affectant la chaîne agricole.

10. Droit applicable

Les présentes Conditions Générales de Vente sont régies par le droit ivoirien. Tout litige relèvera de la compétence des tribunaux d'Abidjan, sous réserve de la médiation préalable.

$kDisclaimerLegal''',
  ),

  LegalDocType.privacy: LegalDocument(
    title: 'Politique de Confidentialité',
    subtitle: 'Version $kCurrentPrivacyVersion · Mise à jour le $kLastUpdatedDate',
    version: kCurrentPrivacyVersion,
    body: '''1. Responsable de traitement

FarmCash, société de droit ivoirien, dont le siège social est situé à Abidjan, est responsable du traitement des données à caractère personnel collectées via l'application mobile et les services connexes. Conformément à la loi n° 2013-450 du 19 juin 2013 sur la protection des données à caractère personnel, nous nous engageons à un traitement loyal, licite et minimal de tes informations.

2. Données collectées

Nous collectons les catégories de données suivantes :
- Identité et coordonnées : nom complet, numéro de téléphone, adresse électronique, photo de profil.
- Données KYC : pièce d'identité, RCCM, agrément coopératif, permis de conduire, carte grise, selon le rôle.
- Données financières : historique des transactions, mouvements wallet, justificatifs de paiement.
- Données de géolocalisation : positions des transporteurs en cours de mission, zones d'achat/vente déclarées.
- Données techniques : identifiant de l'appareil, token FCM pour les notifications, journaux d'utilisation.
- Données vocales : enregistrements de notes vocales pour la création d'annonces express, traités via un fournisseur d'intelligence artificielle.

3. Finalités du traitement

Tes données sont traitées pour les finalités suivantes :
- Fonctionnement du service de marketplace agricole et du wallet.
- Sécurisation des transactions par séquestre, prévention de la fraude, conformité KYC/LCB-FT.
- Mise en relation entre producteurs, acheteurs, coopératives et transporteurs.
- Personnalisation du contenu (matching intelligent, estimation prix marché).
- Respect des obligations légales et réglementaires (BCEAO, fiscales, comptables).

4. Base légale

Les traitements reposent selon les cas sur l'exécution du contrat (CGU/CGV), sur ton consentement explicite (notes vocales, géolocalisation en arrière-plan), sur l'intérêt légitime (sécurité du service, prévention fraude) ou sur une obligation légale (conservation des journaux d'escrow).

5. Destinataires et sous-traitants

Tes données peuvent être partagées avec :
- Nos prestataires techniques (hébergement, base de données, notifications push, stockage objet).
- Nos partenaires de paiement et mobile money agréés BCEAO.
- Les autorités publiques compétentes sur réquisition judiciaire.
- Les autres utilisateurs de la plateforme, dans la limite du nécessaire à la conclusion d'une transaction (par exemple coordonnées de l'acheteur communiquées au transporteur après acceptation de la mission).

Aucune donnée n'est cédée à des tiers à des fins commerciales sans ton consentement préalable.

6. Durées de conservation

Les données de profil sont conservées pendant toute la durée du compte. Après suppression du compte, une période de soft-delete de 30 jours est appliquée pour permettre la restauration. Au-delà, les données sont effectivement purgées, sous réserve des obligations légales de conservation comptable et fiscale qui peuvent justifier la rétention de certaines pièces anonymisées pour une durée de 10 ans.

7. Tes droits

Conformément à la loi ivoirienne 2013-450, tu disposes des droits suivants :
- Droit d'accès à tes données via la page Légal → Exporter mes données (export JSON immédiat).
- Droit de rectification depuis l'édition du profil.
- Droit à l'effacement via la page Supprimer mon compte (soft-delete 30 jours).
- Droit à la limitation et à l'opposition au traitement, à demander par écrit à notre délégué à la protection des données.
- Droit à la portabilité, satisfait par l'export JSON.

Tu peux exercer ces droits par courriel à privacy@farmcash.ci en justifiant de ton identité. Toute réclamation peut être portée devant l'Autorité de Régulation des Télécommunications de Côte d'Ivoire (ARTCI) en sa qualité d'autorité de protection des données.

8. Sécurité

Nous mettons en œuvre des mesures techniques et organisationnelles raisonnables : chiffrement TLS des communications, chiffrement au repos des justificatifs KYC, authentification forte par PIN, rotation régulière des secrets, journalisation des accès aux données sensibles.

9. Transferts hors UEMOA

Certains de nos sous-traitants techniques sont hébergés en dehors de l'espace UEMOA. Les transferts sont encadrés par des clauses contractuelles types garantissant un niveau de protection équivalent à celui exigé par la loi 2013-450.

10. Cookies et traceurs

L'application mobile n'utilise pas de cookies au sens du web mais s'appuie sur un identifiant local stocké de façon sécurisée (Keychain iOS / Keystore Android) pour maintenir la session.

11. Mineurs

Le service est réservé aux personnes majeures. Aucune donnée concernant des mineurs n'est sciemment collectée.

12. Évolution de la politique

La présente Politique de Confidentialité est versionnée. Toute modification substantielle entraîne une nouvelle demande de consentement explicite au prochain lancement de l'application.

$kDisclaimerLegal''',
  ),

  LegalDocType.mentions: LegalDocument(
    title: 'Mentions légales',
    subtitle: 'Mise à jour le $kLastUpdatedDate',
    version: '1.0.0',
    body: '''1. Éditeur de l'application

L'application mobile FarmCash est éditée par la société FarmCash, société de droit ivoirien immatriculée au Registre du Commerce et du Crédit Mobilier d'Abidjan.

Siège social : Abidjan, République de Côte d'Ivoire.
Numéro RCCM : à compléter à la finalisation juridique.
Capital social : à compléter à la finalisation juridique.
Représentant légal : à compléter à la finalisation juridique.

Contact général : contact@farmcash.ci
Contact protection des données : privacy@farmcash.ci
Contact litiges et médiation : litiges@farmcash.ci

2. Directeur de la publication

Le directeur de la publication est le représentant légal de la société FarmCash.

3. Hébergement

L'infrastructure applicative de FarmCash est hébergée par un prestataire technique professionnel répondant aux exigences de sécurité et de disponibilité requises par les services financiers et de mobile money. Les coordonnées de l'hébergeur peuvent être communiquées sur demande motivée.

4. Conception et développement

La conception, le développement et la maintenance de l'application sont assurés par les équipes techniques internes de FarmCash et ses partenaires sous contrat.

5. Propriété intellectuelle

L'ensemble des éléments composant l'application FarmCash (textes, illustrations, photographies, marques, logos, vidéos, code source, bases de données, interfaces) sont la propriété exclusive de FarmCash ou de ses partenaires titulaires des droits afférents.

Toute représentation, reproduction, diffusion, modification, vente, publication ou exploitation commerciale, intégrale ou partielle, sans autorisation écrite préalable, est strictement interdite et passible des sanctions prévues par le droit ivoirien de la propriété intellectuelle.

6. Conditions générales

L'usage de l'application est subordonné à l'acceptation des Conditions Générales d'Utilisation, des Conditions Générales de Vente et de la Politique de Confidentialité, accessibles depuis la page Légal et confidentialité.

7. Activité réglementée

FarmCash opère en lien avec des partenaires de paiement agréés par la Banque Centrale des États de l'Afrique de l'Ouest (BCEAO) pour les services de mobile money et d'émission de monnaie électronique. FarmCash n'émet pas elle-même de monnaie électronique et n'effectue pas d'opérations de banque réservées.

8. Médiation et litiges

Préalablement à toute action judiciaire, les utilisateurs sont invités à contacter le service de médiation FarmCash à l'adresse litiges@farmcash.ci. À défaut de résolution amiable, les juridictions ivoiriennes sont seules compétentes, en application du droit ivoirien.

9. Crédits

Les icônes, polices et illustrations open-source utilisées sont conformes à leurs licences respectives, dont la liste détaillée peut être communiquée sur demande.

10. Mise à jour

Les présentes mentions légales sont mises à jour autant que de besoin pour refléter l'évolution des informations de l'éditeur et du service.

$kDisclaimerLegal''',
  ),
};

/// Résout en mémoire le document à afficher. Retourne `null` si le type
/// est inconnu — la page viewer affichera alors un état vide.
LegalDocument? resolveLegalDocument(String docType) {
  return kLegalDocuments[docType];
}
