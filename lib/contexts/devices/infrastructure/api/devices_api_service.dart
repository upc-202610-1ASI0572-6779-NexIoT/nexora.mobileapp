import 'dart:convert';
import 'package:nexoraiot/shared/api_client.dart';

class DeviceBackendDto {
  final String id;
  final String connectionStatus;
  final String lastSyncAt;
  final int propertyId;
  final String propertyName;

  DeviceBackendDto({
    required this.id,
    required this.connectionStatus,
    required this.lastSyncAt,
    required this.propertyId,
    required this.propertyName,
  });

  factory DeviceBackendDto.fromJson(Map<String, dynamic> json) {
    return DeviceBackendDto(
      id: json['id'] ?? '',
      connectionStatus: json['connectionStatus'] ?? 'Offline',
      lastSyncAt: json['lastSyncAt'] ?? '',
      propertyId: json['propertyId'] ?? 0,
      propertyName: json['propertyName'] ?? 'Unassigned',
    );
  }
}

class DevicesApiService {
  Future<List<DeviceBackendDto>> getDevices() async {
    final response = await ApiClient.get('/devices');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => DeviceBackendDto.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load devices from backend. Status: ${response.statusCode}');
    }
  }
}
