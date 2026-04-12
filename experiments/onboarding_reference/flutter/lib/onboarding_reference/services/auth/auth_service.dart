/// Result returned by a successful [AuthService.login] call.
class AuthResult {
  final String token;

  const AuthResult({required this.token});
}

/// Thrown by [AuthService.login] when authentication fails.
class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

/// Contract for email/password authentication.
///
/// Implement this with your real HTTP client (dio, http, etc.) pointing to
/// your backend's `POST /auth/login` endpoint (or equivalent).
///
/// The example app uses [NoopAuthService], which always succeeds.
abstract class AuthService {
  /// Authenticates the user.
  ///
  /// Returns an [AuthResult] with the session token on success.
  /// Throws [AuthException] with a user-facing message on failure
  /// (wrong password, account not found, server error, etc.).
  Future<AuthResult> login({
    required String email,
    required String password,
  });

  /// Invalidates the server-side session for the given [token].
  /// Silently ignored if the token is already expired.
  Future<void> logout({required String token});
}
