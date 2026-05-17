import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';

part 'traitement.freezed.dart';
part 'traitement.g.dart';

/// Traitement recommandé pour une maladie/ravageur.
@freezed
class Traitement with _$Traitement {
  const factory Traitement({
    required String id,
    required String nom,
    String? description,
    String? type,
    String? mode,
    String? dosage,
    @Default(<String>[]) List<String> maladies,
    @Default(<String>[]) List<String> produits,
    @Default(false) bool isBio,
    @FlexDoubleN() double? prixIndicatif,
    DateTime? createdAt,
  }) = _Traitement;

  factory Traitement.fromJson(Map<String, dynamic> json) =>
      _$TraitementFromJson(json);
}
