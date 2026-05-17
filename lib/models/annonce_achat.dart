import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';
import 'enums.dart';

part 'annonce_achat.freezed.dart';
part 'annonce_achat.g.dart';

/// Demande d'achat publiée par un BUYER (cherche des producteurs).
@freezed
class AnnonceAchat with _$AnnonceAchat {
  const factory AnnonceAchat({
    required String id,
    required String buyerId,
    required String produitId,
    @FlexDouble() required double quantiteKg,
    @FlexDouble() required double prixMaxKg,
    String? regionId,
    String? villeId,
    String? titre,
    String? description,
    /// Le backend renvoie `is_active` (bool), pas un statut enum.
    /// Une demande est "active" si l'acheteur cherche encore (≠ archivée).
    @Default(true) bool isActive,
    @JsonKey(name: 'target_audience', unknownEnumValue: BuyOfferAudience.unknown)
    @Default(BuyOfferAudience.unknown)
    BuyOfferAudience audience,
    String? targetCooperativeId,
    DateTime? dateLimiteLivraison,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AnnonceAchat;

  factory AnnonceAchat.fromJson(Map<String, dynamic> json) =>
      _$AnnonceAchatFromJson(json);
}
