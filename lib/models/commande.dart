import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';
import 'enums.dart';

part 'commande.freezed.dart';
part 'commande.g.dart';

/// Commande passée par un BUYER sur une annonce de vente.
@freezed
class Commande with _$Commande {
  const factory Commande({
    required String id,
    @Default('') String reference,
    required String buyerId,
    required String sellerId,
    required String annonceId,
    @FlexDouble() required double quantiteKg,
    @FlexDouble() required double prixUnitaireKg,
    @FlexDouble() required double montantTotal,
    @JsonKey(unknownEnumValue: OrderStatus.unknown)
    @Default(OrderStatus.unknown)
    OrderStatus status,
    @JsonKey(unknownEnumValue: MobileProvider.unknown)
    MobileProvider? paymentProvider,
    @Default(false) bool escrowReleased,
    String? livraisonAdresse,
    DateTime? livraisonDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Commande;

  factory Commande.fromJson(Map<String, dynamic> json) =>
      _$CommandeFromJson(json);
}

/// Litige ouvert sur une commande.
@freezed
class Dispute with _$Dispute {
  const factory Dispute({
    required String id,
    required String commandeId,
    required String openedById,
    @Default('OPEN') String status,
    String? motif,
    String? description,
    String? resolution,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) = _Dispute;

  factory Dispute.fromJson(Map<String, dynamic> json) =>
      _$DisputeFromJson(json);
}
