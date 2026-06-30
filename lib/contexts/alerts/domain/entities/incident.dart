import 'package:flutter/material.dart';

enum AlertSensorType { gas, water, electricity }

enum AlertStatus { active, pending, resolved }

enum AlertCriticality { high, medium, low }

class Incident {
  final String id;
  final String deviceName;
  final String deviceLocation;
  final AlertSensorType sensorType;
  final DateTime detectedAt;
  final String recordedValue;
  final String threshold;
  final AlertStatus status;
  final AlertCriticality criticality;
  final String anomaly;

  const Incident({
    required this.id,
    required this.deviceName,
    required this.deviceLocation,
    required this.sensorType,
    required this.detectedAt,
    required this.recordedValue,
    required this.threshold,
    required this.status,
    required this.criticality,
    required this.anomaly,
  });

  String get title => anomaly;

  String get subtitle => '$deviceName - $deviceLocation';

  String get time => _formatDateTime(detectedAt);

  IconData get icon {
    return switch (sensorType) {
      AlertSensorType.gas => Icons.sensors_outlined,
      AlertSensorType.water => Icons.water_drop_outlined,
      AlertSensorType.electricity => Icons.bolt_outlined,
    };
  }

  String get sensorLabel {
    return switch (sensorType) {
      AlertSensorType.gas => 'Sensor de gas',
      AlertSensorType.water => 'Consumo de agua',
      AlertSensorType.electricity => 'Consumo de electricidad',
    };
  }

  String get statusLabel {
    return switch (status) {
      AlertStatus.active => 'Activa',
      AlertStatus.pending => 'Pendiente',
      AlertStatus.resolved => 'Resuelta',
    };
  }

  String get criticalityLabel {
    return switch (criticality) {
      AlertCriticality.high => 'Alta',
      AlertCriticality.medium => 'Media',
      AlertCriticality.low => 'Baja',
    };
  }
}

String _formatDateTime(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month/$hour:$minute';
}
