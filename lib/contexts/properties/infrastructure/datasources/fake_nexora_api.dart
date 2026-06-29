import 'package:flutter/material.dart';

import 'package:nexoraiot/contexts/alerts/domain/entities/incident.dart';
import 'package:nexoraiot/contexts/automations/domain/entities/automation.dart';
import 'package:nexoraiot/contexts/properties/domain/entities/app_data.dart';
import 'package:nexoraiot/contexts/devices/domain/entities/device_sensor.dart';

class FakeNexoraApi {
  /// Simulates persisting a new automation on the backend and returns the
  /// stored record. The wizard awaits this when the user taps "Save".
  Future<Automation> createAutomation(Automation draft) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return draft;
  }

  Future<AppData> getDashboardData() async {
    await Future.delayed(const Duration(milliseconds: 800));

    return AppData(
      userName: 'María Castillo',
      homeName: 'San Isidro House',
      waterToday: 284,
      energyToday: 6.2,
      latest24h: [
        8,
        12,
        10,
        15,
        19,
        30,
        42,
        28,
        20,
        14,
        9,
        16,
        24,
        31,
        27,
        20,
        15,
        10,
        8,
        12,
      ],
      gasSensors: [
        DeviceSensor('Kitchen', 'Floor 1', 'No leaks detected', false, 'Kitchen'),
        DeviceSensor(
            'Basement', 'Basement 1', 'No leaks detected', false, 'Basement'),
        DeviceSensor('Kitchen', 'Floor 2', 'Leak detected', true, 'Kitchen'),
      ],
      airQuality: [
        DeviceSensor('Habitación 1', 'Floor 1', '100 %', false, 'Bedroom'),
        DeviceSensor('Dinning Room', 'Floor 2', '95 %', false, 'Living Room'),
        DeviceSensor('Kitchen', 'Floor 2', '93 %', false, 'Kitchen'),
      ],
      humidity: [
        DeviceSensor('Living Room', 'Floor 1', '60 %', false, 'Living Room'),
        DeviceSensor('Garage', 'Floor 1', '87 %', false, 'Garage'),
      ],
      incidents: [
        Incident(
          'Water Leak Detected',
          'Kitchen • 5 mins ago',
          '10:45 AM',
          'Active',
          IncidentLevel.critical,
          Icons.water_drop_outlined,
        ),
        Incident(
          'Power Surge',
          'Main Panel • 12 mins ago',
          '09:12 AM',
          'Active',
          IncidentLevel.critical,
          Icons.bolt_outlined,
        ),
        Incident(
          'Motion in Backyard',
          'External Gate • 1h ago',
          'Yesterday',
          'Pend.',
          IncidentLevel.warning,
          Icons.home_outlined,
        ),
        Incident(
          'Unusual Energy Spike',
          'Whole House • 2h ago',
          'Oct 22',
          'Pend.',
          IncidentLevel.warning,
          Icons.videocam_outlined,
        ),
        Incident(
          'Smoke Sensor Triggered',
          'Kitchen • cleared',
          'Oct 20',
          'Solved',
          IncidentLevel.solved,
          Icons.local_fire_department_outlined,
        ),
        Incident(
          'Front Door Left Open',
          'Main Entrance • cleared',
          'Oct 18',
          'Solved',
          IncidentLevel.solved,
          Icons.meeting_room_outlined,
        ),
      ],
      automations: [
        Automation(
          name: 'Vacation Mode · Eco',
          trigger: TriggerType.location,
          action: ActionType.controlDevice,
          timerMinutes: 15,
          onlyWhenNobodyHome: true,
        ),
        Automation(
          name: 'Night Lights Off',
          trigger: TriggerType.schedule,
          action: ActionType.controlDevice,
          timerMinutes: 30,
        ),
        Automation(
          name: 'Leak Auto Shutoff',
          trigger: TriggerType.sensorValue,
          action: ActionType.securityUpdate,
          timerMinutes: 5,
          notifyOnRun: true,
        ),
        Automation(
          name: 'Away Climate Eco',
          trigger: TriggerType.location,
          action: ActionType.adjustClimate,
          timerMinutes: 60,
          onlyWhenNobodyHome: true,
        ),
        Automation(
          name: 'Goodnight Scene',
          trigger: TriggerType.manual,
          action: ActionType.activateScene,
          timerMinutes: 10,
        ),
      ],
    );
  }

}
