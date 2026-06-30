import 'package:nexoraiot/contexts/alerts/domain/entities/incident.dart';
import 'package:nexoraiot/contexts/alerts/domain/repositories/alerts_repository.dart';
import 'package:nexoraiot/contexts/properties/domain/entities/app_data.dart';

class AppDataAlertsRepository implements AlertsRepository {
  final AppData data;

  const AppDataAlertsRepository(this.data);

  @override
  Future<List<Incident>> getAlerts() async {
    return data.incidents;
  }
}
