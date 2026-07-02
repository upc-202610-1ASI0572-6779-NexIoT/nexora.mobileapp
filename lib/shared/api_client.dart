import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:5001/api/v1';
  static String? _token;

  static Future<String> _getToken() async {
    if (_token != null) return _token!;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/authentication/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'developer@nexora.com',
          'password': 'root',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        if (_token != null) {
          return _token!;
        }
      }
      throw Exception('Failed to sign in. Status: ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error during authentication: $e');
    }
  }

  static Future<http.Response> get(String path) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }

  static Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    return response;
  }

  static Future<http.Response> put(String path, Map<String, dynamic> body) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    return response;
  }
}
