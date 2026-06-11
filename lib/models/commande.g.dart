// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commande.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommandeImpl _$$CommandeImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$CommandeImpl',
      json,
      ($checkedConvert) {
        final val = _$CommandeImpl(
          id: $checkedConvert('id', (v) => v as String),
          reference: $checkedConvert('reference', (v) => v as String? ?? ''),
          buyerId: $checkedConvert('buyer_id', (v) => v as String),
          sellerId: $checkedConvert('seller_id', (v) => v as String),
          annonceId: $checkedConvert('annonce_id', (v) => v as String?),
          annonceAchatId: $checkedConvert(
            'annonce_achat_id',
            (v) => v as String?,
          ),
          publicationCoopId: $checkedConvert(
            'publication_coop_id',
            (v) => v as String?,
          ),
          lotId: $checkedConvert('lot_id', (v) => v as String?),
          quantiteKg: $checkedConvert(
            'quantite_kg',
            (v) => const FlexDouble().fromJson(v),
          ),
          prixUnitaireKg: $checkedConvert(
            'prix_unitaire_kg',
            (v) => const FlexDouble().fromJson(v),
          ),
          montantTotal: $checkedConvert(
            'montant_total',
            (v) => const FlexDouble().fromJson(v),
          ),
          status: $checkedConvert(
            'status',
            (v) =>
                $enumDecodeNullable(
                  _$OrderStatusEnumMap,
                  v,
                  unknownValue: OrderStatus.unknown,
                ) ??
                OrderStatus.unknown,
          ),
          paymentProvider: $checkedConvert(
            'payment_provider',
            (v) => $enumDecodeNullable(
              _$MobileProviderEnumMap,
              v,
              unknownValue: MobileProvider.unknown,
            ),
          ),
          escrowReleased: $checkedConvert(
            'escrow_released',
            (v) => v as bool? ?? false,
          ),
          livraisonAdresse: $checkedConvert(
            'livraison_adresse',
            (v) => v as String?,
          ),
          livraisonDate: $checkedConvert(
            'livraison_date',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          createdAt: $checkedConvert(
            'created_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          updatedAt: $checkedConvert(
            'updated_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          paymentMode: $checkedConvert(
            'payment_mode',
            (v) => v as String? ?? 'FULL',
          ),
          depositAmount: $checkedConvert(
            'deposit_amount',
            (v) => const FlexDoubleN().fromJson(v),
          ),
          depositPaidAt: $checkedConvert(
            'deposit_paid_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          balancePaidAt: $checkedConvert(
            'balance_paid_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          cashCollectedAt: $checkedConvert(
            'cash_collected_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          buyerName: $checkedConvert(
            'buyer_name',
            (v) => v as String?,
            readValue: _readBuyerName,
          ),
          buyerPhotoUrl: $checkedConvert(
            'buyer_photo_url',
            (v) => v as String?,
            readValue: _readBuyerPhoto,
          ),
          sellerName: $checkedConvert(
            'seller_name',
            (v) => v as String?,
            readValue: _readSellerName,
          ),
          sellerPhotoUrl: $checkedConvert(
            'seller_photo_url',
            (v) => v as String?,
            readValue: _readSellerPhoto,
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'buyerId': 'buyer_id',
        'sellerId': 'seller_id',
        'annonceId': 'annonce_id',
        'annonceAchatId': 'annonce_achat_id',
        'publicationCoopId': 'publication_coop_id',
        'lotId': 'lot_id',
        'quantiteKg': 'quantite_kg',
        'prixUnitaireKg': 'prix_unitaire_kg',
        'montantTotal': 'montant_total',
        'paymentProvider': 'payment_provider',
        'escrowReleased': 'escrow_released',
        'livraisonAdresse': 'livraison_adresse',
        'livraisonDate': 'livraison_date',
        'createdAt': 'created_at',
        'updatedAt': 'updated_at',
        'paymentMode': 'payment_mode',
        'depositAmount': 'deposit_amount',
        'depositPaidAt': 'deposit_paid_at',
        'balancePaidAt': 'balance_paid_at',
        'cashCollectedAt': 'cash_collected_at',
        'buyerName': 'buyer_name',
        'buyerPhotoUrl': 'buyer_photo_url',
        'sellerName': 'seller_name',
        'sellerPhotoUrl': 'seller_photo_url',
      },
    );

Map<String, dynamic> _$$CommandeImplToJson(
  _$CommandeImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'reference': instance.reference,
  'buyer_id': instance.buyerId,
  'seller_id': instance.sellerId,
  if (instance.annonceId case final value?) 'annonce_id': value,
  if (instance.annonceAchatId case final value?) 'annonce_achat_id': value,
  if (instance.publicationCoopId case final value?)
    'publication_coop_id': value,
  if (instance.lotId case final value?) 'lot_id': value,
  if (const FlexDouble().toJson(instance.quantiteKg) case final value?)
    'quantite_kg': value,
  if (const FlexDouble().toJson(instance.prixUnitaireKg) case final value?)
    'prix_unitaire_kg': value,
  if (const FlexDouble().toJson(instance.montantTotal) case final value?)
    'montant_total': value,
  'status': _$OrderStatusEnumMap[instance.status]!,
  if (_$MobileProviderEnumMap[instance.paymentProvider] case final value?)
    'payment_provider': value,
  'escrow_released': instance.escrowReleased,
  if (instance.livraisonAdresse case final value?) 'livraison_adresse': value,
  if (instance.livraisonDate?.toIso8601String() case final value?)
    'livraison_date': value,
  if (instance.createdAt?.toIso8601String() case final value?)
    'created_at': value,
  if (instance.updatedAt?.toIso8601String() case final value?)
    'updated_at': value,
  'payment_mode': instance.paymentMode,
  if (const FlexDoubleN().toJson(instance.depositAmount) case final value?)
    'deposit_amount': value,
  if (instance.depositPaidAt?.toIso8601String() case final value?)
    'deposit_paid_at': value,
  if (instance.balancePaidAt?.toIso8601String() case final value?)
    'balance_paid_at': value,
  if (instance.cashCollectedAt?.toIso8601String() case final value?)
    'cash_collected_at': value,
  if (instance.buyerName case final value?) 'buyer_name': value,
  if (instance.buyerPhotoUrl case final value?) 'buyer_photo_url': value,
  if (instance.sellerName case final value?) 'seller_name': value,
  if (instance.sellerPhotoUrl case final value?) 'seller_photo_url': value,
};

const _$OrderStatusEnumMap = {
  OrderStatus.sent: 'SENT',
  OrderStatus.accepted: 'ACCEPTED',
  OrderStatus.rejected: 'REJECTED',
  OrderStatus.inProgress: 'IN_PROGRESS',
  OrderStatus.delivered: 'DELIVERED',
  OrderStatus.completed: 'COMPLETED',
  OrderStatus.disputed: 'DISPUTED',
  OrderStatus.cancelled: 'CANCELLED',
  OrderStatus.unknown: 'UNKNOWN',
};

const _$MobileProviderEnumMap = {
  MobileProvider.orangeMoney: 'ORANGE_MONEY',
  MobileProvider.mtnMomo: 'MTN_MOMO',
  MobileProvider.wave: 'WAVE',
  MobileProvider.moov: 'MOOV',
  MobileProvider.virement: 'VIREMENT',
  MobileProvider.wallet: 'WALLET',
  MobileProvider.unknown: 'UNKNOWN',
};

_$DisputeImpl _$$DisputeImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$DisputeImpl',
      json,
      ($checkedConvert) {
        final val = _$DisputeImpl(
          id: $checkedConvert('id', (v) => v as String),
          commandeId: $checkedConvert('commande_id', (v) => v as String),
          openedById: $checkedConvert('opened_by_id', (v) => v as String),
          status: $checkedConvert('status', (v) => v as String? ?? 'OPEN'),
          motif: $checkedConvert('motif', (v) => v as String?),
          description: $checkedConvert('description', (v) => v as String?),
          resolution: $checkedConvert('resolution', (v) => v as String?),
          createdAt: $checkedConvert(
            'created_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          resolvedAt: $checkedConvert(
            'resolved_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'commandeId': 'commande_id',
        'openedById': 'opened_by_id',
        'createdAt': 'created_at',
        'resolvedAt': 'resolved_at',
      },
    );

Map<String, dynamic> _$$DisputeImplToJson(_$DisputeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'commande_id': instance.commandeId,
      'opened_by_id': instance.openedById,
      'status': instance.status,
      if (instance.motif case final value?) 'motif': value,
      if (instance.description case final value?) 'description': value,
      if (instance.resolution case final value?) 'resolution': value,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
      if (instance.resolvedAt?.toIso8601String() case final value?)
        'resolved_at': value,
    };
