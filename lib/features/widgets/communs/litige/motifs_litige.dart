import '../../../../models/enums.dart';

/// Statuts de commande sur lesquels le backend autorise l'ouverture d'un
/// litige (`POST /orders/disputes`). Aligné sur la règle métier serveur :
/// le backend renvoie 400 « Litige impossible sur une commande au statut
/// XXX » pour tout autre statut.
///
/// Concrètement, un litige n'a de sens que quand quelque chose peut mal
/// se passer :
/// - `inProgress` : le transporteur est en route → retard, perte, casse
/// - `delivered` : livraison faite → contestation conformité, quantité
///
/// Sur `sent` / `accepted` : la commande vient d'être passée, on laisse
/// le vendeur le temps d'agir. Sur `completed` : l'acheteur a déjà
/// confirmé, le contrat est clos.
bool peutOuvrirLitige(OrderStatus status) {
  return status == OrderStatus.inProgress ||
      status == OrderStatus.delivered;
}

/// Un motif prédéfini pour ouvrir un litige.
///
/// Le `code` est une clé technique stable (envoyée au backend en début
/// de raison) ; le `label` est ce qui est affiché à l'utilisateur.
class MotifLitige {
  /// Construit un motif.
  const MotifLitige({required this.code, required this.label});

  /// Code technique stable (ex: `seller_no_response`).
  final String code;

  /// Libellé court affiché dans la radio liste.
  final String label;

  /// Cas spécial "Autre" — au lieu d'envoyer un code prédéfini, on
  /// envoie le texte saisi par l'utilisateur.
  static const autre = MotifLitige(code: 'other', label: 'Autre');
}

/// Catalogue de motifs adapté au rôle. Les libellés sont volontairement
/// formulés en français naturel pour ne pas effrayer l'utilisateur
/// low-tech.
///
/// Le rôle observé est celui qui ouvre le litige (acheteur ou vendeur).
/// Les coopératives utilisent le catalogue vendeur — elles vendent aussi
/// directement. Les transporteurs ne peuvent pas ouvrir de litige côté
/// mobile pour V1.
List<MotifLitige> motifsPourRole(UserRole? role) {
  switch (role) {
    case UserRole.buyer:
      return const [
        MotifLitige(
          code: 'seller_no_response',
          label: 'Le vendeur ne répond pas',
        ),
        MotifLitige(
          code: 'product_not_conform',
          label: 'Le produit reçu n\'est pas conforme',
        ),
        MotifLitige(
          code: 'wrong_quantity',
          label: 'La quantité reçue est incorrecte',
        ),
        MotifLitige(
          code: 'product_damaged',
          label: 'Le produit est endommagé',
        ),
        MotifLitige(
          code: 'late_delivery',
          label: 'Retard important de livraison',
        ),
        MotifLitige(
          code: 'no_transporter',
          label: 'Le transporteur ne vient pas',
        ),
        MotifLitige.autre,
      ];
    case UserRole.farmer:
    case UserRole.cooperative:
      return const [
        MotifLitige(
          code: 'buyer_no_response',
          label: 'L\'acheteur ne répond pas',
        ),
        MotifLitige(
          code: 'buyer_refuses_delivery',
          label: 'L\'acheteur refuse la livraison',
        ),
        MotifLitige(
          code: 'price_disagreement',
          label: 'Désaccord sur le prix après livraison',
        ),
        MotifLitige(
          code: 'transporter_no_pickup',
          label: 'Le transporteur n\'est pas venu chercher',
        ),
        MotifLitige(
          code: 'payment_not_released',
          label: 'Mon paiement n\'a pas été libéré',
        ),
        MotifLitige.autre,
      ];
    default:
      return const [MotifLitige.autre];
  }
}
