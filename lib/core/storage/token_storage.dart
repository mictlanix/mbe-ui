import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps `flutter_secure_storage` for the mbe-api access token
/// (research.md §5). Used by `AuthNotifier` to restore a session at app
/// start and to clear it on sign-out / session-invalid.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            // Without a paid Apple Developer team, ad-hoc signed local
            // builds can't satisfy the Keychain entitlements the data
            // protection keychain requires on macOS, causing -34018.
            mOptions: MacOsOptions(usesDataProtectionKeychain: false),
          );

  static const _tokenKey = 'access_token';

  final FlutterSecureStorage _storage;

  Future<String?> read() => _storage.read(key: _tokenKey);

  Future<void> write(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> clear() => _storage.delete(key: _tokenKey);
}
