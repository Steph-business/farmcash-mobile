// =====================================================================
//  Supply Plans Service (chantier 2)
//  ---------------------------------------------------------------------
//  Client REST pour les plans d'approvisionnement B2B.
// =====================================================================

import '../api_client/api_client.dart';
import '../models/supply_plan.dart';

class SupplyPlansService {
  SupplyPlansService(this._api);
  final ApiClient _api;

  /// Crée un plan (BUYER, RCCM obligatoire côté backend).
  Future<SupplyPlan> createPlan({
    required String produitId,
    required double qtyPerMonthKg,
    required int durationMonths,
    required double pricePerKg,
    required DateTime startMonth,
    required String deliveryAddress,
    required String deliveryCity,
    String? notes,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      '/supply-plans',
      body: {
        'produit_id': produitId,
        'qty_per_month_kg': qtyPerMonthKg,
        'duration_months': durationMonths,
        'price_per_kg': pricePerKg,
        'start_month': startMonth.toIso8601String(),
        'delivery_address': deliveryAddress,
        'delivery_city': deliveryCity,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    return SupplyPlan.fromJson(json);
  }

  /// Liste mes plans (BUYER).
  Future<List<SupplyPlan>> listMyPlans({String? status}) async {
    final json = await _api.get<List<dynamic>>(
      '/supply-plans/mine',
      query: status != null ? {'status': status} : null,
    );
    return json
        .map((e) => SupplyPlan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Liste les plans publics visibles aux fournisseurs (FARMER, COOP).
  Future<List<SupplyPlan>> listPublicPlans({String? produitId}) async {
    final json = await _api.get<List<dynamic>>(
      '/supply-plans/public',
      query: produitId != null ? {'produit_id': produitId} : null,
    );
    return json
        .map((e) => SupplyPlan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Détail d'un plan (tous rôles, contrôle backend selon statut).
  Future<SupplyPlan> getPlanById(String id) async {
    final json = await _api.get<Map<String, dynamic>>('/supply-plans/$id');
    return SupplyPlan.fromJson(json);
  }

  // ─── Candidatures ────────────────────────────────────────────

  /// Candidater à un plan (FARMER, COOPERATIVE).
  Future<Map<String, dynamic>> createCandidature({
    required String planId,
    required double qtyOfferedKg,
    required int monthsOffered,
    required double priceOffered,
    String? message,
  }) async {
    return _api.post<Map<String, dynamic>>(
      '/supply-plans/$planId/candidatures',
      body: {
        'qty_offered_kg': qtyOfferedKg,
        'months_offered': monthsOffered,
        'price_offered': priceOffered,
        if (message != null && message.isNotEmpty) 'message': message,
      },
    );
  }

  /// Lister les candidatures sur un de mes plans (BUYER).
  Future<List<Map<String, dynamic>>> listCandidatures(String planId) async {
    final json = await _api.get<List<dynamic>>(
      '/supply-plans/$planId/candidatures',
    );
    return json.cast<Map<String, dynamic>>();
  }

  /// Accepter une candidature → crée le contrat (BUYER).
  Future<Map<String, dynamic>> acceptCandidature(String candidatureId) async {
    return _api.post<Map<String, dynamic>>(
      '/supply-plans/candidatures/$candidatureId/accept',
      body: {},
    );
  }

  /// Rejeter une candidature (BUYER).
  Future<Map<String, dynamic>> rejectCandidature(
    String candidatureId, {
    String? motif,
  }) async {
    return _api.post<Map<String, dynamic>>(
      '/supply-plans/candidatures/$candidatureId/reject',
      body: motif != null ? {'motif': motif} : {},
    );
  }

  /// Retirer ma candidature (FARMER, COOPERATIVE).
  Future<Map<String, dynamic>> withdrawCandidature(String candidatureId) async {
    return _api.post<Map<String, dynamic>>(
      '/supply-plans/candidatures/$candidatureId/withdraw',
      body: {},
    );
  }

  // ─── Contrats + tranches (Phase 5) ──────────────────────────

  /// Liste mes contrats actifs comme fournisseur (FARMER, COOP).
  Future<List<Map<String, dynamic>>> listMyContractsAsSupplier() async {
    final json = await _api.get<List<dynamic>>(
      '/supply-plans/contracts/mine',
    );
    return json.cast<Map<String, dynamic>>();
  }

  /// Liste les contrats créés à partir de mon plan (BUYER).
  Future<List<Map<String, dynamic>>> listContractsForPlan(
    String planId,
  ) async {
    final json = await _api.get<List<dynamic>>(
      '/supply-plans/$planId/contracts',
    );
    return json.cast<Map<String, dynamic>>();
  }
}
