import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';
import 'enums.dart';

part 'avance_coop.freezed.dart';
part 'avance_coop.g.dart';

/// Avance versée par la COOP au FARMER avant la vente effective.
@freezed
class AvanceCoop with _$AvanceCoop {
  const factory AvanceCoop({
    required String id,
    required String cooperativeId,
    required String farmerId,
    @FlexDouble() required double amount,
    String? annonceVenteId,
    @JsonKey(unknownEnumValue: CoopAdvanceStatus.unknown)
    @Default(CoopAdvanceStatus.unknown)
    CoopAdvanceStatus status,
    String? motif,
    DateTime? paidAt,
    DateTime? reimbursedAt,
    DateTime? createdAt,
  }) = _AvanceCoop;

  factory AvanceCoop.fromJson(Map<String, dynamic> json) =>
      _$AvanceCoopFromJson(json);
}
