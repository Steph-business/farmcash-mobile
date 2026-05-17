import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';

part 'cooperative.freezed.dart';
part 'cooperative.g.dart';

@freezed
class Cooperative with _$Cooperative {
  const factory Cooperative({
    required String id,
    required String userId,
    required String nom,
    String? numeroAgrement,
    String? regionId,
    String? villeId,
    @FlexInt() @Default(0) int nbMembres,
    @Default(<String>[]) List<String> produits,
    @FlexDouble() @Default(0.0) double commissionRate,
    @Default(false) bool autoDistribute,
    String? presidentId,
    String? logoUrl,
    String? description,
    DateTime? createdAt,
  }) = _Cooperative;

  factory Cooperative.fromJson(Map<String, dynamic> json) =>
      _$CooperativeFromJson(json);
}
