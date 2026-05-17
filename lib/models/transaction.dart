import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';
import 'enums.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required String userId,
    @Default('UNKNOWN') String type,
    @FlexDouble() required double montant,
    @Default('PENDING') String status,
    String? commandeId,
    @FlexDoubleN() double? balanceAvant,
    @FlexDoubleN() double? balanceApres,
    @JsonKey(unknownEnumValue: MobileProvider.unknown)
    MobileProvider? provider,
    String? reference,
    String? description,
    DateTime? createdAt,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}
