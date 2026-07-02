import 'package:nexoraiot/contexts/devices/domain/entities/device_sensor.dart';
import 'package:nexoraiot/contexts/devices/domain/repositories/devices_repository.dart';
import 'package:nexoraiot/contexts/devices/infrastructure/api/devices_api_service.dart';

class HttpDevicesRepository implements DevicesRepository {
  final DevicesApiService _apiService;

  HttpDevicesRepository({
    DevicesApiService? apiService,
  }) : _apiService = apiService ?? DevicesApiService();

  @override
  Future<List<DeviceSensor>> getDevices() async {
    try {
      final backendDevices = await _apiService.getDevices();

      return backendDevices.map((dto) {
        final id = dto.id.toLowerCase();
        final isConnected = dto.connectionStatus.toLowerCase() == 'online';
        final room = dto.propertyName;

        // Classify sensor properties based on ID
        if (id.contains('gas')) {
          return DeviceSensor(
            'Gas Safety Unit',
            'Kitchen Sensor',
            isConnected ? 'No leaks' : 'Offline',
            !isConnected, // Alert if disconnected or leak
            room,
            isConnected,
            _formatLastSeen(dto.lastSyncAt),
            'Gas',
          );
        } else if (id.contains('voltage')) {
          return DeviceSensor(
            'Voltage Safety Unit',
            'Main Panel',
            isConnected ? '220 V' : 'Offline',
            !isConnected,
            room,
            isConnected,
            _formatLastSeen(dto.lastSyncAt),
            'Humidity', // Map to Humidity section in UI
          );
        } else {
          // gateway or other device
          final isCritical = id.contains('san-isidro-02') || !isConnected;
          return DeviceSensor(
            id.contains('skyline') ? 'Safety Gateway Skyline' : 'Safety Gateway San Isidro',
            id.contains('skyline') ? 'Sector A' : 'Sector B',
            isConnected ? 'Optimal' : 'Offline',
            isCritical,
            room,
            isConnected,
            _formatLastSeen(dto.lastSyncAt),
            'Air Quality', // Map to Air Quality section in UI
          );
        }
      }).toList();
    } catch (e) {
      // Fallback or rethrow
      rethrow;
    }
  }

  String _formatLastSeen(String rawDate) {
    if (rawDate.isEmpty) return 'Never';
    try {
      final parsed = DateTime.parse(rawDate).toLocal();
      final now = DateTime.now();
      final diff = now.difference(parsed);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return 'Recently';
    }
  }
}
