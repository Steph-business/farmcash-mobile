import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';
import 'enums.dart';

part 'annonce_vente.freezed.dart';
part 'annonce_vente.g.dart';

/// Annonce de vente publiée par un FARMER (ou agrégée par une COOP).
///
/// Le backend renvoie l'objet enrichi avec des relations Prisma jointes :
///   - `produits_agricoles` → nom du produit
///   - `users` → vendeur (full_name, rating, photo_url)
///   - `regions_ci`, `villes_ci` → localisation lisible
///   - `medias` → photos
///
/// Côté Dart on aplatie ces objets en getters simples (`produitNom`,
/// `vendeurNom`, …) pour ne pas dupliquer les modèles côté UI.
@freezed
class AnnonceVente with _$AnnonceVente {
  const AnnonceVente._();

  const factory AnnonceVente({
    required String id,
    required String farmerId,
    required String produitId,
    required String titre,
    @FlexDouble() required double quantiteKg,
    @FlexDouble() required double prixParKg,
    @FlexDoubleN() double? quantiteMinKg,
    @JsonKey(unknownEnumValue: ProductQuality.unknown)
    @Default(ProductQuality.unknown)
    ProductQuality qualite,
    String? description,
    @Default(<String>[]) List<String> certifications,
    String? regionId,
    String? villeId,
    String? adresseDetail,
    @JsonKey(unknownEnumValue: ProductStatus.unknown)
    @Default(ProductStatus.unknown)
    ProductStatus status,
    @FlexInt() @Default(0) int viewsCount,
    String? assignedToCooperativeId,
    @JsonKey(unknownEnumValue: CoopAnnonceStatus.unknown)
    CoopAnnonceStatus? coopStatus,
    /// Motif renseigné par la coopérative quand elle a refusé cette
    /// annonce (`coopStatus == REJECTED`). Renvoyé tel quel par Prisma
    /// dans la colonne `rejected_reason` — d'où le `@JsonKey(name:...)`.
    /// Affiché au producteur dans une bannière rouge soft pour qu'il
    /// sache quoi corriger avant de re-publier.
    @JsonKey(name: 'rejected_reason') String? rejectedReason,

    /// Quantité réellement pesée par la coop lors de la validation
    /// (vs `quantiteKg` qui est la quantité déclarée par le producteur).
    /// Utilisée pour les calculs d'agrégation publication et de
    /// rémunération. Renseignée dès `coopStatus == VALIDATED`.
    @JsonKey(name: 'quantite_kg_validee')
    @FlexDoubleN()
    double? quantiteKgValidee,

    /// Qualité réellement constatée par la coop à la pesée. Peut différer
    /// de la qualité déclarée (sur-classement ou sous-classement après
    /// contrôle visuel). Renseignée dès `coopStatus == VALIDATED`.
    @JsonKey(name: 'qualite_validee', unknownEnumValue: ProductQuality.unknown)
    ProductQuality? qualiteValidee,
    /// Le backend renvoie les photos dans la table `medias` jointe :
    /// `medias: [{url, thumbnail_url}]`. On extrait l'URL utilisable et on
    /// retombe sur un `photos: [...]` plat utilisé par les widgets.
    /// Le `toJson` réémet `medias: [{url}]` pour rester symétrique côté API.
    @JsonKey(name: 'medias', fromJson: mediasToPhotos, toJson: photosToMedias)
    @Default(<String>[])
    List<String> photos,
    DateTime? disponibleJusqu,
    /// Date à laquelle le produit a été récolté — info de fraîcheur affichée
    /// aux acheteurs. Distincte de `disponibleJusqu` (durée de validité de
    /// l'offre côté producteur). Optionnelle.
    DateTime? dateRecolte,
    DateTime? createdAt,
    DateTime? updatedAt,

    // ─── Champs joints (relations Prisma) ──────────────────────────────
    @JsonKey(
      name: 'produits_agricoles',
      fromJson: _nomFromMap,
      toJson: _nomToMap,
    )
    String? produitNom,
    @JsonKey(
      name: 'users',
      fromJson: _vendeurInfoFromJson,
      toJson: _vendeurInfoToJson,
    )
    VendeurApercu? vendeur,
    @JsonKey(
      name: 'regions_ci',
      fromJson: _nomFromMap,
      toJson: _nomToMap,
    )
    String? regionNom,
    @JsonKey(
      name: 'villes_ci',
      fromJson: _nomFromMap,
      toJson: _nomToMap,
    )
    String? villeNom,

    /// Traitements appliqués à la culture (relation jointe par le backend
    /// via `include: { annonce_vente_traitements: { include: { produits_traitement } } }`).
    /// Permet d'exposer la traçabilité "from-farm-to-fork" : type, dosage,
    /// date d'application, délai de carence. Vide si le producteur n'a
    /// rien déclaré.
    @JsonKey(
      name: 'annonce_vente_traitements',
      fromJson: _traitementsFromJson,
      toJson: _traitementsToJson,
    )
    @Default(<AnnonceTraitement>[])
    List<AnnonceTraitement> traitements,
  }) = _AnnonceVente;

