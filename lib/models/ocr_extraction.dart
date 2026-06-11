// =====================================================================
//  OCR Extraction Models
//  ---------------------------------------------------------------------
//  Réponses du backend pour les endpoints OCR documents :
//   • POST /ai/ocr/identity-card  → IdentityCardExtraction
//   • POST /ai/ocr/rccm           → RccmExtraction
//
//  Les deux modèles partagent :
//   - `confidence`  : score 0..1 de la qualité de l'extraction
//   - `rawText`     : texte brut OCR (pour debug / fallback affichage)
//   - `isMock`      : `true` quand le backend n'a pas pu appeler l'IA
//                     (clé absente, quota, fallback simulé)
//
//  Tous les champs métier sont nullables : l'IA peut ne pas retrouver
//  un champ. L'UI doit gérer le cas en proposant la saisie manuelle.
// =====================================================================

import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';

part 'ocr_extraction.freezed.dart';
part 'ocr_extraction.g.dart';

/// Résultat d'extraction d'une pièce d'identité (CNI principalement).
@freezed
class IdentityCardExtraction with _$IdentityCardExtraction {
  const factory IdentityCardExtraction({
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'document_number') String? documentNumber,
    @JsonKey(name: 'birth_date') String? birthDate,
    @JsonKey(name: 'birth_place') String? birthPlace,
    @FlexDouble() @Default(0.0) double confidence,
    @JsonKey(name: 'raw_text') @Default('') String rawText,
    @JsonKey(name: 'is_mock') @Default(false) bool isMock,
  }) = _IdentityCardExtraction;

  factory IdentityCardExtraction.fromJson(Map<String, dynamic> json) =>
      _$IdentityCardExtractionFromJson(json);
}

/// Résultat d'extraction d'une attestation RCCM (registre du commerce).
@freezed
class RccmExtraction with _$RccmExtraction {
  const factory RccmExtraction({
    @JsonKey(name: 'company_name') String? companyName,
    @JsonKey(name: 'rccm_number') String? rccmNumber,
    String? address,
    String? activity,
    @FlexDouble() @Default(0.0) double confidence,
    @JsonKey(name: 'raw_text') @Default('') String rawText,
    @JsonKey(name: 'is_mock') @Default(false) bool isMock,
  }) = _RccmExtraction;

  factory RccmExtraction.fromJson(Map<String, dynamic> json) =>
      _$RccmExtractionFromJson(json);
}
