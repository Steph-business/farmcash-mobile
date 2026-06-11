// =====================================================================
//  OcrService — extraction documents (pièce d'identité, RCCM)
//  ---------------------------------------------------------------------
//  Wrapper service-level autour des endpoints backend `/ai/ocr/*`.
//  Upload multipart `file` (champ unique) sur :
//    - POST /ai/ocr/identity-card  → IdentityCardExtraction
//    - POST /ai/ocr/rccm           → RccmExtraction
//
//  Validation backend : JPEG / PNG / WebP, 10 MB max, rate limit 10/h/user.
//  Le service mobile se contente de poster le fichier — pas de pré-check
//  taille/format ici (le backend renvoie un message d'erreur explicite).
//
//  Pattern aligné sur `AuthService.uploadKyc` et
//  `AiService.extractAnnonceFromMedia` (même API multipart Dio).
// =====================================================================

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../api_client/api_client.dart';
import '../api_client/api_endpoints.dart';
import '../models/ocr_extraction.dart';

class OcrService {
  final ApiClient _api;
  OcrService(this._api);

  /// Extrait les champs d'une pièce d'identité (CNI principalement).
  ///
  /// [photo] doit être un JPEG/PNG/WebP < 10 MB. Le content-type est
  /// déduit de l'extension du fichier ; si l'extension est inconnue on
  /// envoie `image/jpeg` par défaut (le backend détecte de toute façon).
  Future<IdentityCardExtraction> extractIdentityCard(
    File photo, {
    void Function(int sent, int total)? progress,
  }) async {
    final form = await _buildForm(photo);
    final json = await _api.upload<Map<String, dynamic>>(
      ApiEndpoints.aiOcrIdentityCard,
      formData: form,
      onSendProgress: progress,
    );
    return IdentityCardExtraction.fromJson(json);
  }

  /// Extrait les champs d'une attestation RCCM.
  ///
  /// Réservé aux rôles BUYER et COOPERATIVE côté backend — un user
  /// FARMER/TRANSPORTER recevra un 403 (cf. guard backend).
  Future<RccmExtraction> extractRccm(
    File photo, {
    void Function(int sent, int total)? progress,
  }) async {
    final form = await _buildForm(photo);
    final json = await _api.upload<Map<String, dynamic>>(
      ApiEndpoints.aiOcrRccm,
      formData: form,
      onSendProgress: progress,
    );
    return RccmExtraction.fromJson(json);
  }

  // ─── Helpers ─────────────────────────────────────────────────────────

  Future<FormData> _buildForm(File photo) async {
    final fileName = photo.path.split(Platform.pathSeparator).last;
    return FormData.fromMap({
      'file': await MultipartFile.fromFile(
        photo.path,
        filename: fileName,
        contentType: MediaType.parse(_guessMime(fileName)),
      ),
    });
  }

  String _guessMime(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic') || lower.endsWith('.heif')) {
      return 'image/heic';
    }
    // Défaut JPEG (camera/galerie iOS+Android en jpg le plus souvent).
    return 'image/jpeg';
  }
}
