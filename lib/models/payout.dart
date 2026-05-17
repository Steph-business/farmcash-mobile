import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';
import 'enums.dart';

part 'payout.freezed.dart';
part 'payout.g.dart';

/// Batch de paiements groupés (utilisé par COOP pour payer plusieurs membres).
@freezed
class PayoutBatch with _$PayoutBatch {
  const factory PayoutBatch({
    required String id,
    required String initiatorId,
    @FlexDouble() required double totalAmount,
    @Default('PENDING') String status,
    @Default(<PayoutItem>[]) List<PayoutItem> items,
    DateTime? createdAt,
    DateTime? completedAt,
  }) = _PayoutBatch;

  factory PayoutBatch.fromJson(Map<String, dynamic> json) =>
      _$PayoutBatchFromJson(json);
}

@freezed
class PayoutItem with _$PayoutItem {
  const factory PayoutItem({
    required String id,
    required String batchId,
    required String userId,
    @FlexDouble() required double amount,
    @JsonKey(unknownEnumValue: MobileProvider.unknown)
    @Default(MobileProvider.unknown)
    MobileProvider provider,
    @Default('PENDING') String status,
    String? errorMessage,
  }) = _PayoutItem;

  factory PayoutItem.fromJson(Map<String, dynamic> json) =>
      _$PayoutItemFromJson(json);
}
