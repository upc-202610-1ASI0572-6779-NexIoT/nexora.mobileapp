import 'package:nexoraiot/contexts/consumption/domain/entities/consumption_view.dart';

/// A single contributing device/source within a consumption report.
class ConsumptionSource {
  final String deviceId;
  final String label;
  final double value;
  final double sharePercent;

  const ConsumptionSource({
    required this.deviceId,
    required this.label,
    required this.value,
    required this.sharePercent,
  });

  factory ConsumptionSource.fromJson(Map<String, dynamic> json) {
    return ConsumptionSource(
      deviceId: (json['deviceId'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      value: _toDouble(json['value']),
      sharePercent: _toDouble(json['sharePercent']),
    );
  }
}

/// Aggregated, chart-ready consumption report returned by the backend for a
/// single metric + range. Mirrors `ConsumptionReportDto` on the web service.
class ConsumptionReport {
  final ConsumptionMetric metric;
  final ConsumptionRange range;
  final String unit; // L | kWh
  final String rateUnit; // L/min | kW
  final double total;
  final double previousTotal;
  final double deltaPercent;
  final bool increase;
  final bool comparable;
  final double average;
  final String averageLabel;
  final double peak;
  final DateTime? peakAt;
  final bool highUsage;
  final double safeThreshold;
  final List<double> series;
  final List<String> axisLabels;
  final List<ConsumptionSource> sources;
  final int sampleCount;
  final DateTime? lastReadingAt;
  final bool hasData;

  const ConsumptionReport({
    required this.metric,
    required this.range,
    required this.unit,
    required this.rateUnit,
    required this.total,
    required this.previousTotal,
    required this.deltaPercent,
    required this.increase,
    required this.comparable,
    required this.average,
    required this.averageLabel,
    required this.peak,
    required this.peakAt,
    required this.highUsage,
    required this.safeThreshold,
    required this.series,
    required this.axisLabels,
    required this.sources,
    required this.sampleCount,
    required this.lastReadingAt,
    required this.hasData,
  });

  factory ConsumptionReport.fromJson(
    Map<String, dynamic> json, {
    required ConsumptionMetric metric,
    required ConsumptionRange range,
  }) {
    return ConsumptionReport(
      metric: metric,
      range: range,
      unit: (json['unit'] ?? '').toString(),
      rateUnit: (json['rateUnit'] ?? '').toString(),
      total: _toDouble(json['total']),
      previousTotal: _toDouble(json['previousTotal']),
      deltaPercent: _toDouble(json['deltaPercent']),
      increase: json['increase'] == true,
      comparable: json['comparable'] != false,
      average: _toDouble(json['average']),
      averageLabel: (json['averageLabel'] ?? '').toString(),
      peak: _toDouble(json['peak']),
      peakAt: _toDateTime(json['peakAt']),
      highUsage: json['highUsage'] == true,
      safeThreshold: _toDouble(json['safeThreshold']),
      series: _toDoubleList(json['series']),
      axisLabels: _toStringList(json['axisLabels']),
      sources: (json['sources'] as List<dynamic>? ?? [])
          .map((e) => ConsumptionSource.fromJson(e as Map<String, dynamic>))
          .toList(),
      sampleCount: (json['sampleCount'] as num?)?.toInt() ?? 0,
      lastReadingAt: _toDateTime(json['lastReadingAt']),
      hasData: json['hasData'] == true,
    );
  }

  // ---- display helpers -------------------------------------------------------

  String get totalLabel => formatNumber(total);
  String get averageValueLabel => formatNumber(average);
  String get peakLabel => formatNumber(peak, decimals: peak < 10 ? 1 : 0);

  String get deltaLabel {
    final arrow = increase ? '↑' : '↓';
    final pct = deltaPercent.abs();
    final pctText = pct >= 10 ? pct.toStringAsFixed(0) : pct.toStringAsFixed(1);
    return '$arrow $pctText% vs ${range.previousLabel}';
  }

  /// Formats a value with thousands separators; whole numbers when large.
  static String formatNumber(double value, {int? decimals}) {
    final d = decimals ?? (value >= 100 ? 0 : (value >= 10 ? 1 : 2));
    final fixed = value.toStringAsFixed(d);
    final parts = fixed.split('.');
    final intPart = parts[0];
    final buffer = StringBuffer();
    final negative = intPart.startsWith('-');
    final digits = negative ? intPart.substring(1) : intPart;
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    final grouped = (negative ? '-' : '') + buffer.toString();
    return parts.length > 1 ? '$grouped.${parts[1]}' : grouped;
  }
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

List<double> _toDoubleList(dynamic value) {
  if (value is List) return value.map(_toDouble).toList();
  return const [];
}

List<String> _toStringList(dynamic value) {
  if (value is List) return value.map((e) => e.toString()).toList();
  return const [];
}

DateTime? _toDateTime(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  // Backend timestamps are UTC; if the string carries no zone designator,
  // treat it as UTC so .toLocal() converts correctly.
  final hasZone =
      value.endsWith('Z') || RegExp(r'[+-]\d\d:?\d\d$').hasMatch(value);
  return DateTime.tryParse(hasZone ? value : '${value}Z');
}
