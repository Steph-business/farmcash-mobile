/// Vue projetée d'une commande coop éligible à une demande de transport
/// tiers : payée (ACCEPTED / IN_PROGRESS) et sans shipment encore créé.
///
/// Modèle léger sans freezed (un seul producteur, pas de mutation) —
/// parse manuel pour aplatir les jointures Prisma renvoyées par
/// `GET /coop/logistics/transport-requests/eligible`.
class CoopEligibleCommande {
  const CoopEligibleCommande({
    required this.id,
    required this.reference,
    required this.buyerName,
    required this.produitNom,
    required this.quantiteKg,
    required this.deliveryAddress,
    required this.montantTotal,
  });

  final String id;
  final String reference;
  final String buyerName;
  final String produitNom;
  final double quantiteKg;
  final String? deliveryAddress;
  final double montantTotal;

  factory CoopEligibleCommande.fromJson(Map<String, dynamic> json) {
    final buyer =
        json['users_commandes_vente_buyer_idTousers'] as Map<dynamic, dynamic>?;
    final annonce = json['annonces_vente'] as Map<dynamic, dynamic>?;
    final publication =
        json['publications_stock_coop'] as Map<dynamic, dynamic>?;
    final produitFromAnnonce = annonce?['produits_agricoles'] as Map?;
    final produitFromPublication =
        publication?['produits_agricoles'] as Map?;
    return CoopEligibleCommande(
      id: json['id'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      buyerName: (buyer?['full_name'] as String?) ?? 'Acheteur',
      produitNom: (produitFromPublication?['nom'] as String?) ??
          (produitFromAnnonce?['nom'] as String?) ??
          (annonce?['titre'] as String?) ??
          'Produit',
      quantiteKg: _toDouble(json['quantite_kg']),
      deliveryAddress: json['delivery_address'] as String?,
      montantTotal: _toDouble(json['montant_total']),
    );
  }
}

double _toDouble(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}
