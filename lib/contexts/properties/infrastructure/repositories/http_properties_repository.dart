import 'package:nexoraiot/contexts/properties/domain/entities/app_data.dart';
import 'package:nexoraiot/contexts/properties/domain/repositories/properties_repository.dart';
import 'package:nexoraiot/contexts/properties/infrastructure/datasources/fake_nexora_api.dart';
import 'package:nexoraiot/contexts/properties/infrastructure/datasources/properties_api_service.dart';
import 'package:nexoraiot/contexts/devices/infrastructure/repositories/http_devices_repository.dart';

class HttpPropertiesRepository implements PropertiesRepository {
  final PropertiesApiService _propertiesApi;
  final HttpDevicesRepository _devicesRepository;
  final FakeNexoraApi _fakeApi;

  HttpPropertiesRepository({
    PropertiesApiService? propertiesApi,
    HttpDevicesRepository? devicesRepository,
    FakeNexoraApi? fakeApi,
  })  : _propertiesApi = propertiesApi ?? PropertiesApiService(),
        _devicesRepository = devicesRepository ?? HttpDevicesRepository(),
        _fakeApi = fakeApi ?? FakeNexoraApi();

  @override
  Future<AppData> getDashboardData() async {
    try {
      // 1. Fetch real properties
      final properties = await _propertiesApi.getProperties();
      
      // 2. Fetch real devices
      final devices = await _devicesRepository.getDevices();

      // 3. Get mock baseline AppData
      final mockData = await _fakeApi.getDashboardData();

      // 4. Extract real user and home names if properties are available
      String userName = mockData.userName;
      String homeName = mockData.homeName;

      if (properties.isNotEmpty) {
        final firstProp = properties.first;
        userName = '${firstProp.landlord.firstName} ${firstProp.landlord.lastName}';
        homeName = firstProp.name;
      }

      // 5. Categorize real devices to match AppData structure
      final gasSensors = devices.where((d) => d.sensorType == 'Gas').toList();
      final airQuality = devices.where((d) => d.sensorType == 'Air Quality').toList();
      final humidity = devices.where((d) => d.sensorType == 'Humidity').toList();

      return AppData(
        userName: userName,
        homeName: homeName,
        waterToday: mockData.waterToday,
        energyToday: mockData.energyToday,
        latest24h: mockData.latest24h,
        gasSensors: gasSensors,
        airQuality: airQuality,
        humidity: humidity,
        incidents: mockData.incidents,
        consumption: mockData.consumption,
        automations: mockData.automations,
      );
    } catch (e) {
      // Fallback to fake data in case of error, or we can rethrow
      // Let's rethrow to propagate connection issues, or gracefully fall back
      // Since local debugging could have backend offline, falling back makes it robust
      // but rethrowing helps identify configuration issues. Let's rethrow.
      rethrow;
    }
  }
}
