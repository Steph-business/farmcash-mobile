// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'farmer_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FarmerOverviewImpl _$$FarmerOverviewImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(r'_$FarmerOverviewImpl', json, ($checkedConvert) {
      final val = _$FarmerOverviewImpl(
        commerce: $checkedConvert(
          'commerce',
          (v) => FarmerCommerce.fromJson(v as Map<String, dynamic>),
        ),
        revenue: $checkedConvert(
          'revenue',
          (v) => FarmerRevenue.fromJson(v as Map<String, dynamic>),
        ),
        cultures: $checkedConvert(
          'cultures',
          (v) => FarmerCultures.fromJson(v as Map<String, dynamic>),
        ),
        rating: $checkedConvert(
          'rating',
          (v) => FarmerRating.fromJson(v as Map<String, dynamic>),
        ),
        wallet: $checkedConvert(
          'wallet',
          (v) => FarmerWallet.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$$FarmerOverviewImplToJson(
  _$FarmerOverviewImpl instance,
) => <String, dynamic>{
  'commerce': instance.commerce,
  'revenue': instance.revenue,
  'cultures': instance.cultures,
  'rating': instance.rating,
  'wallet': instance.wallet,
};

_$FarmerCommerceImpl _$$FarmerCommerceImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$FarmerCommerceImpl',
      json,
      ($checkedConvert) {
        final val = _$FarmerCommerceImpl(
          activeAnnonces: $checkedConvert(
            'active_annonces',
            (v) => v == null ? 0 : const FlexInt().fromJson(v),
          ),
          totalViews: $checkedConvert(
            'total_views',
            (v) => v == null ? 0 : const FlexInt().fromJson(v),
          ),
          ordersToShip: $checkedConvert(
            'orders_to_ship',
            (v) => v == null ? 0 : const FlexInt().fromJson(v),
          ),
          pendingCandidatures: $checkedConvert(
            'pending_candidatures',
            (v) => v == null ? 0 : const FlexInt().fromJson(v),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'activeAnnonces': 'active_annonces',
        'totalViews': 'total_views',
        'ordersToShip': 'orders_to_ship',
        'pendingCandidatures': 'pending_candidatures',
      },
    );

Map<String, dynamic> _$$FarmerCommerceImplToJson(
  _$FarmerCommerceImpl instance,
) => <String, dynamic>{
  if (const FlexInt().toJson(instance.activeAnnonces) case final value?)
    'active_annonces': value,
  if (const FlexInt().toJson(instance.totalViews) case final value?)
    'total_views': value,
  if (const FlexInt().toJson(instance.ordersToShip) case final value?)
    'orders_to_ship': value,
  if (const FlexInt().toJson(instance.pendingCandidatures) case final value?)
    'pending_candidatures': value,
};

_$FarmerRevenueImpl _$$FarmerRevenueImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$FarmerRevenueImpl',
      json,
      ($checkedConvert) {
        final val = _$FarmerRevenueImpl(
          last30dXof: $checkedConvert(
            'last_30d_xof',
            (v) => v == null ? 0.0 : const FlexDouble().fromJson(v),
          ),
          ordersCompleted30d: $checkedConvert(
            'orders_completed_30d',
            (v) => v == null ? 0 : const FlexInt().fromJson(v),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'last30dXof': 'last_30d_xof',
        'ordersCompleted30d': 'orders_completed_30d',
      },
    );

Map<String, dynamic> _$$FarmerRevenueImplToJson(_$FarmerRevenueImpl instance) =>
    <String, dynamic>{
      if (const FlexDouble().toJson(instance.last30dXof) case final value?)
        'last_30d_xof': value,
      if (const FlexInt().toJson(instance.ordersCompleted30d) case final value?)
        'orders_completed_30d': value,
    };

_$FarmerCulturesImpl _$$FarmerCulturesImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$FarmerCulturesImpl',
      json,
      ($checkedConvert) {
        final val = _$FarmerCulturesImpl(
          parcellesCount: $checkedConvert(
            'parcelles_count',
            (v) => v == null ? 0 : const FlexInt().fromJson(v),
          ),
          criticalAnalyses30d: $checkedConvert(
            'critical_analyses_30d',
            (v) => v == null ? 0 : const FlexInt().fromJson(v),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'parcellesCount': 'parcelles_count',
        'criticalAnalyses30d': 'critical_analyses_30d',
      },
    );

Map<String, dynamic> _$$FarmerCulturesImplToJson(
  _$FarmerCulturesImpl instance,
) => <String, dynamic>{
  if (const FlexInt().toJson(instance.parcellesCount) case final value?)
    'parcelles_count': value,
  if (const FlexInt().toJson(instance.criticalAnalyses30d) case final value?)
    'critical_analyses_30d': value,
};

_$FarmerRatingImpl _$$FarmerRatingImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(r'_$FarmerRatingImpl', json, ($checkedConvert) {
      final val = _$FarmerRatingImpl(
        average: $checkedConvert(
          'average',
          (v) => v == null ? 0.0 : const FlexDouble().fromJson(v),
        ),
        count: $checkedConvert(
          'count',
          (v) => v == null ? 0 : const FlexInt().fromJson(v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$$FarmerRatingImplToJson(
  _$FarmerRatingImpl instance,
) => <String, dynamic>{
  if (const FlexDouble().toJson(instance.average) case final value?)
    'average': value,
  if (const FlexInt().toJson(instance.count) case final value?) 'count': value,
};

_$FarmerWalletImpl _$$FarmerWalletImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$FarmerWalletImpl',
      json,
      ($checkedConvert) {
        final val = _$FarmerWalletImpl(
          balanceXof: $checkedConvert(
            'balance_xof',
            (v) => v == null ? 0.0 : const FlexDouble().fromJson(v),
          ),
          isFrozen: $checkedConvert('is_frozen', (v) => v as bool? ?? false),
        );
        return val;
      },
      fieldKeyMap: const {'balanceXof': 'balance_xof', 'isFrozen': 'is_frozen'},
    );

Map<String, dynamic> _$$FarmerWalletImplToJson(_$FarmerWalletImpl instance) =>
    <String, dynamic>{
      if (const FlexDouble().toJson(instance.balanceXof) case final value?)
        'balance_xof': value,
      'is_frozen': instance.isFrozen,
    };

_$FarmerPendingActionsImpl _$$FarmerPendingActionsImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  r'_$FarmerPendingActionsImpl',
  json,
  ($checkedConvert) {
    final val = _$FarmerPendingActionsImpl(
      candidaturesToHandle: $checkedConvert(
        'candidatures_to_handle',
        (v) => v == null ? 0 : const FlexInt().fromJson(v),
      ),
      ordersToShip: $checkedConvert(
        'orders_to_ship',
        (v) => v == null ? 0 : const FlexInt().fromJson(v),
      ),
      previsionsToConvertSoon: $checkedConvert(
        'previsions_to_convert_soon',
        (v) => v == null ? 0 : const FlexInt().fromJson(v),
      ),
      annoncesPendingCoop: $checkedConvert(
        'annonces_pending_coop',
        (v) => v == null ? 0 : const FlexInt().fromJson(v),
      ),
      total: $checkedConvert(
        'total',
        (v) => v == null ? 0 : const FlexInt().fromJson(v),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'candidaturesToHandle': 'candidatures_to_handle',
    'ordersToShip': 'orders_to_ship',
    'previsionsToConvertSoon': 'previsions_to_convert_soon',
    'annoncesPendingCoop': 'annonces_pending_coop',
  },
);

Map<String, dynamic> _$$FarmerPendingActionsImplToJson(
  _$FarmerPendingActionsImpl instance,
) => <String, dynamic>{
  if (const FlexInt().toJson(instance.candidaturesToHandle) case final value?)
    'candidatures_to_handle': value,
  if (const FlexInt().toJson(instance.ordersToShip) case final value?)
    'orders_to_ship': value,
  if (const FlexInt().toJson(instance.previsionsToConvertSoon)
      case final value?)
    'previsions_to_convert_soon': value,
  if (const FlexInt().toJson(instance.annoncesPendingCoop) case final value?)
    'annonces_pending_coop': value,
  if (const FlexInt().toJson(instance.total) case final value?) 'total': value,
};

_$FarmerConversionRowImpl _$$FarmerConversionRowImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  r'_$FarmerConversionRowImpl',
  json,
  ($checkedConvert) {
    final val = _$FarmerConversionRowImpl(
      annonceId: $checkedConvert('annonce_id', (v) => v as String),
      titre: $checkedConvert('titre', (v) => v as String),
      views: $checkedConvert(
        'views',
        (v) => v == null ? 0 : const FlexInt().fromJson(v),
      ),
      candidatures: $checkedConvert(
        'candidatures',
        (v) => v == null ? 0 : const FlexInt().fromJson(v),
      ),
      orders: $checkedConvert(
        'orders',
        (v) => v == null ? 0 : const FlexInt().fromJson(v),
      ),
      conversionRate: $checkedConvert(
        'conversion_rate',
        (v) => v == null ? 0.0 : const FlexDouble().fromJson(v),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'annonceId': 'annonce_id',
    'conversionRate': 'conversion_rate',
  },
);

Map<String, dynamic> _$$FarmerConversionRowImplToJson(
  _$FarmerConversionRowImpl instance,
) => <String, dynamic>{
  'annonce_id': instance.annonceId,
  'titre': instance.titre,
  if (const FlexInt().toJson(instance.views) case final value?) 'views': value,
  if (const FlexInt().toJson(instance.candidatures) case final value?)
    'candidatures': value,
  if (const FlexInt().toJson(instance.orders) case final value?)
    'orders': value,
  if (const FlexDouble().toJson(instance.conversionRate) case final value?)
    'conversion_rate': value,
};
