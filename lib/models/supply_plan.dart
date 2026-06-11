// =====================================================================
//  Supply Plan — Plan d'approvisionnement B2B (chantier 2)
//  ---------------------------------------------------------------------
//  Modèle léger côté mobile (pas de freezed V1 — peu de champs critiques).
//  Si la complexité grandit (validations, conversions), on migrera.
// =====================================================================

import 'package:intl/intl.dart';

class SupplyPlan {
  SupplyPlan({
    required this.id,
    required this.buyerId,
    required this.produitId,
    required this.qtyPerMonthKg,
    required this.durationMonths,
    required this.pricePerKg,
    required this.startMonth,
    required this.deliveryAddress,
    required this.deliveryCity,
    required this.status,
    this.notes,
    this.adminRejectionReason,
    this.publishedAt,
    this.createdAt,
    this.produitNom,
    this.buyerName,
    this.candidaturesCount,
  });

  final String id;
  final String buyerId;
  final String produitId;
  final double qtyPerMonthKg;
  final int durationMonths;
  final double pricePerKg;
  final DateTime startMonth;
  final String deliveryAddress;
  final String deliveryCity;
  final String status;
  final String? notes;
  final String? adminRejectionReason;
  final DateTime? publishedAt;
  final DateTime? createdAt;

  // Champs joints depuis l'API (include backend)
  final String? produitNom;
  final String? buyerName;
  final int? candidaturesCount;

  /// Volume total = qty/mois × durée
  double get totalVolumeKg => qtyPerMonthKg * durationMonths;

  /// Valeur totale en F CFA
  double get totalValue => totalVolumeKg * pricePerKg;

  factory SupplyPlan.fromJson(Map<String, dynamic> json) {
    final produitJson = json['produits_agricoles'] as Map<String, dynamic>?;
    final usersJson = json['users'] as Map<String, dynamic>?;
    final countJson = json['_count'] as Map<String, dynamic>?;
    return SupplyPlan(
      id: json['id'] as String,
      buyerId: json['buyer_id'] as String,
      produitId: json['produit_id'] as String,
      qtyPerMonthKg: _toDouble(json['qty_per_month_kg']),
      durationMonths: json['duration_months'] as int,
      pricePerKg: _toDouble(json['price_per_kg']),
      startMonth: DateTime.parse(json['start_month'] as String),
      deliveryAddress: json['delivery_address'] as String,
      deliveryCity: json['delivery_city'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      adminRejectionReason: json['admin_rejection_reason'] as String?,
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      produitNom: produitJson?['nom'] as String?,
      buyerName: usersJson?['full_name'] as String?,
      candidaturesCount:
          countJson?['supply_plan_candidatures'] as int?,
    );
  }

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.parse(v);
    return 0;
  }

  String formatStartMonth() {
    return DateFormat('MMMM yyyy', 'fr_FR').format(startMonth);
  }
}

/// Étiquettes UX pour les statuts d'un plan.
String labelStatutPlan(String status) {
  switch (status) {
    case 'DRAFT':
      return 'Brouillon';
    case 'PENDING_VALIDATION':
      return 'En attente de validation';
    case 'PUBLISHED':
      return 'Publié';
    case 'NEGOTIATING':
      return 'Candidatures en cours';
    case 'ACTIVE':
      return 'Actif';
    case 'COMPLETED':
      return 'Terminé';
    case 'CANCELLED':
      return 'Annulé';
    case 'REJECTED':
      return 'Rejeté';
    default:
      return status;
  }
}
