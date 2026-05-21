import 'dart:convert';
import 'api_client.dart';
import 'constants.dart';
import 'storage_helper.dart';
import 'user_model.dart';

class AuthService {
  static UserModel? _currentUser;

  /// Get the currently logged-in user
  static UserModel? get currentUser => _currentUser;

  /// Check if the user is authenticated (checks if access token exists)
  static Future<bool> isAuthenticated() async {
    final token = await StorageHelper.getAccessToken();
    return token != null;
  }

  /// Perform login call
  static Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await ApiClient.post(
        AppConstants.loginEndpoint,
        {
          'username': username,
          'password': password,
        },
        requiresAuth: false,
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final accessToken = responseData['access_token'] as String;
        final refreshToken = responseData['refresh_token'] as String;
        final userJson = responseData['user'] as Map<String, dynamic>;

        // Store tokens
        await StorageHelper.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        // Parse user profile
        _currentUser = UserModel.fromJson(userJson);

        return AuthResult(
          success: true,
          message: responseData['message'] ?? 'Login successful',
          user: _currentUser,
        );
      } else {
        final errorMessage = responseData['error'] ?? responseData['detail'] ?? 'Authentication failed';
        return AuthResult(
          success: false,
          message: errorMessage.toString(),
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'An error occurred: $e',
      );
    }
  }

  /// Logout
  static Future<void> logout() async {
    await StorageHelper.clearTokens();
    _currentUser = null;
  }
}

class AuthResult {
  final bool success;
  final String message;
  final UserModel? user;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
  });
}
