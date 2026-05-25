import '../../../../models/parcelle.dart';
import '../../../../models/produit.dart';

/// Bundle de données pour la page détail parcelle.
///
/// Contient la parcelle elle-même + les cultures associées + le
/// catalogue produit pour résoudre les noms (produitId → Produit).
class ParcelleDetailData {
  final Parcelle? parcelle;
  final List<Culture> cultures;
  final Map<String, Produit> produitsById;

  const ParcelleDetailData({
    required this.parcelle,
    required this.cultures,
    required this.produitsById,
  });
}
