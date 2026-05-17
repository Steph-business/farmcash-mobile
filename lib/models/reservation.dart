import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';

part 'reservation.freezed.dart';
part 'reservation.g.dart';

/// Réservation de quantité sur une prévision de production.
@freezed
class Reservation with _$Reservation {
  const factory Reservation({
    required String id,
    required String previsionId,
    required String acheteurId,
    @FlexDouble() required double quantiteKg,
    @FlexDouble() required double depositAmount,
    @Default('PENDING') String status,
    DateTime? createdAt,
  }) = _Reservation;

  factory Reservation.fromJson(Map<String, dynamic> json) =>
      _$ReservationFromJson(json);
}
