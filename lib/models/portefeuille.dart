import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';

part 'portefeuille.freezed.dart';
part 'portefeuille.g.dart';

/// Solde du wallet utilisateur.
@freezed
class Portefeuille with _$Portefeuille {
  const Portefeuille._();

  const factory Portefeuille({
    @Default('') String id,
    @Default('') String userId,
    @Default('XOF') String currency,
    @FlexDouble() @Default(0.0) double balance,
    @FlexDouble() @Default(0.0) double balanceEscrow,
  }) = _Portefeuille;

  factory Portefeuille.fromJson(Map<String, dynamic> json) =>
      _$PortefeuilleFromJson(json);

  double get totalAvailable => balance;
}

/// Moyen de paiement Mobile Money / Wallet enregistré.
@freezed
class MoyenPayement with _$MoyenPayement {
  const factory MoyenPayement({
    required String id,
    required String userId,
    @Default('UNKNOWN') String provider,
    @Default('') String phoneDisplay,
    @Default(false) bool isDefault,
    @Default(true) bool isActive,
    DateTime? createdAt,
  }) = _MoyenPayement;

  factory MoyenPayement.fromJson(Map<String, dynamic> json) =>
      _$MoyenPayementFromJson(json);
}
