import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';

part 'vehicle.freezed.dart';
part 'vehicle.g.dart';

/// Véhicule de transport déclaré par un TRANSPORTER.
@freezed
class Vehicle with _$Vehicle {
  const factory Vehicle({
    required String id,
    required String transporterId,
    @Default('') String type,
    String? immatriculation,
    String? marque,
    @FlexDouble() @Default(0) double chargeMaxKg,
    @FlexDoubleN() double? volumeM3,
    String? photoUrl,
    @Default(true) bool isActive,
    DateTime? createdAt,
  }) = _Vehicle;

  factory Vehicle.fromJson(Map<String, dynamic> json) =>
      _$VehicleFromJson(json);
}
