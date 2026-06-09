/// Modèles pour la **distribution** d'une publication coop agrégée
/// après une vente (preview via `dry_run=true`, ou résultat exécuté).
///
/// Modèles légers manuels (pas freezed) — consommés à un seul endroit
/// (carte distribution sur la page détail commande coop). Le contrat
/// backend est stable, pas besoin de la lourdeur du codegen ici.

/// Une ligne de distribution : qui touche combien après cascade.
class DistributionLine {
  const DistributionLine({
    required this.farmerId,
    required this.contributionId,
    required this.annonceVenteId,
    required this.quantiteKg,
    required this.partPct,
    required this.grossAmount,
    required this.advanceDeducted,
    required this.amount,
    this.farmerName,
  });

  final String farmerId;
  final String contributionId;
  final String annonceVenteId;
  final double quantiteKg;

  /// Part du producteur dans le lot (0.0 - 1.0). 0.4 = 40 %.
  final double partPct;

  /// Montant brut avant déduction des avances déjà payées.
  final double grossAmount;

  /// Total des avances déjà versées au producteur — déduit du brut.
  final double advanceDeducted;

  /// Montant net à recevoir (gross - advances).
  final double amount;

  /// Nom du producteur. Backend ne le joint pas dans le breakdown
  /// (juste dans `getContributions`) — on l'enrichit côté mobile en
  /// croisant avec la liste des contributions.
  final String? farmerName;

  factory DistributionLine.fromJson(Map<String, dynamic> json) {
    return DistributionLine(
      farmerId: json['farmer_id'] as String? ?? '',
      contributionId: json['contribution_id'] as String? ?? '',
      annonceVenteId: json['annonce_vente_id'] as String? ?? '',
      quantiteKg: _toDouble(json['quantite_kg']),
      partPct: _toDouble(json['part_pct']),
      grossAmount: _toDouble(json['gross_amount']),
      advanceDeducted: _toDouble(json['advance_deducted']),
      amount: _toDouble(json['amount']),
    );
  }

  DistributionLine copyWithName(String? name) => DistributionLine(
        farmerId: farmerId,
        contributionId: contributionId,
        annonceVenteId: annonceVenteId,
        quantiteKg: quantiteKg,
        partPct: partPct,
        grossAmount: grossAmount,
        advanceDeducted: advanceDeducted,
        amount: amount,
        farmerName: name,
      );
}

/// Aperçu (ou résultat) de la distribution d'une publication coop.
///
/// Backend renvoie : `{ total_sold, coop_commission, distributable,
/// breakdown[], executed }`.
///
/// Note : le frais FarmCash 3% n'est PAS exposé directement par le
/// backend dans la réponse — il est déjà prélevé en amont au moment de
/// la libération escrow. Côté UI on le **calcule** comme :
///     `farmcashFee = totalSold - (coopCommission + distributable + commissionCascadeBase)`
/// Plus simple : on l'estime à `totalSold * 0.03` (taux config par défaut).
class DistributionPreview {
  const DistributionPreview({
    required this.totalSold,
    required this.coopCommission,
    required this.distributable,
    required this.farmcashFee,
    required this.breakdown,
    required this.executed,
  });

  /// Total payé par l'acheteur (brut).
  final double totalSold;

  /// Commission de la coop (5% par défaut, sur le net après FarmCash).
  final double coopCommission;

  /// Montant total à distribuer aux producteurs membres (au prorata).
  final double distributable;

  /// Frais FarmCash (3% du brut). Calculé côté mobile car pas exposé
  /// dans la réponse backend.
  final double farmcashFee;

  /// Détail par producteur.
  final List<DistributionLine> breakdown;

  /// `true` = distribution réelle effectuée. `false` = preview (dry-run).
  final bool executed;

  factory DistributionPreview.fromJson(Map<String, dynamic> json) {
    final totalSold = _toDouble(json['total_sold']);
    final breakdown = (json['breakdown'] as List?)
            ?.whereType<Map>()
            .map((m) =>
                DistributionLine.fromJson(m.cast<String, dynamic>()))
            .toList(growable: false) ??
        const <DistributionLine>[];
    return DistributionPreview(
      totalSold: totalSold,
      coopCommission: _toDouble(json['coop_commission']),
      distributable: _toDouble(json['distributable']),
      // Pas exposé par le backend → estimation au taux par défaut. C'est
      // exactement ce que le backend prélève (cf. SERVICE_FEE_PRODUCT).
      farmcashFee: (totalSold * 0.03).roundToDouble(),
      breakdown: breakdown,
      executed: json['executed'] == true,
    );
  }
}

double _toDouble(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}
