import 'package:freezed_annotation/freezed_annotation.dart';

import 'annonce_vente.dart' show VendeurApercu;
import 'converters.dart';
import 'enums.dart';

part 'annonce_achat.freezed.dart';
part 'annonce_achat.g.dart';

/// Demande d'achat publiée par un BUYER (cherche des producteurs).
///
/// Comme `AnnonceVente`, le backend joint :
///   - `produits_agricoles` → nom du produit
///   - `users` → buyer (full_name, rating)
///   - `regions_ci` → région
/// On les aplatit en getters pour ne pas multiplier les modèles.
@freezed
class AnnonceAchat with _$AnnonceAchat {
  const AnnonceAchat._();

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

    // ─── Champs joints ────────────────────────────────────────────────
    @JsonKey(
      name: 'produits_agricoles',
      fromJson: _nomFromMap,
      toJson: _nomToMap,
    )
    String? produitNom,
    @JsonKey(
      name: 'users',
      fromJson: _buyerInfoFromJson,
      toJson: _buyerInfoToJson,
    )
    VendeurApercu? buyer,
    @JsonKey(
      name: 'regions_ci',
      fromJson: _nomFromMap,
      toJson: _nomToMap,
    )
    String? regionNom,
  }) = _AnnonceAchat;

  factory AnnonceAchat.fromJson(Map<String, dynamic> json) =>
      _$AnnonceAchatFromJson(json);

  /// Libellé du produit affichable : nom catalogue si dispo, sinon titre.
  String get produitLabel {
    final nom = produitNom?.trim();
    if (nom != null && nom.isNotEmpty) return nom;
    if (titre != null && titre!.trim().isNotEmpty) return titre!;
    return 'Demande';
  }

  /// Nom du buyer (`users.full_name` joint), `null` si non exposé.
  String? get buyerNom => buyer?.fullName;
}

VendeurApercu? _buyerInfoFromJson(dynamic raw) {
  if (raw is! Map) return null;
  final m = raw.cast<String, dynamic>();
  final rating = m['rating'];
  return VendeurApercu(
    id: m['id'] as String?,
    fullName: m['full_name'] as String?,
    rating: rating is num
        ? rating.toDouble()
        : (rating is String ? double.tryParse(rating) : null),
    photoUrl: m['photo_url'] as String?,
  );
}

Map<String, dynamic>? _buyerInfoToJson(VendeurApercu? v) {
  if (v == null) return null;
  return {
    if (v.id != null) 'id': v.id,
    if (v.fullName != null) 'full_name': v.fullName,
    if (v.rating != null) 'rating': v.rating,
    if (v.photoUrl != null) 'photo_url': v.photoUrl,
  };
}

String? _nomFromMap(dynamic raw) {
  if (raw is Map && raw['nom'] is String) return raw['nom'] as String;
  if (raw is String) return raw;
  return null;
}

Map<String, dynamic>? _nomToMap(String? nom) =>
    nom == null ? null : {'nom': nom};
