import 'package:flutter/material.dart';

import 'package:nexoraiot/contexts/alerts/domain/entities/incident.dart';
import 'package:nexoraiot/contexts/automations/domain/entities/automation.dart';
import 'package:nexoraiot/contexts/consumption/domain/entities/consumption_area.dart';
import 'package:nexoraiot/contexts/consumption/domain/entities/consumption_view.dart';
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
        DeviceSensor('Kitchen', 'Floor 1', 'No leaks detected', false, 'Kitchen', true, 'Just now', 'Gas'),
        DeviceSensor(
            'Basement', 'Basement 1', 'No leaks detected', false, 'Basement', false, '4h ago', 'Gas'),
        DeviceSensor('Kitchen', 'Floor 2', 'Leak detected', true, 'Kitchen', true, 'Just now', 'Gas'),
      ],
      airQuality: [
        DeviceSensor('Habitación 1', 'Floor 1', '100 %', false, 'Bedroom', true, 'Just now', 'Air Quality'),
        DeviceSensor('Dinning Room', 'Floor 2', '95 %', false, 'Living Room', true, 'Just now', 'Air Quality'),
        DeviceSensor('Kitchen', 'Floor 2', '93 %', false, 'Kitchen', true, 'Just now', 'Air Quality'),
      ],
      humidity: [
        DeviceSensor('Living Room', 'Floor 1', '60 %', false, 'Living Room', true, 'Just now', 'Humidity'),
        DeviceSensor('Garage', 'Floor 1', '87 %', false, 'Garage', false, '2d ago', 'Humidity'),
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
      consumption: _consumption,
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

  // Mock consumption datasets for every metric + range combination, so the
  // Reports filters (Water/Electricity and Day/Week/Month/Year) switch to real
  // data instead of a static chart.
  static final Map<ConsumptionMetric, Map<ConsumptionRange, ConsumptionView>>
      _consumption = {
    ConsumptionMetric.water: {
      ConsumptionRange.day: ConsumptionView(
        totalLabel: '284',
        unit: 'litres',
        deltaLabel: '↑ 8% vs yesterday',
        increase: true,
        highUsage: false,
        series: [8, 12, 10, 15, 19, 30, 42, 28, 20, 14, 9, 16, 24, 31, 27, 20],
        axisLabels: ['12a', '6a', '12p', '6p', '11p'],
        areas: [
          ConsumptionArea('Master bathroom', 96),
          ConsumptionArea('Kitchen', 74),
          ConsumptionArea('Laundry', 61),
          ConsumptionArea('Secondary bathroom', 53),
        ],
      ),
      ConsumptionRange.week: ConsumptionView(
        totalLabel: '1,847',
        unit: 'litres',
        deltaLabel: '↑ 14% vs last week',
        increase: true,
        highUsage: true,
        series: [980, 1220, 1140, 1320, 1490, 1280, 1560],
        axisLabels: ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
        areas: [
          ConsumptionArea('Master bathroom', 624),
          ConsumptionArea('Kitchen', 498),
          ConsumptionArea('Laundry', 412),
          ConsumptionArea('Secondary bathroom', 313),
        ],
      ),
      ConsumptionRange.month: ConsumptionView(
        totalLabel: '7,320',
        unit: 'litres',
        deltaLabel: '↓ 5% vs last month',
        increase: false,
        highUsage: false,
        series: [1650, 1820, 1740, 1900, 2010, 1780, 1990, 2110],
        axisLabels: ['W1', 'W2', 'W3', 'W4'],
        areas: [
          ConsumptionArea('Master bathroom', 2480),
          ConsumptionArea('Kitchen', 1980),
          ConsumptionArea('Laundry', 1640),
          ConsumptionArea('Secondary bathroom', 1220),
        ],
      ),
      ConsumptionRange.year: ConsumptionView(
        totalLabel: '86,400',
        unit: 'litres',
        deltaLabel: '↑ 3% vs last year',
        increase: true,
        highUsage: false,
        series: [
          6800, 7100, 6900, 7400, 7600, 7300, //
          7800, 7900, 7200, 7000, 7300, 7100,
        ],
        axisLabels: ['Jan', 'Apr', 'Jul', 'Oct'],
        areas: [
          ConsumptionArea('Master bathroom', 29000),
          ConsumptionArea('Kitchen', 23000),
          ConsumptionArea('Laundry', 19000),
          ConsumptionArea('Secondary bathroom', 15400),
        ],
      ),
    },
    ConsumptionMetric.electricity: {
      ConsumptionRange.day: ConsumptionView(
        totalLabel: '6.2',
        unit: 'kWh',
        deltaLabel: '↓ 8% vs yesterday',
        increase: false,
        highUsage: false,
        series: [
          0.2, 0.15, 0.1, 0.3, 0.5, 0.7, 0.6, 0.4, //
          0.35, 0.5, 0.45, 0.6, 0.8, 0.7, 0.5, 0.4,
        ],
        axisLabels: ['12a', '6a', '12p', '6p', '11p'],
        areas: [
          ConsumptionArea('Kitchen', 1.9),
          ConsumptionArea('A/C', 1.6),
          ConsumptionArea('Water heater', 1.4),
          ConsumptionArea('Laundry', 1.3),
        ],
      ),
      ConsumptionRange.week: ConsumptionView(
        totalLabel: '38.5',
        unit: 'kWh',
        deltaLabel: '↑ 6% vs last week',
        increase: true,
        highUsage: false,
        series: [5.2, 6.1, 5.8, 6.4, 5.9, 4.8, 4.3],
        axisLabels: ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
        areas: [
          ConsumptionArea('Kitchen', 12.4),
          ConsumptionArea('A/C', 9.8),
          ConsumptionArea('Water heater', 8.6),
          ConsumptionArea('Laundry', 7.7),
        ],
      ),
      ConsumptionRange.month: ConsumptionView(
        totalLabel: '162',
        unit: 'kWh',
        deltaLabel: '↓ 4% vs last month',
        increase: false,
        highUsage: false,
        series: [38, 42, 40, 44, 41, 39, 43, 45],
        axisLabels: ['W1', 'W2', 'W3', 'W4'],
        areas: [
          ConsumptionArea('Kitchen', 52),
          ConsumptionArea('A/C', 41),
          ConsumptionArea('Water heater', 36),
          ConsumptionArea('Laundry', 33),
        ],
      ),
      ConsumptionRange.year: ConsumptionView(
        totalLabel: '1,980',
        unit: 'kWh',
        deltaLabel: '↑ 2% vs last year',
        increase: true,
        highUsage: false,
        series: [
          155, 148, 162, 170, 175, 168, //
          182, 190, 172, 160, 165, 158,
        ],
        axisLabels: ['Jan', 'Apr', 'Jul', 'Oct'],
        areas: [
          ConsumptionArea('Kitchen', 640),
          ConsumptionArea('A/C', 510),
          ConsumptionArea('Water heater', 430),
          ConsumptionArea('Laundry', 400),
        ],
      ),
    },
  };
}
