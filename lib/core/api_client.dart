import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'storage_helper.dart';

class ApiClient {
  static final http.Client _client = http.Client();

  /// Create base headers, appending the auth token if present
  static Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await StorageHelper.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// POST request
  static Future<http.Response> post(String endpoint, Map<String, dynamic> body, {bool requiresAuth = true}) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    
    try {
      final response = await _client.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw Exception('Connection failed: $e');
    }
  }

  /// GET request
  static Future<http.Response> get(String endpoint, {bool requiresAuth = true}) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    final headers = await _getHeaders(requiresAuth: requiresAuth);

    try {
      final response = await _client.get(
        url,
        headers: headers,
      );
      return response;
    } catch (e) {
      throw Exception('Connection failed: $e');
    }
  }
}