  factory AnnonceVente.fromJson(Map<String, dynamic> json) =>
      _$AnnonceVenteFromJson(json);

  double get montantTotal => quantiteKg * prixParKg;

  /// Libellé du produit le plus parlant : le `nom` du produit catalogue
  /// si dispo, sinon le `titre` libre de l'annonce.
  String get produitLabel {
    final nom = produitNom?.trim();
    if (nom != null && nom.isNotEmpty) return nom;
    return titre;
  }

  /// Nom du vendeur affichable (full_name côté back). Renvoie `null` si
  /// l'API ne l'a pas joint (cas des endpoints publics filtrés).
  String? get vendeurNom => vendeur?.fullName;

  /// Localisation lisible : "Ville · Région" si on a les deux, sinon le
  /// libellé disponible. Renvoie `null` si rien n'est exploitable.
  String? get localisationLabel {
    final v = villeNom?.trim();
    final r = regionNom?.trim();
    if (v != null && v.isNotEmpty && r != null && r.isNotEmpty) {
      return '$v · $r';
    }
    return (v != null && v.isNotEmpty) ? v : (r?.isNotEmpty == true ? r : null);
  }
}

/// Infos minimales sur le vendeur joint à une annonce.
///
/// Renseigné par le backend uniquement quand l'endpoint expose la relation
/// `users`. Côté détail on a aussi `id` et `photoUrl`.
class VendeurApercu {
  const VendeurApercu({
    this.id,
    this.fullName,
    this.rating,
    this.photoUrl,
    this.reliabilityScore,
  });

  final String? id;
  final String? fullName;
  final double? rating;
  final String? photoUrl;
  /// Score de fiabilité 0-100 du farmer (affiché en % sur les cards
  /// marketplace pour que les acheteurs jaugent la confiance avant
  /// d'acheter / réserver). `null` si le backend ne l'a pas joint.
  final int? reliabilityScore;
}

VendeurApercu? _vendeurInfoFromJson(dynamic raw) {
  if (raw is! Map) return null;
  final m = raw.cast<String, dynamic>();
  final rating = m['rating'];
  final score = m['reliability_score'];
  return VendeurApercu(
    id: m['id'] as String?,
    fullName: m['full_name'] as String?,
    rating: rating is num
        ? rating.toDouble()
        : (rating is String ? double.tryParse(rating) : null),
    photoUrl: m['photo_url'] as String?,
    reliabilityScore: score is num
        ? score.toInt()
        : (score is String ? int.tryParse(score) : null),
  );
}

Map<String, dynamic>? _vendeurInfoToJson(VendeurApercu? v) {
  if (v == null) return null;
  return {
    if (v.id != null) 'id': v.id,
    if (v.fullName != null) 'full_name': v.fullName,
    if (v.rating != null) 'rating': v.rating,
    if (v.reliabilityScore != null) 'reliability_score': v.reliabilityScore,
    if (v.photoUrl != null) 'photo_url': v.photoUrl,
  };
}

/// Pour les relations Prisma renvoyées avec seulement `{ nom: ... }`.
String? _nomFromMap(dynamic raw) {
  if (raw is Map && raw['nom'] is String) return raw['nom'] as String;
  if (raw is String) return raw;
  return null;
}

Map<String, dynamic>? _nomToMap(String? nom) =>
    nom == null ? null : {'nom': nom};

