import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://backend.vision-optique.com/api';
  static const String _tokenKey = 'auth_token';

  static Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }

  static Map<String, String> _getHeaders() {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    final headers = _getHeaders();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');

      // Use basic headers for login/register, auth headers for other endpoints
      final headers =
          (endpoint == 'auth/login' || endpoint == 'auth/register')
              ? _getHeaders()
              : await _getAuthHeaders();

      final response = await http
          .post(url, headers: headers, body: jsonEncode(data))
          .timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body);

      // For login, save the new token if successful
      if (endpoint == 'auth/login' &&
          response.statusCode == 200 &&
          responseData['success'] == true) {
        try {
          if (responseData['token'] != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_tokenKey, responseData['token']);
          }
        } catch (e) {
          print('Failed to save token from login response: $e');
        }
      }

      // Check for 401 only for non-auth endpoints
      if (response.statusCode == 401 && !endpoint.startsWith('auth/')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_tokenKey);
        return {
          'success': false,
          'message': 'Session expirée. Veuillez vous reconnecter.',
        };
      }

      return responseData;
    } catch (e) {
      return {'success': false, 'message': 'Erreur de requête: $e'};
    }
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final headers = await _getAuthHeaders();

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 401) {
        // Token expired or invalid
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_tokenKey);
        return {
          'success': false,
          'message': 'Session expirée. Veuillez vous reconnecter.',
        };
      }

      return responseData;
    } catch (e) {
      return {'success': false, 'message': 'Erreur de requête: $e'};
    }
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final headers = await _getAuthHeaders();

      final response = await http
          .delete(url, headers: headers)
          .timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 401) {
        // Token expired or invalid
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_tokenKey);
        return {
          'success': false,
          'message': 'Session expirée. Veuillez vous reconnecter.',
        };
      }

      return responseData;
    } catch (e) {
      return {'success': false, 'message': 'Erreur de suppression: $e'};
    }
  }

  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final headers = await _getAuthHeaders();

      final response = await http
          .put(url, headers: headers, body: jsonEncode(data))
          .timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_tokenKey);
        return {
          'success': false,
          'message': 'Session expirée. Veuillez vous reconnecter.',
        };
      }

      return responseData;
    } catch (e) {
      return {'success': false, 'message': 'Erreur de modification: $e'};
    }
  }
}
