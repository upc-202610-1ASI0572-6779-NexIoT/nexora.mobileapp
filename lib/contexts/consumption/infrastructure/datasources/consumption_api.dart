import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:nexoraiot/app/config/app_config.dart';

/// Thin HTTP client for the Nexora consumption/reports endpoints.
class ConsumptionApi {
  final http.Client _client;
  final String _baseUrl;

  ConsumptionApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  /// GET /api/v1/reports/consumption?metric=&range=
  Future<Map<String, dynamic>> fetchConsumption({
    required String metric,
    required String range,
    String? deviceId,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/reports/consumption').replace(
      queryParameters: {
        'metric': metric,
        'range': range,
        if (deviceId != null && deviceId.isNotEmpty) 'deviceId': deviceId,
      },
    );

    final response = await _client
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw ConsumptionApiException(
        'Request failed (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ConsumptionApiException('Unexpected response format');
    }
    return decoded;
  }

  /// GET /api/v1/telemetries/latest?deviceId=
  /// Returns the latest raw reading for a device, or null when none exists yet.
  Future<Map<String, dynamic>?> fetchLatest(String deviceId) async {
    final uri = Uri.parse('$_baseUrl/api/v1/telemetries/latest').replace(
      queryParameters: {'deviceId': deviceId},
    );

    final response = await _client
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw ConsumptionApiException(
        'Request failed (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ConsumptionApiException('Unexpected response format');
    }
    return decoded;
  }
}

class ConsumptionApiException implements Exception {
  final String message;
  final int? statusCode;

  const ConsumptionApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
