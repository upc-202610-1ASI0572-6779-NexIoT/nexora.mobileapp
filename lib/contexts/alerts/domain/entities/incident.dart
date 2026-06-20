import 'package:flutter/material.dart';

enum IncidentLevel {
  critical,
  warning,
  solved,
}

class Incident {
  final String title;
  final String subtitle;
  final String time;
  final String status;
  final IncidentLevel level;
  final IconData icon;

  Incident(
      this.title,
      this.subtitle,
      this.time,
      this.status,
      this.level,
      this.icon,
      );
}