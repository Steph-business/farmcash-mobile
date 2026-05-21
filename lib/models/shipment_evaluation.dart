import 'package:freezed_annotation/freezed_annotation.dart';

part 'shipment_evaluation.freezed.dart';
part 'shipment_evaluation.g.dart';

/// Évaluation d'un transporteur par l'acheteur après livraison.
/// Réutilise la table `avis` côté backend avec `context_type = 'SHIPMENT'`.
@freezed
class ShipmentEvaluation with _$ShipmentEvaluation {
  const factory ShipmentEvaluation({
    required String id,
    required String reviewerId,
    required String reviewedUserId,
    @Default(0) int note,
    String? commentaire,
    DateTime? createdAt,
  }) = _ShipmentEvaluation;

  factory ShipmentEvaluation.fromJson(Map<String, dynamic> json) =>
      _$ShipmentEvaluationFromJson(json);
}
