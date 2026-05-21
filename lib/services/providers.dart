import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api_client/api_client.dart';
import 'ai_service.dart';
import 'auth_service.dart';
import 'buyer_service.dart';
import 'coop_logistics_service.dart';
import 'cooperatives_service.dart';
import 'finance_service.dart';
import 'logistics_service.dart';
import 'marketplace_service.dart';
import 'messaging_service.dart';
import 'negotiation_service.dart';
import 'notifications_service.dart';
import 'orders_service.dart';

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
  return AiService(ref.watch(apiClientProvider));
});
