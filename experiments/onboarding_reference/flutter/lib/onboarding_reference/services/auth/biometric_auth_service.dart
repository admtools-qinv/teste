import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

// ── Failure reasons ───────────────────────────────────────────────

/// Typed reason for a biometric authentication failure.
///
/// Allows the UI to show specific messages without parsing error strings.
enum BiometricFailureReason {
  /// Device has no biometric hardware (or hardware is unavailable).
  notAvailable,

  /// Hardware present, but no biometrics are enrolled.
  /// Guide the user to enroll in device Settings.
  notEnrolled,

  /// Too many failed attempts — temporary lockout.
  /// User can retry after a short delay.
  lockedOut,

  /// Permanent lockout — biometrics disabled until the user authenticates
  /// with their device PIN/pattern/password.
  permanentlyLockedOut,

  /// Device has no PIN/pattern/password set, which is required as a fallback.
  passcodeNotSet,

  /// Unknown or unhandled platform error.
  unknown,
}

/// Thrown by [BiometricAuthService] when authentication cannot proceed.
///
/// Note: user **cancellation** of the OS dialog is NOT an exception — it is
/// signalled by [BiometricAuthService.authenticate] returning `false`.
class BiometricException implements Exception {
  final BiometricFailureReason reason;
  final String? platformCode;

  const BiometricException(this.reason, {this.platformCode});

  @override
  String toString() =>
      'BiometricException(reason: $reason, platformCode: $platformCode)';
}

// ── Abstract interface ────────────────────────────────────────────

/// Abstraction over the `local_auth` plugin, enabling full widget-test
/// coverage without hitting platform channels.
abstract class BiometricAuthService {
  /// Returns true if the device has biometric hardware AND at least one
  /// biometric is enrolled.
  Future<bool> isAvailable();

  /// Prompts the user to authenticate.
  ///
  /// - Returns `true` on success.
  /// - Returns `false` if the user dismisses / cancels the OS dialog.
  /// - Throws [BiometricException] for system errors (not enrolled, locked
  ///   out, hardware unavailable, etc.).
  Future<bool> authenticate({required String localizedReason});
}

// ── Production implementation ─────────────────────────────────────

/// Production [BiometricAuthService] backed by the `local_auth` plugin.
///
/// **iOS setup required:** Add to `ios/Runner/Info.plist`:
/// ```xml
/// <key>NSFaceIDUsageDescription</key>
/// <string>Use Face ID to sign in to Qinv quickly and securely.</string>
/// ```
/// Without this key, Face ID will throw at runtime on iOS.
///
/// **Android setup:** `USE_BIOMETRIC` + `USE_FINGERPRINT` permissions are
/// already declared in `AndroidManifest.xml`.
///
/// **Error code reference:**
/// | Code (Android)            | Code (iOS)                      | Reason         |
/// |---------------------------|---------------------------------|----------------|
/// | `NotAvailable`            | `LAErrorBiometryNotAvailable`   | notAvailable   |
/// | `NotEnrolled`             | `LAErrorBiometryNotEnrolled`    | notEnrolled    |
/// | `LockedOut`               | `LAErrorBiometryLockout`        | lockedOut      |
/// | `PermanentlyLockedOut`    | (LAErrorBiometryLockout repeat) | permLockedOut  |
/// | `passcodeNotSet`          | `LAErrorPasscodeNotSet`         | passcodeNotSet |
class LocalAuthBiometricService implements BiometricAuthService {
  final LocalAuthentication _auth;

  LocalAuthBiometricService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  @override
  Future<bool> isAvailable() async {
    final canCheck = await _auth.canCheckBiometrics;
    if (canCheck) return true;
    return _auth.isDeviceSupported();
  }

  @override
  Future<bool> authenticate({required String localizedReason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          // false = allows device PIN/pattern as fallback within the OS dialog.
          // On iOS this still shows Touch ID / Face ID first.
          biometricOnly: false,
          // stickyAuth = keeps the prompt alive if the user switches apps
          // and comes back (Android-only; ignored on iOS).
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      throw BiometricException(_mapCode(e.code), platformCode: e.code);
    }
  }

  static BiometricFailureReason _mapCode(String code) {
    switch (code) {
      // ── Android codes ──────────────────────────────────────────
      case 'NotAvailable':
        return BiometricFailureReason.notAvailable;
      case 'NotEnrolled':
        return BiometricFailureReason.notEnrolled;
      case 'LockedOut':
        return BiometricFailureReason.lockedOut;
      case 'PermanentlyLockedOut':
        return BiometricFailureReason.permanentlyLockedOut;
      case 'passcodeNotSet':
        return BiometricFailureReason.passcodeNotSet;

      // ── iOS / macOS LAError codes ──────────────────────────────
      case 'LAErrorBiometryNotAvailable':
        return BiometricFailureReason.notAvailable;
      case 'LAErrorBiometryNotEnrolled':
        return BiometricFailureReason.notEnrolled;
      case 'LAErrorBiometryLockout':
        // Repeated failures on iOS eventually become permanent lockout;
        // treat all LAErrorBiometryLockout as lockedOut and let the OS
        // manage the permanent→PIN redirect via its own dialog.
        return BiometricFailureReason.lockedOut;
      case 'LAErrorPasscodeNotSet':
        return BiometricFailureReason.passcodeNotSet;

      default:
        return BiometricFailureReason.unknown;
    }
  }
}
