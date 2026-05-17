import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';

part 'analyse_plante.freezed.dart';
part 'analyse_plante.g.dart';

@freezed
class AnalysePlante with _$AnalysePlante {
  const factory AnalysePlante({
    required String id,
    required String farmerId,
    @Default('') String imageUrl,
    String? parcelleId,
    String? diseaseDetected,
    String? riskLevel,
    @FlexDoubleN() double? confidenceScore,
    String? recommendations,
    @Default(<String>[]) List<String> treatmentIds,
    DateTime? createdAt,
  }) = _AnalysePlante;

  factory AnalysePlante.fromJson(Map<String, dynamic> json) =>
      _$AnalysePlanteFromJson(json);
}
