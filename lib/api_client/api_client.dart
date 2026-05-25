import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../constants/app_constants.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';

/// Client HTTP central de l'app.
///
/// Toute la couche service doit passer par cette instance — JAMAIS d'appel
/// direct à `Dio()` ailleurs. Cela garantit :
/// - JWT injecté automatiquement
/// - Refresh transparent sur 401
/// - Exceptions normalisées via `ApiException.fromDio`
/// - Logs lisibles en dev
class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiClient._(this._dio, this._storage);

  Dio get dio => _dio;
  FlutterSecureStorage get storage => _storage;

  /// [onAuthFailure] est appelé quand le refresh token est invalide
  /// (à brancher sur la navigation pour rediriger vers /login).
  factory ApiClient.create({OnAuthFailure? onAuthFailure}) {
    final storage = const FlutterSecureStorage();
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        sendTimeout: AppConstants.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        responseType: ResponseType.json,
        // On garde le défaut Dio (`status < 400`) — toute 4xx/5xx devient
        // une DioException native. C'est CRITIQUE pour que les 401
        // déclenchent `AuthInterceptor.onError` (qui fait le refresh
        // automatique). Un `validateStatus` plus permissif (< 500)
        // bypass-ait le onError → le refresh ne tournait jamais et
        // l'utilisateur voyait l'erreur brute "Token JWT invalide".
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        storage: storage,
        onAuthFailure: onAuthFailure,
      ),
    );

    if (AppConstants.isDev) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: false,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          compact: true,
          maxWidth: 100,
        ),
      );
    }

    // L'unwrap d'enveloppe NestJS est fait dans _unwrap() ci-dessous.
    // Pas besoin d'interceptor de conversion 4xx → DioException ici :
    // avec le `validateStatus` par défaut, Dio le fait nativement.

    return ApiClient._(dio, storage);
  }

  // ─── Helpers HTTP typés ──────────────────────────────────────────────

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _wrap(() async {
        final res = await _dio.get<dynamic>(
          path,
          queryParameters: query,
          options: options,
          cancelToken: cancelToken,
        );
        return _unwrap<T>(res.data);
      });

  Future<T> post<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _wrap(() async {
        final res = await _dio.post<dynamic>(
          path,
          data: body,
          queryParameters: query,
          options: options,
          cancelToken: cancelToken,
        );
        return _unwrap<T>(res.data);
      });

  Future<T> put<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _wrap(() async {
        final res = await _dio.put<dynamic>(
          path,
          data: body,
          queryParameters: query,
          options: options,
          cancelToken: cancelToken,
        );
        return _unwrap<T>(res.data);
      });

  Future<T> patch<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _wrap(() async {
        final res = await _dio.patch<dynamic>(
          path,
          data: body,
          queryParameters: query,
          options: options,
          cancelToken: cancelToken,
        );
        return _unwrap<T>(res.data);
      });

  Future<T> delete<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _wrap(() async {
        final res = await _dio.delete<dynamic>(
          path,
          data: body,
          queryParameters: query,
          options: options,
          cancelToken: cancelToken,
        );
        return _unwrap<T>(res.data);
      });

  /// Upload multipart (analyses plantes, médias annonces, etc.).
  Future<T> upload<T>(
    String path, {
    required FormData formData,
    Map<String, dynamic>? query,
    Options? options,
    void Function(int sent, int total)? onSendProgress,
    CancelToken? cancelToken,
  }) =>
      _wrap(() async {
        final res = await _dio.post<dynamic>(
          path,
          data: formData,
          queryParameters: query,
          options: options,
          onSendProgress: onSendProgress,
          cancelToken: cancelToken,
        );
        return _unwrap<T>(res.data);
      });

  /// Désenroule l'enveloppe NestJS standard et caste vers `T`.
  ///
  /// Le backend renvoie systématiquement :
  /// ```json
  /// { "success": true, "data": <payload>, "timestamp": "..." }
  /// ```
  /// On extrait `data` et on convertit récursivement les `Map` imbriquées
  /// en `Map<String,dynamic>` pour que les `fromJson` Freezed/json_serializable
  /// (qui font des casts stricts) fonctionnent sans Type'cast error'.
  T _unwrap<T>(dynamic raw) {
    dynamic payload = raw;
    if (raw is Map &&
        raw['success'] == true &&
        raw.containsKey('data')) {
      payload = raw['data'];
    }
    return _normalizeJson(payload) as T;
  }

  /// Convertit récursivement les `Map` et `List` pour matcher les types
  /// génériques attendus par json_serializable (`Map<String,dynamic>` /
  /// `List<dynamic>`). Inutile sur les types primitifs.
  dynamic _normalizeJson(dynamic value) {
    if (value is Map) {
      return value.map<String, dynamic>(
        (k, v) => MapEntry(k.toString(), _normalizeJson(v)),
      );
    }
    if (value is List) {
      return value.map(_normalizeJson).toList();
    }
    return value;
  }

  Future<T> _wrap<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: e.toString(),
        type: ApiExceptionType.unknown,
      );
    }
  }
}
