import 'package:nexoraiot/contexts/consumption/domain/entities/consumption_report.dart';
import 'package:nexoraiot/contexts/consumption/domain/entities/consumption_view.dart';
import 'package:nexoraiot/contexts/consumption/domain/entities/live_reading.dart';

abstract class ConsumptionRepository {
  /// Fetches the aggregated consumption report for the given metric and range.
  Future<ConsumptionReport> getReport({
    required ConsumptionMetric metric,
    required ConsumptionRange range,
  });

  /// Fetches the latest instantaneous reading for a device (null if none yet).
  Future<LiveReading?> getLatestReading(String deviceId);
}
