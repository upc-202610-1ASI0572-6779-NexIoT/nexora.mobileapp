import 'package:flutter/material.dart';

/// The "WHEN..." part of an automation (Step 1 of the wizard).
enum TriggerType {
  deviceState(
    label: 'Device state',
    summaryTitle: 'Device state',
    summarySubtitle: 'System state detection',
    icon: Icons.devices_other_outlined,
  ),
  schedule(
    label: 'Schedule / time',
    summaryTitle: 'Schedule / time',
    summarySubtitle: 'Time-based trigger',
    icon: Icons.schedule,
  ),
  location(
    label: 'Location (away/home)',
    summaryTitle: 'Location',
    summarySubtitle: 'Geofence trigger',
    icon: Icons.location_on_outlined,
  ),
  sensorValue(
    label: 'Sensor value',
    summaryTitle: 'Sensor value',
    summarySubtitle: 'Sensor threshold trigger',
    icon: Icons.sensors,
  ),
  manual(
    label: 'Manual',
    summaryTitle: 'Manual',
    summarySubtitle: 'Tap to run',
    icon: Icons.touch_app_outlined,
  );

  const TriggerType({
    required this.label,
    required this.summaryTitle,
    required this.summarySubtitle,
    required this.icon,
  });

  final String label;
  final String summaryTitle;
  final String summarySubtitle;
  final IconData icon;
}

/// The "THEN PERFORM..." part of an automation (Step 2 of the wizard).
enum ActionType {
  controlDevice(
    label: 'Control device',
    optionSubtitle: 'Turn on/off or dim lighting',
    summaryTitle: 'Turn off',
    summarySubtitle: 'Smart lighting cluster',
    icon: Icons.lightbulb_outline,
  ),
  sendNotification(
    label: 'Send notification',
    optionSubtitle: 'Push alert to your phone',
    summaryTitle: 'Send notification',
    summarySubtitle: 'Push to your phone',
    icon: Icons.notifications_none,
  ),
  activateScene(
    label: 'Activate Scene',
    optionSubtitle: 'Trigger multiple devices at once',
    summaryTitle: 'Activate scene',
    summarySubtitle: 'Multiple devices',
    icon: Icons.auto_awesome_outlined,
  ),
  adjustClimate(
    label: 'Adjust climate',
    optionSubtitle: 'Set target temperature',
    summaryTitle: 'Adjust climate',
    summarySubtitle: 'Target temperature',
    icon: Icons.thermostat_outlined,
  ),
  securityUpdate(
    label: 'Security update',
    optionSubtitle: 'Lock doors or arm alarms',
    summaryTitle: 'Security update',
    summarySubtitle: 'Lock & arm',
    icon: Icons.lock_outline,
  );

  const ActionType({
    required this.label,
    required this.optionSubtitle,
    required this.summaryTitle,
    required this.summarySubtitle,
    required this.icon,
  });

  final String label;
  final String optionSubtitle;
  final String summaryTitle;
  final String summarySubtitle;
  final IconData icon;
}

class Automation {
  String name;
  final TriggerType trigger;
  final ActionType action;
  final int timerMinutes;
  final bool onlyWhenNobodyHome;
  final bool notifyOnRun;
  bool enabled;

  Automation({
    required this.name,
    required this.trigger,
    required this.action,
    this.timerMinutes = 15,
    this.onlyWhenNobodyHome = false,
    this.notifyOnRun = false,
    this.enabled = true,
  });

  /// Human readable timer, e.g. "15 min" or "1 h".
  String get timerLabel =>
      timerMinutes < 60 ? '$timerMinutes min' : '${timerMinutes ~/ 60} h';

  /// One-line description shown in the automations list.
  String get summaryLine => '${trigger.summaryTitle} → ${action.summaryTitle}';
}
