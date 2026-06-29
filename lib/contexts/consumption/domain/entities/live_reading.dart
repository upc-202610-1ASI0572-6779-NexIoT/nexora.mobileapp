/// The latest instantaneous telemetry snapshot for a single device, mirroring
/// what the embedded device shows in real time (current in A, water flow in L/min).
class LiveReading {
  final String deviceId;
  final double waterReading; // L/min
  final double electricityReading; // A (current)
  final bool voltageOk;
  final DateTime? timestamp;

  const LiveReading({
    required this.deviceId,
    required this.waterReading,
    required this.electricityReading,
    required this.voltageOk,
    required this.timestamp,
  });

  factory LiveReading.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    DateTime? toDate(dynamic v) {
      if (v is! String || v.isEmpty) return null;
      // Backend timestamps are UTC; assume UTC when no zone is present.
      final hasZone =
          v.endsWith('Z') || RegExp(r'[+-]\d\d:?\d\d$').hasMatch(v);
      return DateTime.tryParse(hasZone ? v : '${v}Z');
    }

    return LiveReading(
      deviceId: (json['deviceId'] ?? '').toString(),
      waterReading: toDouble(json['waterReading']),
      electricityReading: toDouble(json['electricityReading']),
      voltageOk: json['voltageOk'] == true,
      timestamp: toDate(json['timestamp']),
    );
  }
}
