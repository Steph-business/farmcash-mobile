import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';

part 'matching.freezed.dart';
part 'matching.g.dart';

/// Opportunité de matching côté PRODUCTEUR (FARMER).
///
/// Une opportunité représente une demande d'achat active publiée par un
/// acheteur dont le produit matche une culture déclarée par le producteur
/// connecté. Retournée par `GET /ai/matching/opportunities`.
@freezed
class MatchingOpportunity with _$MatchingOpportunity {
  const factory MatchingOpportunity({
    @JsonKey(name: 'annonce_id') required String annonceId,
    @JsonKey(name: 'buyer_name') required String buyerName,
    @JsonKey(name: 'produit_nom') required String produitNom,
    @JsonKey(name: 'quantite_kg') @FlexDouble() @Default(0.0) double quantiteKg,
    @JsonKey(name: 'prix_max_kg') @FlexDouble() @Default(0.0) double prixMaxKg,
    @JsonKey(name: 'region_name') String? regionName,
    @JsonKey(name: 'match_score') @FlexInt() @Default(0) int matchScore,
  }) = _MatchingOpportunity;

  factory MatchingOpportunity.fromJson(Map<String, dynamic> json) =>
      _$MatchingOpportunityFromJson(json);
}

/// Producteur potentiel matché côté ACHETEUR / COOPERATIVE.
///
/// Représente un producteur qui pourrait répondre à une demande d'achat
/// précise (matching produit + région + cultures déclarées + annonces
/// actives). Retournée par `GET /ai/matching/suppliers/:annonceId`.
@freezed
class MatchedSupplier with _$MatchedSupplier {
  const factory MatchedSupplier({
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'region_id') String? regionId,
    @JsonKey(name: 'region_name') String? regionName,
    @JsonKey(name: 'distance_km') @FlexDoubleN() double? distanceKm,
    @JsonKey(name: 'has_active_annonce')
    @Default(false)
    bool hasActiveAnnonce,
    @JsonKey(name: 'declared_in_cultures')
    @Default(false)
    bool declaredInCultures,
    @JsonKey(name: 'match_score') @FlexInt() @Default(0) int matchScore,
  }) = _MatchedSupplier;

  factory MatchedSupplier.fromJson(Map<String, dynamic> json) =>
      _$MatchedSupplierFromJson(json);
}
