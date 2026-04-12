import 'package:shared_preferences/shared_preferences.dart';

import 'secure_store.dart';

/// Persists login-related data locally on the device.
///
/// - **Email** and **biometric preference** → [SharedPreferences]
///   (fast, synchronous read after first load; backed up by OS on iOS if
///   NSUbiquitousKeyValueStore is configured, or lost on uninstall on Android).
/// - **Auth token** → [SecureStore] (Android Keystore via EncryptedSharedPreferences;
///   iOS/macOS Keychain). Never stored in plain SharedPreferences.
///
/// Initialization (call once in `main()` before `runApp`):
/// ```dart
/// final prefs = await SharedPreferences.getInstance();
/// final store = LocalCredentialStore(prefs: prefs);
/// ```
///
/// For tests, pass an [InMemorySecureStore]:
/// ```dart
/// SharedPreferences.setMockInitialValues({});
/// final prefs = await SharedPreferences.getInstance();
/// final store = LocalCredentialStore(prefs: prefs, secureStore: InMemorySecureStore());
/// ```
class LocalCredentialStore {
  static const _kEmail = 'qinv_saved_email';
  static const _kDisplayName = 'qinv_display_name';
  static const _kBiometricEnabled = 'qinv_biometric_enabled';
  static const _kBiometricAsked = 'qinv_biometric_asked';
  static const _kToken = 'qinv_auth_token';

  final SharedPreferences _prefs;
  final SecureStore _secure;

  LocalCredentialStore({
    required SharedPreferences prefs,
    SecureStore? secureStore,
  })  : _prefs = prefs,
        _secure = secureStore ?? const FlutterSecureStoreAdapter();

  // ── Synchronous getters (SharedPreferences is cached in memory) ──

  /// The last successfully logged-in email, or null if none was saved.
  String? get savedEmail => _prefs.getString(_kEmail);

  /// Display name returned by the backend after login (e.g. "Fabricio").
  /// Falls back to null if not yet saved.
  String? get displayName => _prefs.getString(_kDisplayName);

  /// Whether the user has opted in to biometric login.
  bool get isBiometricEnabled => _prefs.getBool(_kBiometricEnabled) ?? false;

  /// True once the biometric prompt has been shown, regardless of the user's
  /// choice. Used to avoid showing [BiometricPromptScreen] more than once.
  bool get hasBiometricBeenAsked => _prefs.getBool(_kBiometricAsked) ?? false;

  // ── Writes ────────────────────────────────────────────────────────

  Future<void> saveEmail(String email) =>
      _prefs.setString(_kEmail, email);

  Future<void> saveDisplayName(String name) =>
      _prefs.setString(_kDisplayName, name);

  /// Persists the biometric preference AND marks the prompt as answered.
  Future<void> setBiometricEnabled({required bool enabled}) async {
    await _prefs.setBool(_kBiometricEnabled, enabled);
    await _prefs.setBool(_kBiometricAsked, true);
  }

  /// Marks that the biometric prompt has been shown without changing the
  /// [isBiometricEnabled] flag (e.g. the user dismissed without deciding).
  Future<void> markBiometricAsked() =>
      _prefs.setBool(_kBiometricAsked, true);

  // ── Secure token ──────────────────────────────────────────────────

  Future<String?> getToken() => _secure.read(_kToken);

  Future<void> saveToken(String token) => _secure.write(_kToken, token);

  // ── Logout / wipe ─────────────────────────────────────────────────

  /// Clears session data (biometric flags + token) but retains the saved
  /// email so the next login pre-fills the field.
  Future<void> clearSession() async {
    await _prefs.remove(_kBiometricEnabled);
    await _prefs.remove(_kBiometricAsked);
    await _secure.delete(_kToken);
  }

  /// Full wipe — call on account deletion or explicit "forget this device".
  Future<void> clearAll() async {
    await _prefs.remove(_kEmail);
    await _prefs.remove(_kBiometricEnabled);
    await _prefs.remove(_kBiometricAsked);
    await _secure.delete(_kToken);
  }
}
