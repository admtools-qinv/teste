import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Minimal key-value interface for encrypted storage.
///
/// Exists so that [LocalCredentialStore] can be tested without hitting
/// platform channels. In production, use [FlutterSecureStoreAdapter].
/// In tests, use [InMemorySecureStore].
abstract class SecureStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// Production adapter backed by [FlutterSecureStorage].
///
/// On Android, [encryptedSharedPreferences] uses the Android Keystore
/// via EncryptedSharedPreferences (API 23+). On iOS/macOS it uses the
/// system Keychain.
class FlutterSecureStoreAdapter implements SecureStore {
  final FlutterSecureStorage _storage;

  const FlutterSecureStoreAdapter({FlutterSecureStorage? storage})
      : _storage = storage ??
            // ignore: prefer_const_constructors
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// In-memory implementation for unit tests — no platform channels.
class InMemorySecureStore implements SecureStore {
  final Map<String, String> _data = {};

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async => _data[key] = value;

  @override
  Future<void> delete(String key) async => _data.remove(key);
}
