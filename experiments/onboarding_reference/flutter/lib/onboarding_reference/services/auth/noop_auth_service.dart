import 'auth_service.dart';

/// Stub implementation of [AuthService] for the example app and tests.
///
/// Always succeeds with a fake token after a short delay.
/// Replace with [RemoteAuthService] (or your own implementation) in production.
class NoopAuthService implements AuthService {
  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    // Simulate network latency so loading states are visible during dev.
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return const AuthResult(token: 'noop-token-example');
  }

  @override
  Future<void> logout({required String token}) async {}
}
