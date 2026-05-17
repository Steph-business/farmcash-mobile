import 'package:freezed_annotation/freezed_annotation.dart';

import 'annonce_vente.dart' show mediasToPhotos, photosToMedias;
import 'converters.dart';
import 'enums.dart';
import 'utilisateur.dart';

part 'publication_coop.freezed.dart';
part 'publication_coop.g.dart';

/// Publication agrégée par une coopérative (somme de N annonces de membres).
@freezed
class PublicationCoop with _$PublicationCoop {
  const factory PublicationCoop({
    required String id,
    required String cooperativeId,
    required String produitId,
    required String titre,
    @FlexDouble() required double quantiteKg,
    @FlexDouble() required double prixParKg,
    @JsonKey(unknownEnumValue: ProductQuality.unknown)
    @Default(ProductQuality.unknown)
    ProductQuality qualite,
    String? description,
    @JsonKey(name: 'medias', fromJson: mediasToPhotos, toJson: photosToMedias)
    @Default(<String>[])
    List<String> photos,
    @JsonKey(unknownEnumValue: ProductStatus.unknown)
    @Default(ProductStatus.unknown)
    ProductStatus status,
    @Default(0) int nbContributeurs,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PublicationCoop;

  factory PublicationCoop.fromJson(Map<String, dynamic> json) =>
      _$PublicationCoopFromJson(json);
}

/// Détail d'un contributeur à une publication (pour distribution payout).
@freezed
class CoopContribution with _$CoopContribution {
  const CoopContribution._();

  const factory CoopContribution({
    required String userId,
    required String annonceId,
    @FlexDouble() required double quantiteKg,
    @FlexDouble() required double partPourcent,
    @FlexDouble() required double revenuProjete,
    Utilisateur? user,
  }) = _CoopContribution;

  factory CoopContribution.fromJson(Map<String, dynamic> json) =>
      _$CoopContributionFromJson(json);

  String? get fullName => user?.fullName;
}
