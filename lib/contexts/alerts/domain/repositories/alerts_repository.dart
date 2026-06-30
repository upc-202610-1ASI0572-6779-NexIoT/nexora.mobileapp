import 'package:nexoraiot/contexts/alerts/domain/entities/incident.dart';

abstract class AlertsRepository {
  Future<List<Incident>> getAlerts();
}
