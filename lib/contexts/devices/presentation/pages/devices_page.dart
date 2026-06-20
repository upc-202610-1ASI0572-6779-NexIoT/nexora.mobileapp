import 'package:flutter/material.dart';

import 'package:nexoraiot/app/theme/app_colors.dart';
import 'package:nexoraiot/shared/presentation/widgets/chip_label.dart';
import 'package:nexoraiot/shared/presentation/widgets/section_label.dart';
import 'package:nexoraiot/shared/presentation/widgets/top_bar.dart';
import 'package:nexoraiot/shared/presentation/widgets/white_card.dart';
import 'package:nexoraiot/contexts/automations/presentation/pages/automations_page.dart';
import 'package:nexoraiot/contexts/properties/domain/entities/app_data.dart';
import 'package:nexoraiot/contexts/devices/domain/entities/device_sensor.dart';

class DevicesPage extends StatefulWidget {
  final AppData data;

  const DevicesPage({
    super.key,
    required this.data,
  });

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  // null = "All".
  String? _selectedRoom;

  Future<void> _openAutomations() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AutomationsPage(automations: widget.data.automations),
      ),
    );
    // Toggles / new automations may have changed the active count.
    if (mounted) setState(() {});
  }

  List<DeviceSensor> get _allDevices => [
        ...widget.data.gasSensors,
        ...widget.data.airQuality,
        ...widget.data.humidity,
      ];

  /// Distinct rooms ordered by how many devices they contain (desc).
  List<String> get _rooms {
    final counts = <String, int>{};
    for (final device in _allDevices) {
      counts[device.room] = (counts[device.room] ?? 0) + 1;
    }
    final rooms = counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
    return rooms;
  }

  List<DeviceSensor> _filter(List<DeviceSensor> items) {
    if (_selectedRoom == null) return items;
    return items.where((d) => d.room == _selectedRoom).toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    final sections = [
      _DeviceSection(
        title: 'GAS SENSOR',
        icon: Icons.sensor_occupied_outlined,
        items: _filter(data.gasSensors),
        alertIcon: Icons.warning_rounded,
      ),
      _DeviceSection(
        title: 'AIR QUALITY',
        icon: Icons.air,
        items: _filter(data.airQuality),
      ),
      _DeviceSection(
        title: 'HUMIDITY',
        icon: Icons.water_drop_outlined,
        items: _filter(data.humidity),
      ),
    ].where((section) => section.items.isNotEmpty).toList();

    return Column(
      children: [
        const TopBar(
          title: 'Devices',
          actionIcon: Icons.search,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 20, 14, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AutomationCard(
                  activeCount:
                      data.automations.where((a) => a.enabled).length,
                  onTap: _openAutomations,
                ),
                const SizedBox(height: 20),
                _RoomFilters(
                  rooms: _rooms,
                  total: _allDevices.length,
                  countFor: (room) =>
                      _allDevices.where((d) => d.room == room).length,
                  selectedRoom: _selectedRoom,
                  onSelect: (room) => setState(() => _selectedRoom = room),
                ),
                const SizedBox(height: 28),
                for (var i = 0; i < sections.length; i++) ...[
                  if (i > 0) const SizedBox(height: 24),
                  sections[i],
                ],
                if (sections.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        'No devices in this room',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RoomFilters extends StatelessWidget {
  final List<String> rooms;
  final int total;
  final int Function(String room) countFor;
  final String? selectedRoom;
  final ValueChanged<String?> onSelect;

  const _RoomFilters({
    required this.rooms,
    required this.total,
    required this.countFor,
    required this.selectedRoom,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChipLabel(
            'All ($total)',
            selected: selectedRoom == null,
            onTap: () => onSelect(null),
          ),
          for (final room in rooms) ...[
            const SizedBox(width: 8),
            ChipLabel(
              '$room (${countFor(room)})',
              selected: selectedRoom == room,
              onTap: () => onSelect(room),
            ),
          ],
        ],
      ),
    );
  }
}

class _AutomationCard extends StatelessWidget {
  final int activeCount;
  final VoidCallback onTap;

  const _AutomationCard({
    required this.activeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: WhiteCard(
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AUTOMATIONS',
                        style: TextStyle(
                          color: AppColors.muted,
                          letterSpacing: 1.2,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$activeCount Active',
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          Icon(
                            Icons.circle,
                            color: AppColors.orange,
                            size: 7,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'System optimizing energy usage',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Icon(
                Icons.sensors_outlined,
                size: 74,
                color: AppColors.blue.withOpacity(0.08),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeviceSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final IconData? alertIcon;
  final List<DeviceSensor> items;

  const _DeviceSection({
    required this.title,
    required this.icon,
    required this.items,
    this.alertIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(title),
        const SizedBox(height: 10),
        WhiteCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: items.map((item) {
              final isLast = items.last == item;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: item.alert
                                ? const Color(0xFFFFE6E6)
                                : const Color(0xFFF0F2FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            item.alert
                                ? alertIcon ?? Icons.warning_rounded
                                : icon,
                            color: item.alert
                                ? AppColors.red
                                : AppColors.blue,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                item.subtitle,
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          item.value,
                          style: TextStyle(
                            color: item.alert
                                ? AppColors.red
                                : AppColors.blue,
                            fontWeight: FontWeight.w700,
                            fontSize: item.value.contains('%') ? 18 : 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    const Divider(
                      height: 1,
                      color: AppColors.border,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
