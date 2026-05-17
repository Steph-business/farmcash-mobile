import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';

part 'parcelle.freezed.dart';
part 'parcelle.g.dart';

@freezed
class Parcelle with _$Parcelle {
  const factory Parcelle({
    required String id,
    required String userId,
    required String nom,
    @FlexDoubleN() double? superficieHa,
    String? produitId,
    @Default(<GeoPoint>[]) List<GeoPoint> contour,
    DateTime? createdAt,
  }) = _Parcelle;

  factory Parcelle.fromJson(Map<String, dynamic> json) =>
      _$ParcelleFromJson(json);
}

@freezed
class GeoPoint with _$GeoPoint {
  const factory GeoPoint({
    @FlexDouble() required double lat,
    @FlexDouble() required double lng,
  }) = _GeoPoint;

  factory GeoPoint.fromJson(Map<String, dynamic> json) =>
      _$GeoPointFromJson(json);
}

@freezed
class Culture with _$Culture {
  const Culture._();

  const factory Culture({
    required String id,
    /// Nullable côté DB (peuvent exister des cultures historiques sans
    /// parcelle), même si toutes les nouvelles cultures en auront une.
    String? parcelleId,
    required String produitId,
    @FlexDoubleN() double? superficieHa,
    DateTime? dateSemis,
    DateTime? dateRecoltePrevue,
    @FlexDoubleN() double? quantiteEstimeeKg,
    String? statut,
    DateTime? createdAt,
    /// Le back renvoie `produits_agricoles: { nom: "Maïs grain blanc" }`.
    /// On aplatit via le converter pour exposer `produitNom` directement.
    @JsonKey(name: 'produits_agricoles', fromJson: _produitNomFromMap)
    String? produitNom,
  }) = _Culture;

  factory Culture.fromJson(Map<String, dynamic> json) =>
      _$CultureFromJson(json);
}

String? _produitNomFromMap(dynamic raw) {
  if (raw is Map && raw['nom'] is String) return raw['nom'] as String;
  return null;
}
