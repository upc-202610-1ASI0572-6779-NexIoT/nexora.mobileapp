import 'package:nexoraiot/contexts/consumption/domain/entities/consumption_report.dart';
import 'package:nexoraiot/contexts/consumption/domain/entities/consumption_view.dart';
import 'package:nexoraiot/contexts/consumption/domain/entities/live_reading.dart';
import 'package:nexoraiot/contexts/consumption/domain/repositories/consumption_repository.dart';
import 'package:nexoraiot/contexts/consumption/infrastructure/datasources/consumption_api.dart';

class HttpConsumptionRepository implements ConsumptionRepository {
  final ConsumptionApi _api;

  HttpConsumptionRepository({ConsumptionApi? api})
      : _api = api ?? ConsumptionApi();

  @override
  Future<ConsumptionReport> getReport({
    required ConsumptionMetric metric,
    required ConsumptionRange range,
  }) async {
    final json = await _api.fetchConsumption(
      metric: metric.apiValue,
      range: range.apiValue,
    );
    return ConsumptionReport.fromJson(json, metric: metric, range: range);
  }

  @override
  Future<LiveReading?> getLatestReading(String deviceId) async {
    final json = await _api.fetchLatest(deviceId);
    return json == null ? null : LiveReading.fromJson(json);
  }
}
