import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';
import 'enums.dart';

part 'negociation.freezed.dart';
part 'negociation.g.dart';

/// Offre d'un BUYER sur une annonce de vente.
@freezed
class Candidature with _$Candidature {
  const factory Candidature({
    required String id,
    required String annonceId,
    required String buyerId,
    @FlexDouble() required double quantiteKg,
    @FlexDouble() required double prixProposeKg,
    @JsonKey(unknownEnumValue: NegotiationStatus.unknown)
    @Default(NegotiationStatus.unknown)
    NegotiationStatus status,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Candidature;

  factory Candidature.fromJson(Map<String, dynamic> json) =>
      _$CandidatureFromJson(json);
}

/// Proposition d'un FARMER/COOP sur une annonce d'achat.
@freezed
class Proposition with _$Proposition {
  const factory Proposition({
    required String id,
    required String annonceAchatId,
    required String vendeurId,
    @FlexDouble() required double quantiteKg,
    @FlexDouble() required double prixProposeKg,
    @JsonKey(unknownEnumValue: NegotiationStatus.unknown)
    @Default(NegotiationStatus.unknown)
    NegotiationStatus status,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Proposition;

  factory Proposition.fromJson(Map<String, dynamic> json) =>
      _$PropositionFromJson(json);
}

/// Contre-offre BUYER sur une publication coop.
@freezed
class ContreOffreCoop with _$ContreOffreCoop {
  const factory ContreOffreCoop({
    required String id,
    required String publicationCoopId,
    required String buyerId,
    @FlexDouble() required double quantiteKg,
    @FlexDouble() required double prixProposeKg,
    @JsonKey(unknownEnumValue: NegotiationStatus.unknown)
    @Default(NegotiationStatus.unknown)
    NegotiationStatus status,
    String? message,
    DateTime? createdAt,
  }) = _ContreOffreCoop;

  factory ContreOffreCoop.fromJson(Map<String, dynamic> json) =>
      _$ContreOffreCoopFromJson(json);
}
