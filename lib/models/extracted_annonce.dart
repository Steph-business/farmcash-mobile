import 'enums.dart';

/// Modèle représentant les données extraites d'un média par l'IA
/// pour pré-remplir une annonce de vente.
class ExtractedAnnonce {
  final String? productName;
  final double? quantiteKg;
  final double? prixParKg;
  final ProductQuality? qualite;
  final String? description;
  final DateTime? dateRecolte;
  final List<String>? certifications;
  final List<String>? traitements;

  /// `true` quand ces données viennent de la simulation locale (l'appel
  /// IA a échoué : pas de clé backend, 404, réseau…). Permet à l'UI de
  /// prévenir l'utilisateur que ce ne sont PAS ses vraies paroles.
  final bool isSimulation;

  const ExtractedAnnonce({
    this.productName,
    this.quantiteKg,
    this.prixParKg,
    this.qualite,
    this.description,
    this.dateRecolte,
    this.certifications,
    this.traitements,
    this.isSimulation = false,
  });

  factory ExtractedAnnonce.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['date_recolte'] != null) {
      parsedDate = DateTime.tryParse(json['date_recolte'] as String);
    }

    ProductQuality? parsedQuality;
    if (json['qualite'] != null) {
      final val = json['qualite'] as String;
      parsedQuality = ProductQuality.values.firstWhere(
        (q) => q.apiValue == val || q.name.toLowerCase() == val.toLowerCase(),
        orElse: () => ProductQuality.unknown,
      );
    }

    List<String>? parsedCertifs;
    if (json['certifications'] is List) {
      parsedCertifs = (json['certifications'] as List).map((e) => e.toString()).toList();
    }

    List<String>? parsedTraitements;
    if (json['traitements'] is List) {
      parsedTraitements = (json['traitements'] as List).map((e) => e.toString()).toList();
    }

    return ExtractedAnnonce(
      productName: json['product_name'] as String?,
      quantiteKg: (json['quantite_kg'] as num?)?.toDouble(),
      prixParKg: (json['prix_par_kg'] as num?)?.toDouble(),
      qualite: parsedQuality,
      description: json['description'] as String?,
      dateRecolte: parsedDate,
      certifications: parsedCertifs,
      traitements: parsedTraitements,
    );
  }

  Map<String, dynamic> toJson() => {
        'product_name': productName,
        'quantite_kg': quantiteKg,
        'prix_par_kg': prixParKg,
        'qualite': qualite?.apiValue,
        'description': description,
        'date_recolte': dateRecolte?.toIso8601String().split('T').first,
        'certifications': certifications,
        'traitements': traitements,
      };
}
