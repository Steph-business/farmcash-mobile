import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';

part 'farmer_stats.freezed.dart';
part 'farmer_stats.g.dart';

/// Modèles du tableau de bord analytique PRODUCTEUR.
///
/// Alimentent la page « Mes statistiques » à partir des endpoints
/// `GET /oversight/farmer/*` (rôle FARMER). Tous les montants XOF arrivent
/// en `Decimal` Prisma (souvent sérialisés en String) → `FlexDouble`.

// ─── Overview (GET /oversight/farmer/overview) ─────────────────────────

/// Vue agrégée du producteur : commerce, revenus 30j, cultures, note,
/// wallet. Sert de carte hero + grille KPI de la page stats.
@freezed
class FarmerOverview with _$FarmerOverview {
  const factory FarmerOverview({
    required FarmerCommerce commerce,
    required FarmerRevenue revenue,
    required FarmerCultures cultures,
    required FarmerRating rating,
    required FarmerWallet wallet,
  }) = _FarmerOverview;

  factory FarmerOverview.fromJson(Map<String, dynamic> json) =>
      _$FarmerOverviewFromJson(json);
}

/// Bloc « commerce » : annonces actives, vues cumulées, commandes à
/// expédier, candidatures en attente.
@freezed
class FarmerCommerce with _$FarmerCommerce {
  const factory FarmerCommerce({
    @JsonKey(name: 'active_annonces') @FlexInt() @Default(0) int activeAnnonces,
    @JsonKey(name: 'total_views') @FlexInt() @Default(0) int totalViews,
    @JsonKey(name: 'orders_to_ship') @FlexInt() @Default(0) int ordersToShip,
    @JsonKey(name: 'pending_candidatures')
    @FlexInt()
    @Default(0)
    int pendingCandidatures,
  }) = _FarmerCommerce;

  factory FarmerCommerce.fromJson(Map<String, dynamic> json) =>
      _$FarmerCommerceFromJson(json);
}

/// Bloc « revenue » : chiffre d'affaires net des 30 derniers jours et
/// nombre de commandes finalisées sur la période.
@freezed
class FarmerRevenue with _$FarmerRevenue {
  const factory FarmerRevenue({
    @JsonKey(name: 'last_30d_xof') @FlexDouble() @Default(0.0) double last30dXof,
    @JsonKey(name: 'orders_completed_30d')
    @FlexInt()
    @Default(0)
    int ordersCompleted30d,
  }) = _FarmerRevenue;

  factory FarmerRevenue.fromJson(Map<String, dynamic> json) =>
      _$FarmerRevenueFromJson(json);
}

/// Bloc « cultures » : nombre de parcelles et analyses critiques récentes.
@freezed
class FarmerCultures with _$FarmerCultures {
  const factory FarmerCultures({
    @JsonKey(name: 'parcelles_count') @FlexInt() @Default(0) int parcellesCount,
    @JsonKey(name: 'critical_analyses_30d')
    @FlexInt()
    @Default(0)
    int criticalAnalyses30d,
  }) = _FarmerCultures;

  factory FarmerCultures.fromJson(Map<String, dynamic> json) =>
      _$FarmerCulturesFromJson(json);
}

/// Bloc « rating » : note moyenne et nombre d'évaluations.
@freezed
class FarmerRating with _$FarmerRating {
  const factory FarmerRating({
    @FlexDouble() @Default(0.0) double average,
    @FlexInt() @Default(0) int count,
  }) = _FarmerRating;

  factory FarmerRating.fromJson(Map<String, dynamic> json) =>
      _$FarmerRatingFromJson(json);
}

/// Bloc « wallet » : solde XOF et état (gelé ou non).
@freezed
class FarmerWallet with _$FarmerWallet {
  const factory FarmerWallet({
    @JsonKey(name: 'balance_xof') @FlexDouble() @Default(0.0) double balanceXof,
    @JsonKey(name: 'is_frozen') @Default(false) bool isFrozen,
  }) = _FarmerWallet;

  factory FarmerWallet.fromJson(Map<String, dynamic> json) =>
      _$FarmerWalletFromJson(json);
}

// ─── Pending actions (GET /oversight/farmer/pending-actions) ───────────

/// Mini-todo board du producteur : candidatures à traiter, commandes à
/// livrer, prévisions à convertir, annonces en attente coop. `total` est
/// la somme calculée côté backend.
@freezed
class FarmerPendingActions with _$FarmerPendingActions {
  const factory FarmerPendingActions({
    @JsonKey(name: 'candidatures_to_handle')
    @FlexInt()
    @Default(0)
    int candidaturesToHandle,
    @JsonKey(name: 'orders_to_ship') @FlexInt() @Default(0) int ordersToShip,
    @JsonKey(name: 'previsions_to_convert_soon')
    @FlexInt()
    @Default(0)
    int previsionsToConvertSoon,
    @JsonKey(name: 'annonces_pending_coop')
    @FlexInt()
    @Default(0)
    int annoncesPendingCoop,
    @FlexInt() @Default(0) int total,
  }) = _FarmerPendingActions;

  factory FarmerPendingActions.fromJson(Map<String, dynamic> json) =>
      _$FarmerPendingActionsFromJson(json);
}

// ─── Conversion funnel (GET /oversight/farmer/conversion-funnel) ───────

/// Ligne du funnel de conversion d'une annonce active :
/// vues → candidatures → commandes, avec le taux de conversion (%) calculé
/// côté backend (commandes / vues × 100).
@freezed
class FarmerConversionRow with _$FarmerConversionRow {
  const factory FarmerConversionRow({
    @JsonKey(name: 'annonce_id') required String annonceId,
    required String titre,
    @FlexInt() @Default(0) int views,
    @FlexInt() @Default(0) int candidatures,
    @FlexInt() @Default(0) int orders,
    @JsonKey(name: 'conversion_rate')
    @FlexDouble()
    @Default(0.0)
    double conversionRate,
  }) = _FarmerConversionRow;

  factory FarmerConversionRow.fromJson(Map<String, dynamic> json) =>
      _$FarmerConversionRowFromJson(json);
}
