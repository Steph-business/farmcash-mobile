import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';

part 'coop_vehicle.freezed.dart';
part 'coop_vehicle.g.dart';

/// Véhicule du parc d'une coopérative.
@freezed
class CoopVehicle with _$CoopVehicle {
  const factory CoopVehicle({
    required String id,
    required String cooperativeId,
    @Default('') String type,
    String? immatriculation,
    String? marque,
    @FlexDouble() @Default(0) double chargeMaxKg,
    String? chauffeurNom,
    String? chauffeurPhone,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CoopVehicle;

  factory CoopVehicle.fromJson(Map<String, dynamic> json) =>
      _$CoopVehicleFromJson(json);
}
