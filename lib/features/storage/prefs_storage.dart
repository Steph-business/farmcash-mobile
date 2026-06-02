import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Préférences non-sensibles : langue, thème, onboarding seen, etc.
///
/// Pour les tokens, utiliser SecureStorage à la place.
class PrefsStorage {
  final SharedPreferences _prefs;

  PrefsStorage(this._prefs);

  static const _kLocale = 'fc_locale';
  static const _kThemeMode = 'fc_theme_mode';
  static const _kOnboardingSeen = 'fc_onboarding_seen';
  static const _kNegociationsLastSeen = 'fc_negociations_last_seen_ms';

  String? get locale => _prefs.getString(_kLocale);
  Future<bool> setLocale(String value) => _prefs.setString(_kLocale, value);

  String? get themeMode => _prefs.getString(_kThemeMode);
  Future<bool> setThemeMode(String value) =>
      _prefs.setString(_kThemeMode, value);

  bool get onboardingSeen => _prefs.getBool(_kOnboardingSeen) ?? false;
  Future<bool> setOnboardingSeen(bool value) =>
      _prefs.setBool(_kOnboardingSeen, value);

  /// Timestamp (epoch ms) de la dernière fois où l'utilisateur a ouvert
  /// la page Négociations. Sert à distinguer les propositions vues
  /// (avant ce timestamp) des nouvelles (après). Le badge sur la tuile
  /// décrémente automatiquement dès qu'on entre dans la page.
  DateTime? get negociationsLastSeen {
    final ms = _prefs.getInt(_kNegociationsLastSeen);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<bool> setNegociationsLastSeen(DateTime when) =>
      _prefs.setInt(_kNegociationsLastSeen, when.millisecondsSinceEpoch);
}

/// Provider initialisé par override dans main.dart après `SharedPreferences.getInstance()`.
final prefsStorageProvider = Provider<PrefsStorage>((ref) {
  throw UnimplementedError(
    'prefsStorageProvider must be overridden in ProviderScope',
  );
});
