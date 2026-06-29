/// Filters that drive the Reports module: the resource being analysed and the
/// time window. Shared by the presentation layer and the backend query.
enum ConsumptionMetric { water, electricity }

enum ConsumptionRange { day, week, month, year }

extension ConsumptionMetricInfo on ConsumptionMetric {
  String get label =>
      this == ConsumptionMetric.water ? 'Water' : 'Electricity';

  /// Value sent to the backend `metric` query parameter.
  String get apiValue =>
      this == ConsumptionMetric.water ? 'water' : 'electricity';
}

extension ConsumptionRangeInfo on ConsumptionRange {
  String get chip => switch (this) {
        ConsumptionRange.day => 'Day',
        ConsumptionRange.week => 'Week',
        ConsumptionRange.month => 'Month',
        ConsumptionRange.year => 'Year',
      };

  String get headline => switch (this) {
        ConsumptionRange.day => 'LAST 24 HOURS',
        ConsumptionRange.week => 'LAST 7 DAYS',
        ConsumptionRange.month => 'LAST 30 DAYS',
        ConsumptionRange.year => 'LAST 12 MONTHS',
      };

  /// How the previous period is referred to in deltas.
  String get previousLabel => switch (this) {
        ConsumptionRange.day => 'previous day',
        ConsumptionRange.week => 'previous week',
        ConsumptionRange.month => 'previous month',
        ConsumptionRange.year => 'previous year',
      };

  /// Value sent to the backend `range` query parameter.
  String get apiValue => switch (this) {
        ConsumptionRange.day => 'day',
        ConsumptionRange.week => 'week',
        ConsumptionRange.month => 'month',
        ConsumptionRange.year => 'year',
      };
}
