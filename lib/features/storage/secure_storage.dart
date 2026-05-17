import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wrapper FlutterSecureStorage côté app.
///
/// Le client API a aussi son propre handle via `ApiClient.storage` —
/// les deux pointent vers le même Keychain/Keystore. Ce wrapper offre
/// juste une API plus haute pour le state Riverpod.
class SecureStorage {
  static const _options = AndroidOptions(encryptedSharedPreferences: true);
  final FlutterSecureStorage _storage;

  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(aOptions: _options);

  Future<String?> read(String key) => _storage.read(key: key);
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
  Future<void> delete(String key) => _storage.delete(key: key);
  Future<void> deleteAll() => _storage.deleteAll();
}

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});
