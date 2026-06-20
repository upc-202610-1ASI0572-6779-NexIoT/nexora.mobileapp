import 'package:nexoraiot/contexts/properties/domain/entities/app_data.dart';

abstract class PropertiesRepository {
  Future<AppData> getDashboardData();
}
