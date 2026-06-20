import 'package:nexoraiot/contexts/properties/infrastructure/datasources/fake_nexora_api.dart';
import 'package:nexoraiot/contexts/properties/domain/entities/app_data.dart';
import 'package:nexoraiot/contexts/properties/domain/repositories/properties_repository.dart';

class FakePropertiesRepository implements PropertiesRepository {
  final FakeNexoraApi _api;

  FakePropertiesRepository({
    FakeNexoraApi? api,
  }) : _api = api ?? FakeNexoraApi();

  @override
  Future<AppData> getDashboardData() {
    return _api.getDashboardData();
  }
}