/// Convertit `medias: [{url, thumbnail_url}]` (forme back) **ou**
/// `photos: ["url", ...]` (forme legacy / tests) en `List<String>`.
List<String> mediasToPhotos(dynamic raw) {
  if (raw is! List) return const <String>[];
  return raw
      .map<String?>((e) {
        if (e is String) return e;
        if (e is Map) {
          final v = e['url'] ?? e['thumbnail_url'];
          return v?.toString();
        }
        return null;
      })
      .whereType<String>()
      .toList(growable: false);
}

/// Sérialise une liste d'URLs vers la forme `medias: [{url}]` attendue
/// par l'API. Utilisé uniquement si on renvoie l'objet au backend.
List<Map<String, String>> photosToMedias(List<String> photos) =>
    photos.map((u) => {'url': u}).toList(growable: false);

/// Traitement appliqué à la culture de l'annonce (engrais, pesticide, bio…).
///
/// Renseigné en option par le producteur via le module IA `produits_traitement`.
/// Permet à l'acheteur de voir l'historique phytosanitaire avant de commander
/// — argument de vente premium "from-farm-to-fork".
class AnnonceTraitement {
  const AnnonceTraitement({
    this.produitTraitementNom,
    this.type,
    this.dosageUtilise,
    this.dateApplication,
    this.delaiCarenceRespecte,
    this.notes,
  });

  /// Nom du produit appliqué (depuis `produits_traitement.nom`).
  final String? produitTraitementNom;

  /// Catégorie du produit : `BIO`, `CHIMIQUE`, `NATUREL`, … (libre côté back).
  final String? type;

  /// Dosage utilisé (texte libre, ex: "2 L/ha").
  final String? dosageUtilise;

  /// Date d'application du traitement.
  final DateTime? dateApplication;

  /// `true` si le délai de carence (= temps minimum avant récolte) a bien
  /// été respecté. Drapeau de confiance pour l'acheteur.
  final bool? delaiCarenceRespecte;

  /// Notes libres du producteur sur l'application.
  final String? notes;
}

/// Parse la liste `annonce_vente_traitements` renvoyée par le backend en
/// `List<AnnonceTraitement>`. Chaque entrée contient les colonnes de la
/// jointure + la relation `produits_traitement: { nom, type, … }`.
List<AnnonceTraitement> _traitementsFromJson(dynamic raw) {
  if (raw is! List) return const <AnnonceTraitement>[];
  return raw
      .whereType<Map>()
      .map<AnnonceTraitement>((entry) {
        final m = entry.cast<String, dynamic>();
        final produit = m['produits_traitement'];
        String? nom;
        String? type;
        if (produit is Map) {
          final p = produit.cast<String, dynamic>();
          nom = p['nom'] as String?;
          type = p['type'] as String?;
        }
        final date = m['date_application'];
        DateTime? parsedDate;
        if (date is String && date.isNotEmpty) {
          parsedDate = DateTime.tryParse(date);
        }
        return AnnonceTraitement(
          produitTraitementNom: nom,
          type: type,
          dosageUtilise: m['dosage_utilise'] as String?,
          dateApplication: parsedDate,
          delaiCarenceRespecte: m['delai_carence_respecte'] as bool?,
          notes: m['notes'] as String?,
        );
      })
      .toList(growable: false);
}

/// Symétrique de `_traitementsFromJson` : utilisé seulement quand on
/// renvoie un `AnnonceVente` au backend (cas rare côté mobile).
List<Map<String, dynamic>> _traitementsToJson(List<AnnonceTraitement> ts) {
  return ts
      .map<Map<String, dynamic>>((t) => {
            if (t.dosageUtilise != null) 'dosage_utilise': t.dosageUtilise,
            if (t.dateApplication != null)
              'date_application': t.dateApplication!.toIso8601String(),
            if (t.delaiCarenceRespecte != null)
              'delai_carence_respecte': t.delaiCarenceRespecte,
            if (t.notes != null) 'notes': t.notes,
            if (t.produitTraitementNom != null || t.type != null)
              'produits_traitement': {
                if (t.produitTraitementNom != null)
                  'nom': t.produitTraitementNom,
                if (t.type != null) 'type': t.type,
              },
          })
      .toList(growable: false);
}
