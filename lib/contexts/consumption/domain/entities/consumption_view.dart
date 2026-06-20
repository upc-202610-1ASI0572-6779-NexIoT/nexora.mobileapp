import 'package:nexoraiot/contexts/consumption/domain/entities/consumption_area.dart';

enum ConsumptionMetric { water, electricity }

enum ConsumptionRange { day, week, month, year }

extension ConsumptionMetricInfo on ConsumptionMetric {
  String get label =>
      this == ConsumptionMetric.water ? 'Water' : 'Electricity';

  /// Short unit shown next to per-area figures.
  String get areaUnit => this == ConsumptionMetric.water ? 'L' : 'kWh';
}

extension ConsumptionRangeInfo on ConsumptionRange {
  String get chip => switch (this) {
        ConsumptionRange.day => 'Day',
        ConsumptionRange.week => 'Week',
        ConsumptionRange.month => 'Month',
        ConsumptionRange.year => 'Year',
      };

  String get headline => switch (this) {
        ConsumptionRange.day => 'TODAY',
        ConsumptionRange.week => 'THIS WEEK',
        ConsumptionRange.month => 'THIS MONTH',
        ConsumptionRange.year => 'THIS YEAR',
      };
}

/// A single metric + range slice of consumption data, used by the Reports page.
class ConsumptionView {
  final String totalLabel;
  final String unit;
  final String deltaLabel;
  final bool increase;
  final bool highUsage;
  final List<double> series;
  final List<String> axisLabels;
  final List<ConsumptionArea> areas;

  ConsumptionView({
    required this.totalLabel,
    required this.unit,
    required this.deltaLabel,
    required this.increase,
    required this.highUsage,
    required this.series,
    required this.axisLabels,
    required this.areas,
  });
}
