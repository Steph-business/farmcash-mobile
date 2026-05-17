import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';
import 'api_endpoints.dart';

typedef OnAuthFailure = void Function();

/// Interceptor JWT :
/// - Ajoute `Authorization: Bearer <access>` sur chaque requête.
/// - Sur 401, tente un refresh une seule fois puis rejoue la requête.
/// - Sur échec du refresh, supprime les tokens et notifie via [onAuthFailure].
class AuthInterceptor extends QueuedInterceptor {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  final OnAuthFailure? onAuthFailure;

  AuthInterceptor({
    required Dio dio,
    FlutterSecureStorage? storage,
    this.onAuthFailure,
  })  : _dio = dio,
        _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final skip = options.extra['skipAuth'] == true;
    if (!skip) {
      final token = await _storage.read(key: AppConstants.accessTokenKey);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final isUnauthorized = response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra['retried'] == true;
    final isRefreshCall =
        err.requestOptions.path.endsWith(ApiEndpoints.authRefresh);

    if (!isUnauthorized || alreadyRetried || isRefreshCall) {
      return handler.next(err);
    }

    final refreshToken =
        await _storage.read(key: AppConstants.refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) {
      await _clearTokens();
      onAuthFailure?.call();
      return handler.next(err);
    }

    try {
      final refreshResponse = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.authRefresh,
        data: {'refresh_token': refreshToken},
        options: Options(extra: {'skipAuth': true}),
      );

      final data = refreshResponse.data;
      final newAccess =
          data?['access_token'] as String? ?? data?['accessToken'] as String?;
      final newRefresh =
          data?['refresh_token'] as String? ?? data?['refreshToken'] as String?;

      if (newAccess == null) {
        throw StateError('Refresh response missing access token');
      }

      await _storage.write(
        key: AppConstants.accessTokenKey,
        value: newAccess,
      );
      if (newRefresh != null) {
        await _storage.write(
          key: AppConstants.refreshTokenKey,
          value: newRefresh,
        );
      }

      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $newAccess';
      retryOptions.extra['retried'] = true;

      final cloned = await _dio.fetch<dynamic>(retryOptions);
      return handler.resolve(cloned);
    } catch (_) {
      await _clearTokens();
      onAuthFailure?.call();
      return handler.next(err);
    }
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }
}
