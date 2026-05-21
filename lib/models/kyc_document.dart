import 'package:freezed_annotation/freezed_annotation.dart';

part 'kyc_document.freezed.dart';
part 'kyc_document.g.dart';

/// Document KYC (justificatif d'identité, parcelle, carte producteur).
///
/// Workflow : PENDING (upload) → VALIDATED ou REJECTED (par un ADMIN
/// côté oversight).
@freezed
class KycDocument with _$KycDocument {
  const factory KycDocument({
    required String id,
    required String userId,
    @Default('') String docType,
    @Default('') String url,
    @Default('PENDING') String status,
    String? rejectionReason,
    DateTime? uploadedAt,
    DateTime? validatedAt,
    String? validatedBy,
  }) = _KycDocument;

  factory KycDocument.fromJson(Map<String, dynamic> json) =>
      _$KycDocumentFromJson(json);
}
