import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';
import 'enums.dart';

part 'commande.freezed.dart';
part 'commande.g.dart';

/// Commande passée par un BUYER. Issue de l'une des 3 sources backend
/// (cf. contrainte `chk_commande_source`) :
///   • `annonceId` : achat sur une annonce de vente publique
///   • `annonceAchatId` : commande issue d'une proposition acceptée
///     (le vendeur a répondu à une demande d'achat)
///   • `publicationCoopId` : achat direct sur publication coop
/// Au moins l'un de ces 3 IDs est rempli, les autres peuvent être null
/// — donc tous nullable côté modèle.
@freezed
class Commande with _$Commande {
  const factory Commande({
    required String id,
    @Default('') String reference,
    required String buyerId,
    required String sellerId,
    String? annonceId,
    String? annonceAchatId,
    String? publicationCoopId,
    /// Identifiant du lot physique livré (rempli quand le vendeur lie la
    /// commande à un lot tracé). Sert à charger la traçabilité publique
    /// `/ai/traceability/:lotId` côté acheteur.
    String? lotId,
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
    // ─── Champs joints (depuis getOrderById backend) ──────────────────
    // Le backend renvoie le buyer/seller via `include:` Prisma. On les
    // aplatit ici en fields plats lisibles directement par l'UI. `null`
    // si la jointure n'a pas été demandée (ex. ancien endpoint list).
    @JsonKey(readValue: _readBuyerName) String? buyerName,
    @JsonKey(readValue: _readBuyerPhoto) String? buyerPhotoUrl,
    @JsonKey(readValue: _readSellerName) String? sellerName,
    @JsonKey(readValue: _readSellerPhoto) String? sellerPhotoUrl,
  }) = _Commande;

  factory Commande.fromJson(Map<String, dynamic> json) =>
      _$CommandeFromJson(json);
}

// ─── Helpers extraction joints users ─────────────────────────────────

Object? _readBuyerName(Map<dynamic, dynamic> json, String key) {
  final u = json['users_commandes_vente_buyer_idTousers'];
  return u is Map ? u['full_name'] : null;
}

Object? _readBuyerPhoto(Map<dynamic, dynamic> json, String key) {
  final u = json['users_commandes_vente_buyer_idTousers'];
  return u is Map ? u['photo_url'] : null;
}

Object? _readSellerName(Map<dynamic, dynamic> json, String key) {
  final u = json['users_commandes_vente_seller_idTousers'];
  return u is Map ? u['full_name'] : null;
}

Object? _readSellerPhoto(Map<dynamic, dynamic> json, String key) {
  final u = json['users_commandes_vente_seller_idTousers'];
  return u is Map ? u['photo_url'] : null;
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
