import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000/api';

  static Duration get apiTimeout {
    final ms = int.tryParse(dotenv.env['API_TIMEOUT_MS'] ?? '30000') ?? 30000;
    return Duration(milliseconds: ms);
  }

  static String get environment => dotenv.env['ENV'] ?? 'dev';

  static bool get isDev => environment == 'dev';
  static bool get isStaging => environment == 'staging';
  static bool get isProd => environment == 'prod';

  static const String accessTokenKey = 'fc_access_token';
  static const String refreshTokenKey = 'fc_refresh_token';
  static const String currentUserKey = 'fc_current_user';
}
