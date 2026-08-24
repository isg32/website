import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// This app talks to Postgres directly (see DbClient) rather than through a
/// backend that verifies a bearer token per request, so this login is
/// purely an app-level gate — "did you type the right password" — not a
/// request-authorization mechanism. On success we just remember "logged in
/// until <TTL>" locally; nothing from Neon Auth is attached to DB queries.
///
/// IMPORTANT: before wiring this up, check the Neon console's Auth tab to
/// see which flavor is actually provisioned (Managed Better Auth vs legacy
/// Stack Auth) and set _NeonAuthFlavor.active below accordingly — see
/// admin_app/README.md.
enum NeonAuthFlavor { managedBetterAuth, legacyStackAuth }

class AuthGateService {
  AuthGateService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _sessionKey = 'admin_session_expires_at';
  static const _sessionTtl = Duration(hours: 12);

  // Set to whichever flavor the Neon console confirms is active.
  static const NeonAuthFlavor activeFlavor = NeonAuthFlavor.managedBetterAuth;

  // Managed Better Auth
  static const _betterAuthBaseUrl = String.fromEnvironment('NEON_AUTH_BASE_URL');

  // Legacy Stack Auth (publishable client key only — never the secret server key)
  static const _stackProjectId = String.fromEnvironment('STACK_PROJECT_ID');
  static const _stackPublishableClientKey = String.fromEnvironment(
    'STACK_PUBLISHABLE_CLIENT_KEY',
  );

  Future<bool> hasValidSession() async {
    final stored = await _storage.read(key: _sessionKey);
    if (stored == null) return false;
    final expiresAt = DateTime.tryParse(stored);
    if (expiresAt == null) return false;
    return DateTime.now().isBefore(expiresAt);
  }

  Future<void> signOut() async {
    await _storage.delete(key: _sessionKey);
  }

  Future<void> signIn({required String email, required String password}) async {
    final success = switch (activeFlavor) {
      NeonAuthFlavor.managedBetterAuth => await _signInBetterAuth(email, password),
      NeonAuthFlavor.legacyStackAuth => await _signInStackAuth(email, password),
    };

    if (!success) {
      throw Exception('Invalid email or password.');
    }

    final expiresAt = DateTime.now().add(_sessionTtl);
    await _storage.write(key: _sessionKey, value: expiresAt.toIso8601String());
  }

  Future<bool> _signInBetterAuth(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_betterAuthBaseUrl/sign-in/email'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Future<bool> _signInStackAuth(String email, String password) async {
    final response = await http.post(
      Uri.parse('https://api.stack-auth.com/api/v1/auth/password/sign-in'),
      headers: {
        'content-type': 'application/json',
        'x-stack-access-type': 'client',
        'x-stack-project-id': _stackProjectId,
        'x-stack-publishable-client-key': _stackPublishableClientKey,
      },
      body: jsonEncode({'email': email, 'password': password}),
    );
    return response.statusCode >= 200 && response.statusCode < 300;
  }
}
