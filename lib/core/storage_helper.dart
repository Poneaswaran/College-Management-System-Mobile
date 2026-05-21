// Helper class for secure storage of JWT tokens.
// In production, configure this to use flutter_secure_storage package.
class StorageHelper {
  static String? _accessToken;
  static String? _refreshToken;
  static Map<String, String> _inMemoryStorage = {};

  /// Save the access and refresh tokens
  static Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _inMemoryStorage['access_token'] = accessToken;
    _inMemoryStorage['refresh_token'] = refreshToken;
  }

  /// Get the saved access token
  static Future<String?> getAccessToken() async {
    return _accessToken ?? _inMemoryStorage['access_token'];
  }

  /// Get the saved refresh token
  static Future<String?> getRefreshToken() async {
    return _refreshToken ?? _inMemoryStorage['refresh_token'];
  }

  /// Clear tokens (used on logout)
  static Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _inMemoryStorage.clear();
  }

  /// Save string key-value pairs
  static Future<void> write(String key, String value) async {
    _inMemoryStorage[key] = value;
  }

  /// Read string value by key
  static Future<String?> read(String key) async {
    return _inMemoryStorage[key];
  }

  /// Delete value by key
  static Future<void> delete(String key) async {
    _inMemoryStorage.remove(key);
  }
}
