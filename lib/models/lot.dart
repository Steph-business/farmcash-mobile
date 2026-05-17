import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';
import 'enums.dart';

part 'lot.freezed.dart';
part 'lot.g.dart';

@freezed
class Lot with _$Lot {
  const factory Lot({
    required String id,
    required String lotCode,
    @Default('INDIVIDUAL') String type,
    required String produitId,
    @FlexDouble() required double quantiteKg,
    String? farmerId,
    String? cooperativeId,
    @JsonKey(unknownEnumValue: ProductQuality.unknown)
    @Default(ProductQuality.unknown)
    ProductQuality qualite,
    DateTime? dateRecolte,
    String? blockchainTx,
    DateTime? createdAt,
  }) = _Lot;

  factory Lot.fromJson(Map<String, dynamic> json) => _$LotFromJson(json);
}

@freezed
class Entrepot with _$Entrepot {
  const factory Entrepot({
    required String id,
    required String ownerId,
    required String nom,
    @FlexDouble() required double capaciteKg,
    String? location,
    @FlexDoubleN() double? lat,
    @FlexDoubleN() double? lng,
    @Default(false) bool isRefrigere,
    @FlexDoubleN() double? temperatureMin,
    @FlexDoubleN() double? temperatureMax,
    DateTime? createdAt,
  }) = _Entrepot;

  factory Entrepot.fromJson(Map<String, dynamic> json) =>
      _$EntrepotFromJson(json);
}

/// Événement de traçabilité publique d'un lot (scan QR).
@freezed
class TraceabilityEvent with _$TraceabilityEvent {
  const factory TraceabilityEvent({
    required String id,
    required String lotId,
    required String eventType,
    String? actorId,
    String? location,
    Map<String, dynamic>? metadata,
    String? blockchainTx,
    DateTime? createdAt,
  }) = _TraceabilityEvent;

  factory TraceabilityEvent.fromJson(Map<String, dynamic> json) =>
      _$TraceabilityEventFromJson(json);
}
