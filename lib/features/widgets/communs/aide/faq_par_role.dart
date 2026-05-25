import '../../../../models/enums.dart';

/// Modèle d'une question FAQ.
class QuestionFaq {
  /// Construit une question.
  const QuestionFaq(this.question, this.reponse);

  /// La question affichée (en gras dans l'UI).
  final String question;

  /// La réponse révélée au tap.
  final String reponse;
}

/// Retourne la FAQ adaptée au rôle. Pour chaque rôle on a 4-5 questions
/// fréquentes. La liste reste statique pour V1 ; à terme elle viendra du
/// backend pour permettre des mises à jour sans release.
List<QuestionFaq> faqPourRole(UserRole? role) {
  switch (role) {
    case UserRole.farmer:
      return _faqProducteur;
    case UserRole.buyer:
      return _faqAcheteur;
    case UserRole.cooperative:
      return _faqCooperative;
    case UserRole.transporter:
      return _faqTransporteur;
    default:
      return _faqGenerique;
  }
}

const _faqProducteur = <QuestionFaq>[
  QuestionFaq(
    'Comment publier ma première annonce ?',
    'Appuie sur le bouton + au centre de la barre du bas, choisis "Annonce '
        'de vente" puis sélectionne ta culture, indique quantité, prix et '
        'photo. Tu peux relire avant publication.',
  ),
  QuestionFaq(
    'Comment fonctionnent les paiements ?',
    'Le paiement est sécurisé : l\'acheteur dépose le montant sur ton wallet '
        'bloqué. Une fois la livraison confirmée, les fonds sont débloqués '
        'et retirables.',
  ),
  QuestionFaq(
    'Quels documents pour la KYC ?',
    'Pièce d\'identité (CNI recto/verso), justificatif d\'adresse et photos '
        'de ton exploitation. Tout est chiffré et vérifié sous 48h.',
  ),
  QuestionFaq(
    'Comment rejoindre une coopérative ?',
    'Demande au président de ta coop d\'envoyer une invitation, ou contacte '
        'le support pour qu\'on te mette en relation.',
  ),
  QuestionFaq(
    'Comment retirer mon argent ?',
    'Va dans Wallet → Retirer, choisis ton moyen de paiement (Mobile Money '
        'ou compte bancaire) et confirme avec ton PIN. Les fonds arrivent '
        'sous 24h ouvrées.',
  ),
];

const _faqAcheteur = <QuestionFaq>[
  QuestionFaq(
    'Comment passer ma première commande ?',
    'Va dans Marché, choisis une annonce ou poste une demande d\'achat avec '
        'tes critères. Une fois la négociation OK, tu confirmes avec ton '
        'PIN et un transporteur est assigné.',
  ),
  QuestionFaq(
    'Comment sont sécurisés mes paiements ?',
    'Ton paiement est placé en escrow (séquestre) jusqu\'à la livraison '
        'confirmée. Si la livraison échoue, tu es remboursé automatiquement.',
  ),
  QuestionFaq(
    'Que se passe-t-il si la livraison est en retard ?',
    'Tu peux suivre le transporteur en temps réel depuis le détail de la '
        'commande. En cas de retard > 24h, contacte le support pour '
        'déclencher un litige.',
  ),
  QuestionFaq(
    'Puis-je acheter directement à une coopérative ?',
    'Oui — certaines coopératives publient en leur nom. L\'achat se fait de '
        'la même manière, et tu bénéficies souvent d\'une traçabilité '
        'renforcée.',
  ),
  QuestionFaq(
    'Comment annuler une commande ?',
    'Tant que la commande n\'est pas marquée "En route", tu peux annuler '
        'depuis le détail commande. Au-delà, contacte le support.',
  ),
];

const _faqCooperative = <QuestionFaq>[
  QuestionFaq(
    'Comment inviter de nouveaux membres ?',
    'Va dans Membres → Inviter un farmer, saisis son numéro de téléphone et '
        'envoie l\'invitation. Si le farmer n\'a pas de smartphone, utilise '
        '"Enregistrer un farmer géré" pour le créer.',
  ),
  QuestionFaq(
    'Comment fonctionne la distribution automatique ?',
    'Si activée, après chaque vente la coop redistribue automatiquement aux '
        'membres contributeurs selon les parts définies, moins ta commission.',
  ),
  QuestionFaq(
    'Comment publier au nom d\'un farmer géré ?',
    'Lors de la création d\'une annonce, choisis "Publier au nom de" et '
        'sélectionne le farmer. L\'annonce apparaît côté acheteur comme '
        'venant du farmer.',
  ),
  QuestionFaq(
    'Comment verser une avance à un membre ?',
    'Va dans Membres → détail membre → Verser une avance. Le montant est '
        'débité de ton wallet coop et déduit automatiquement de sa prochaine '
        'distribution.',
  ),
  QuestionFaq(
    'Comment gérer le stock dans plusieurs entrepôts ?',
    'Dans l\'onglet Stock, tu peux créer plusieurs entrepôts. Chaque '
        'réception est rattachée à un entrepôt et le transfert entre '
        'entrepôts est possible depuis Logistique.',
  ),
];

const _faqTransporteur = <QuestionFaq>[
  QuestionFaq(
    'Comment recevoir des missions ?',
    'Active ta disponibilité dans ton profil et déclare au moins un '
        'itinéraire actif. Les acheteurs te verront apparaître au moment de '
        'choisir un transporteur.',
  ),
  QuestionFaq(
    'Comment confirmer une prise en charge ?',
    'Quand tu arrives chez le producteur, scanne son QR depuis l\'onglet '
        'Scanner ou depuis le détail mission. La mission passe à "En route".',
  ),
  QuestionFaq(
    'Comment fixer mes tarifs ?',
    'Va dans Profil → Tarif par kg et Tarif minimum. Tu peux aussi définir '
        'des tarifs spécifiques par itinéraire si nécessaire.',
  ),
  QuestionFaq(
    'Quand suis-je payé ?',
    'Une fois la livraison confirmée par le scan du QR acheteur, ton '
        'paiement est libéré immédiatement sur ton wallet. Tu peux retirer '
        'à tout moment.',
  ),
  QuestionFaq(
    'Quels documents pour mon véhicule ?',
    'Carte grise, assurance valide, et permis de conduire correspondant à '
        'la catégorie. Documents à uploader dans Profil → Mes véhicules.',
  ),
];

const _faqGenerique = <QuestionFaq>[
  QuestionFaq(
    'Comment contacter le support ?',
    'Utilise le bouton Chat en haut de cette page, appelle-nous au +225 '
        '07 00 00 00 00 ou écris-nous sur WhatsApp. Réponse sous 24h en '
        'semaine.',
  ),
  QuestionFaq(
    'Comment modifier mes informations ?',
    'Va dans ton Profil et appuie sur "Modifier" en haut de la carte '
        'identité. Certains champs (téléphone, email) nécessitent une '
        'vérification.',
  ),
  QuestionFaq(
    'L\'application est-elle disponible hors-ligne ?',
    'Une grande partie des écrans reste consultable sans réseau. Les '
        'opérations (paiements, publications) nécessitent une connexion '
        'active.',
  ),
];
