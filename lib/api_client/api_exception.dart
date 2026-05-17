import 'package:dio/dio.dart';

/// Exception structurée renvoyée à la couche UI/state.
///
/// Toujours préférer attraper `ApiException` plutôt que `DioException`
/// dans les services/providers : on perd ainsi tous les détails Dio mais
/// on gagne un message déjà formaté pour l'utilisateur.
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final String? errorCode;
  final Map<String, dynamic>? details;
  final ApiExceptionType type;

  const ApiException({
    required this.message,
    required this.type,
    this.statusCode,
    this.errorCode,
    this.details,
  });

  factory ApiException.fromDio(DioException e) {
    final response = e.response;
    final data = response?.data;

    String? messageFromBackend;
    String? code;
    Map<String, dynamic>? details;

    if (data is Map<String, dynamic>) {
      // Le backend NestJS enveloppe parfois l'erreur dans `error: {...}`
      // (format custom) au lieu du message à la racine (format Nest natif).
      // On tente les deux pour rester tolérant.
      final nested = data['error'];
      final rootMessage = data['message'];

      dynamic raw;
      if (rootMessage != null) {
        raw = rootMessage;
      } else if (nested is Map) {
        raw = nested['message'];
      }

      if (raw is String) {
        messageFromBackend = raw;
      } else if (raw is List && raw.isNotEmpty) {
        messageFromBackend = raw.join(', ');
      }

      if (nested is Map) {
        code = (nested['error'] ?? nested['code'])?.toString();
      }
      code ??= (data['error'] is String ? data['error'] as String : null) ??
          data['code']?.toString();
      details = data;
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Délai de connexion dépassé. Vérifiez votre réseau.',
          type: ApiExceptionType.timeout,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Impossible de joindre le serveur.',
          type: ApiExceptionType.network,
        );
      case DioExceptionType.cancel:
        return ApiException(
          message: 'Requête annulée.',
          type: ApiExceptionType.cancel,
        );
      case DioExceptionType.badCertificate:
        return ApiException(
          message: 'Certificat SSL invalide.',
          type: ApiExceptionType.network,
        );
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        final status = response?.statusCode;
        return ApiException(
          statusCode: status,
          errorCode: code,
          details: details,
          message: messageFromBackend ?? _defaultMessageForStatus(status),
          type: _typeForStatus(status),
        );
    }
  }

  static String _defaultMessageForStatus(int? status) {
    switch (status) {
      case 400:
        return 'Requête invalide.';
      case 401:
        return 'Session expirée, veuillez vous reconnecter.';
      case 403:
        return 'Accès refusé.';
      case 404:
        return 'Ressource introuvable.';
      case 409:
        return 'Conflit avec une ressource existante.';
      case 422:
        return 'Données invalides.';
      case 429:
        return 'Trop de tentatives. Réessayez plus tard.';
      case 500:
      case 502:
      case 503:
        return 'Erreur serveur. Réessayez dans un instant.';
      default:
        return 'Une erreur est survenue.';
    }
  }

  static ApiExceptionType _typeForStatus(int? status) {
    if (status == null) return ApiExceptionType.unknown;
    if (status == 401) return ApiExceptionType.unauthorized;
    if (status == 403) return ApiExceptionType.forbidden;
    if (status == 404) return ApiExceptionType.notFound;
    if (status == 422 || status == 400) return ApiExceptionType.validation;
    if (status == 429) return ApiExceptionType.rateLimit;
    if (status >= 500) return ApiExceptionType.server;
    return ApiExceptionType.unknown;
  }

  bool get isUnauthorized => type == ApiExceptionType.unauthorized;
  bool get isNetwork =>
      type == ApiExceptionType.network || type == ApiExceptionType.timeout;

  @override
  String toString() =>
      'ApiException($statusCode, $type${errorCode != null ? ', $errorCode' : ''}): $message';
}

enum ApiExceptionType {
  network,
  timeout,
  cancel,
  unauthorized,
  forbidden,
  notFound,
  validation,
  rateLimit,
  server,
  unknown,
}
