import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';

part 'buyer_address.freezed.dart';
part 'buyer_address.g.dart';

/// Adresse de livraison enregistrée par un BUYER.
///
/// Le backend renvoie une jointure `villes_ci: { nom }` quand `ville_id`
/// est renseigné : on l'aplatit en `villeNom` pour l'UI.
@freezed
class BuyerAddress with _$BuyerAddress {
  const BuyerAddress._();

  const factory BuyerAddress({
    required String id,
    required String userId,
    required String libelle,
    @Default('') String contactNom,
    @Default('') String contactPhone,
    @Default('') String adresseComplete,
    String? villeId,
    @FlexDoubleN() double? lat,
    @FlexDoubleN() double? lng,
    @Default(false) bool isDefault,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    @JsonKey(
      name: 'villes_ci',
      fromJson: _nomFromMap,
      toJson: _nomToMap,
    )
    String? villeNom,
  }) = _BuyerAddress;

  factory BuyerAddress.fromJson(Map<String, dynamic> json) =>
      _$BuyerAddressFromJson(json);
}

String? _nomFromMap(dynamic raw) {
  if (raw is Map && raw['nom'] is String) return raw['nom'] as String;
  if (raw is String) return raw;
  return null;
}

Map<String, dynamic>? _nomToMap(String? nom) =>
    nom == null ? null : {'nom': nom};
