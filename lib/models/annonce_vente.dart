import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';
import 'enums.dart';

part 'annonce_vente.freezed.dart';
part 'annonce_vente.g.dart';

/// Annonce de vente publiée par un FARMER (ou agrégée par une COOP).
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
    @JsonKey(unknownEnumValue: ProductQuality.unknown)
    @Default(ProductQuality.unknown)
    ProductQuality qualite,
    String? description,
    @Default(<String>[]) List<String> certifications,
    String? regionId,
    String? villeId,
    @JsonKey(unknownEnumValue: ProductStatus.unknown)
    @Default(ProductStatus.unknown)
    ProductStatus status,
    @FlexInt() @Default(0) int viewsCount,
    String? assignedToCooperativeId,
    @JsonKey(unknownEnumValue: CoopAnnonceStatus.unknown)
    CoopAnnonceStatus? coopStatus,
    /// Le backend renvoie les photos dans la table `medias` jointe :
    /// `medias: [{url, thumbnail_url}]`. On extrait l'URL utilisable et on
    /// retombe sur un `photos: [...]` plat utilisé par les widgets.
    /// Le `toJson` réémet `medias: [{url}]` pour rester symétrique côté API.
    @JsonKey(name: 'medias', fromJson: mediasToPhotos, toJson: photosToMedias)
    @Default(<String>[])
    List<String> photos,
    DateTime? dateRecolte,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AnnonceVente;

  factory AnnonceVente.fromJson(Map<String, dynamic> json) =>
      _$AnnonceVenteFromJson(json);

  double get montantTotal => quantiteKg * prixParKg;
}

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
