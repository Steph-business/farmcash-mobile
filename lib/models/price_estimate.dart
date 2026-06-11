import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';

part 'price_estimate.freezed.dart';
part 'price_estimate.g.dart';

/// Origine du calcul d'estimation prix renvoyée par le backend.
///
/// - `history` : prix calculé à partir des commandes réelles récentes
///   (médiane + min/max sur N jours). Le plus fiable.
/// - `catalog` : pas assez de commandes → fallback sur le prix de
///   référence du catalogue produit. À afficher comme "prix de
///   référence" plutôt que "prix marché".
/// - `none` : ni historique ni catalogue dispo. On masque le badge.
/// - `unknown` : valeur inconnue côté front (forward compat).
@JsonEnum(valueField: 'apiValue')
enum PriceSource {
  history('history'),
  catalog('catalog'),
  none('none'),
  unknown('UNKNOWN');

  const PriceSource(this.apiValue);
  final String apiValue;
}

/// Verdict synthétique calculé côté mobile à partir de l'estimation
/// et du prix saisi par l'utilisateur (producteur ou affichage acheteur).
///
/// Sert à choisir la couleur + le wording du sous-encart "ton prix" :
/// - `underMarket` : prix < min du marché → risque vente difficile
/// - `fairMarket`  : prix entre min et max → dans la fourchette
/// - `aboveMarket` : prix > max → marge de négociation visible
/// - `noSignal`    : pas assez de données pour qualifier
enum PriceVerdict { underMarket, fairMarket, aboveMarket, noSignal }

/// Réponse de `GET /ai/price-estimate?produit_id=...&region_id=...
/// &qualite=...&period_days=...`.
///
/// Tous les champs peuvent être null si le backend retourne `source=none`.
/// On garde donc les `*_kg` nullables et on s'appuie sur `isComplete` pour
/// décider si on affiche quelque chose.
@freezed
class PriceEstimate with _$PriceEstimate {
  const PriceEstimate._();

  const factory PriceEstimate({
    /// Prix médian observé sur la période (F CFA/kg).
    @JsonKey(name: 'median_kg') @FlexDoubleN() double? medianKg,

    /// Prix minimum observé sur la période (F CFA/kg).
    @JsonKey(name: 'min_kg') @FlexDoubleN() double? minKg,

    /// Prix maximum observé sur la période (F CFA/kg).
    @JsonKey(name: 'max_kg') @FlexDoubleN() double? maxKg,

    /// Nombre de commandes utilisées pour calculer médian/min/max.
    @JsonKey(name: 'sample_size') @FlexInt() @Default(0) int sampleSize,

    /// Fenêtre temporelle (en jours) considérée par le backend.
    @JsonKey(name: 'period_days') @FlexInt() @Default(90) int periodDays,

    /// Vrai si la médiane est suffisamment fiable pour être affichée
    /// avec confiance (calculé côté backend selon `sampleSize`).
    @JsonKey(name: 'is_reliable') @Default(false) bool isReliable,

    /// Origine du calcul (historique réel vs fallback catalogue).
    @JsonKey(name: 'source', unknownEnumValue: PriceSource.unknown)
    @Default(PriceSource.unknown)
    PriceSource source,

    /// Nom lisible du produit (renvoyé pour affichage direct).
    @JsonKey(name: 'product_name') String? productName,
  }) = _PriceEstimate;

  factory PriceEstimate.fromJson(Map<String, dynamic> json) =>
      _$PriceEstimateFromJson(json);

  // ─── Helpers métier ──────────────────────────────────────────────────

  /// `true` si on a au moins une médiane à afficher. Les widgets qui
  /// reçoivent `null` ou `isComplete == false` doivent retourner
  /// `SizedBox.shrink()` (silencieux, pas d'erreur intrusive).
  bool get isComplete =>
      medianKg != null && medianKg! > 0 && source != PriceSource.none;

  /// Écart signé entre un prix donné et la médiane, en pourcentage.
  /// Retourne `0` si la médiane n'est pas dispo (évite NaN).
  ///
  /// Convention : positif = au-dessus du marché, négatif = en dessous.
  double percentDiffFromMedian(double prixKg) {
    final m = medianKg;
    if (m == null || m <= 0) return 0;
    return ((prixKg - m) / m) * 100.0;
  }

  /// Classification visuelle d'un prix donné par rapport au marché.
  /// Utilise min/max si dispos pour la sweetspot, sinon retombe sur la
  /// médiane +/- 10 %.
  PriceVerdict verdictFor(double prixKg) {
    if (!isComplete) return PriceVerdict.noSignal;
    final mn = minKg;
    final mx = maxKg;
    if (mn != null && mx != null && mn > 0 && mx > 0) {
      if (prixKg < mn) return PriceVerdict.underMarket;
      if (prixKg > mx) return PriceVerdict.aboveMarket;
      return PriceVerdict.fairMarket;
    }
    // Fallback : pas de fourchette → on tolère +/- 10 % autour de la
    // médiane pour éviter le faux signal alarmant sur un petit dataset.
    final m = medianKg!;
    final delta = (prixKg - m).abs() / m;
    if (delta <= 0.10) return PriceVerdict.fairMarket;
    return prixKg < m ? PriceVerdict.underMarket : PriceVerdict.aboveMarket;
  }
}
