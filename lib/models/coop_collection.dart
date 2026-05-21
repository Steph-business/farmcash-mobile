import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';
import 'utilisateur.dart';

part 'coop_collection.freezed.dart';
part 'coop_collection.g.dart';

/// Collecte planifiée par une coop pour aller chercher la marchandise
/// chez un membre. Statuts : PLANNED / IN_PROGRESS / COMPLETED / CANCELLED.
@freezed
class CoopCollection with _$CoopCollection {
  const CoopCollection._();

  const factory CoopCollection({
    required String id,
    required String cooperativeId,
    required String farmerId,
    String? annonceVenteId,
    String? vehicleId,
    DateTime? scheduledAt,
    @Default('') String pickupAddress,
    @FlexDouble() @Default(0) double quantitePrevueKg,
    @Default('PLANNED') String status,
    String? notes,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,

    /// Jointures Prisma (back retourne `users` pour le farmer).
    @JsonKey(name: 'users') Utilisateur? farmer,
  }) = _CoopCollection;

  factory CoopCollection.fromJson(Map<String, dynamic> json) =>
      _$CoopCollectionFromJson(json);

  String? get farmerNom => farmer?.fullName;
}
