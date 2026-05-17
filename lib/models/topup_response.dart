import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';

part 'topup_response.freezed.dart';
part 'topup_response.g.dart';

/// Réponse de POST /finance/wallet/topup (ou GET /topup/:txId pour polling).
///
/// `status` ∈ {PENDING, SUCCESS, FAILED}. `newBalance` est présent
/// uniquement quand le provider crédite synchroniquement (status=SUCCESS).
/// Sinon, le wallet sera créditée par le webhook provider et le client
/// doit poller via /wallet/topup/:transactionId.
@freezed
class TopupWalletResponse with _$TopupWalletResponse {
  const factory TopupWalletResponse({
    @JsonKey(name: 'transaction_id') required String transactionId,
    required String status,
    @JsonKey(name: 'provider_ref') String? providerRef,
    @JsonKey(name: 'new_balance') @FlexDoubleN() double? newBalance,
  }) = _TopupWalletResponse;

  factory TopupWalletResponse.fromJson(Map<String, dynamic> json) =>
      _$TopupWalletResponseFromJson(json);
}
