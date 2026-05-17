import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';
import 'enums.dart';

part 'prevision.freezed.dart';
part 'prevision.g.dart';

/// Prévision de production : un farmer annonce une récolte à venir,
/// les acheteurs peuvent réserver une part avec acompte 10%.
@freezed
class Prevision with _$Prevision {
  const factory Prevision({
    required String id,
    required String farmerId,
    required String produitId,
    @FlexDouble() required double quantitePrevKg,
    String? parcelleId,
    DateTime? dateRecoltePrev,
    @FlexDoubleN() double? prixCibleKg,
    @JsonKey(unknownEnumValue: PrevisionStatus.unknown)
    @Default(PrevisionStatus.unknown)
    PrevisionStatus status,
    String? assignedToCooperativeId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Prevision;

  factory Prevision.fromJson(Map<String, dynamic> json) =>
      _$PrevisionFromJson(json);
}
