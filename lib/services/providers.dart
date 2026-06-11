import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api_client/api_client.dart';
import '../models/price_estimate.dart';
import 'ai_service.dart';
import 'auth_service.dart';
import 'buyer_service.dart';
import 'coop_logistics_service.dart';
import 'cooperatives_service.dart';
import 'finance_service.dart';
import 'logistics_service.dart';
import 'marketplace_service.dart';
import 'matching_service.dart';
import 'messaging_service.dart';
import 'negotiation_service.dart';
import 'notifications_service.dart';
import 'ocr_service.dart';
import 'orders_service.dart';
import 'price_estimation_service.dart';
import 'supply_plans_service.dart';

/// Provider racine du client HTTP.
///
/// IMPORTANT : à override au moment où on connaît la callback de redirection
/// auth (ex. dans `main.dart` après que GoRouter soit construit).
/// Exemple :
/// ```dart
/// ProviderScope(
///   overrides: [
///     apiClientProvider.overrideWithValue(
///       ApiClient.create(onAuthFailure: () => router.go('/login')),
///     ),
///   ],
///   child: const MyApp(),
/// );
/// ```
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient.create();
});

// ─── Services ──────────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(apiClientProvider));
});

final marketplaceServiceProvider = Provider<MarketplaceService>((ref) {
  return MarketplaceService(ref.watch(apiClientProvider));
});

final buyerServiceProvider = Provider<BuyerService>((ref) {
  return BuyerService(ref.watch(apiClientProvider));
});

final coopLogisticsServiceProvider = Provider<CoopLogisticsService>((ref) {
  return CoopLogisticsService(ref.watch(apiClientProvider));
});

final ordersServiceProvider = Provider<OrdersService>((ref) {
  return OrdersService(ref.watch(apiClientProvider));
});

final financeServiceProvider = Provider<FinanceService>((ref) {
  return FinanceService(ref.watch(apiClientProvider));
});

final logisticsServiceProvider = Provider<LogisticsService>((ref) {
  return LogisticsService(ref.watch(apiClientProvider));
});

final messagingServiceProvider = Provider<MessagingService>((ref) {
  return MessagingService(ref.watch(apiClientProvider));
});

final negotiationServiceProvider = Provider<NegotiationService>((ref) {
  return NegotiationService(ref.watch(apiClientProvider));
});

final notificationsServiceProvider = Provider<NotificationsService>((ref) {
  return NotificationsService(ref.watch(apiClientProvider));
});

final cooperativesServiceProvider = Provider<CooperativesService>((ref) {
  return CooperativesService(ref.watch(apiClientProvider));
});

final aiServiceProvider = Provider<AiService>((ref) {
  return AiService(
    ref.watch(apiClientProvider),
    ref.watch(marketplaceServiceProvider),
  );
});

/// OCR documents (pièce d'identité, RCCM) — chantier onboarding express.
final ocrServiceProvider = Provider<OcrService>((ref) {
  return OcrService(ref.watch(apiClientProvider));
});

/// Plans d'approvisionnement B2B — chantier 2.
final supplyPlansServiceProvider = Provider<SupplyPlansService>((ref) {
  return SupplyPlansService(ref.watch(apiClientProvider));
});

/// Matching intelligent — opportunités pour le producteur, fournisseurs
/// potentiels pour l'acheteur / la coop.
final matchingServiceProvider = Provider<MatchingService>((ref) {
  return MatchingService(ref.watch(apiClientProvider));
});

/// Estimation prix marché — médiane + min/max + verdict. Utilisé par le
/// badge "Prix marché" producteur (publication) et acheteur (fiche
/// annonce/publication coop).
final priceEstimationServiceProvider =
    Provider<PriceEstimationService>((ref) {
  return PriceEstimationService(ref.watch(apiClientProvider));
});

/// Clé d'une requête d'estimation de prix. On en fait une classe avec
/// equality/hashCode pour que `FutureProvider.autoDispose.family` cache
/// correctement la même requête tant que les paramètres ne changent pas.
///
/// Pourquoi pas un Record Dart : la stack mobile cible encore Dart < 3
/// dans certains paths générés, et l'equality structurelle d'un record
/// est moins explicite pour le code de lecture. Une classe `==`/`hashCode`
/// reste l'idiome dominant des autres `.family` du projet (cf.
/// `mesCandidaturesAccepteesProvider` qui prend un `String`).
@immutable
class PriceEstimateQuery {
  const PriceEstimateQuery({
    required this.produitId,
    this.regionId,
    this.qualite,
    this.periodDays,
  });

  final String produitId;
  final String? regionId;
  final String? qualite;
  final int? periodDays;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PriceEstimateQuery &&
        other.produitId == produitId &&
        other.regionId == regionId &&
        other.qualite == qualite &&
        other.periodDays == periodDays;
  }

  @override
  int get hashCode => Object.hash(produitId, regionId, qualite, periodDays);
}

/// Provider d'estimation prix. `autoDispose` pour libérer le cache dès
/// qu'aucun widget ne l'écoute (la fiche annonce change souvent).
final priceEstimateProvider = FutureProvider.autoDispose
    .family<PriceEstimate?, PriceEstimateQuery>((ref, q) async {
  return ref.read(priceEstimationServiceProvider).estimate(
        produitId: q.produitId,
        regionId: q.regionId,
        qualite: q.qualite,
        periodDays: q.periodDays,
      );
});
