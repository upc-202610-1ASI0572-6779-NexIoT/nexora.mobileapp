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

  const DevicesPage({super.key, required this.data});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  // Filters: null = "All"
  String? _selectedRoom;
  String? _selectedStatus; // null = "All", "connected", "disconnected", "alert"

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

  /// Rooms ordered by device counts (desc)
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
    var filtered = items;
    if (_selectedRoom != null) {
      filtered = filtered.where((d) => d.room == _selectedRoom).toList();
    }
    if (_selectedStatus != null) {
      if (_selectedStatus == 'connected') {
        filtered = filtered.where((d) => d.isConnected).toList();
      } else if (_selectedStatus == 'disconnected') {
        filtered = filtered.where((d) => !d.isConnected).toList();
      } else if (_selectedStatus == 'alert') {
        filtered = filtered.where((d) => d.alert).toList();
      }
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    // Totals calculations based on unfiltered list
    final totalCount = _allDevices.length;
    final connectedCount = _allDevices.where((d) => d.isConnected).length;
    final disconnectedCount = _allDevices.where((d) => !d.isConnected).length;
    final anomaliesCount = _allDevices.where((d) => d.alert).length;

    // Filtered lists for rendering sections
    final gasFiltered = _filter(data.gasSensors);
    final airFiltered = _filter(data.airQuality);
    final humidityFiltered = _filter(data.humidity);

    final sections = [
      if (gasFiltered.isNotEmpty)
        _DeviceSection(
          title: 'GAS SENSOR',
          icon: Icons.sensor_occupied_outlined,
          items: gasFiltered,
          alertIcon: Icons.warning_rounded,
        ),
      if (airFiltered.isNotEmpty)
        _DeviceSection(
          title: 'AIR QUALITY',
          icon: Icons.air,
          items: airFiltered,
        ),
      if (humidityFiltered.isNotEmpty)
        _DeviceSection(
          title: 'HUMIDITY',
          icon: Icons.water_drop_outlined,
          items: humidityFiltered,
        ),
    ];

    return Column(
      children: [
        const TopBar(title: 'Devices', actionIcon: Icons.search),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Executive Automations card
                _AutomationCard(
                  activeCount: data.automations.where((a) => a.enabled).length,
                  onTap: _openAutomations,
                ),
                const SizedBox(height: 20),

                // Connected/Disconnected Summary Bar
                _DevicesSummaryBar(
                  total: totalCount,
                  connected: connectedCount,
                  disconnected: disconnectedCount,
                  anomalies: anomaliesCount,
                ),
                const SizedBox(height: 20),

                // Filters panel (Status + Room)
                const SectionLabel('FILTRAR ESTADO'),
                const SizedBox(height: 8),
                _StatusFilters(
                  selectedStatus: _selectedStatus,
                  onSelect: (status) =>
                      setState(() => _selectedStatus = status),
                  totalCount: totalCount,
                  connectedCount: connectedCount,
                  disconnectedCount: disconnectedCount,
                  anomaliesCount: anomaliesCount,
                ),
                const SizedBox(height: 16),

                const SectionLabel('FILTRAR POR AMBIENTE'),
                const SizedBox(height: 8),
                _RoomFilters(
                  rooms: _rooms,
                  total: totalCount,
                  countFor: (room) =>
                      _allDevices.where((d) => d.room == room).length,
                  selectedRoom: _selectedRoom,
                  onSelect: (room) => setState(() => _selectedRoom = room),
                ),
                const SizedBox(height: 28),

                // Render device list sections
                ...sections,

                if (sections.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        'No hay dispositivos que coincidan con los filtros',
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

class _DevicesSummaryBar extends StatelessWidget {
  final int total;
  final int connected;
  final int disconnected;
  final int anomalies;

  const _DevicesSummaryBar({
    required this.total,
    required this.connected,
    required this.disconnected,
    required this.anomalies,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryIndicator(
            label: 'Total',
            value: '$total',
            color: AppColors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryIndicator(
            label: 'Conectados',
            value: '$connected',
            color: AppColors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryIndicator(
            label: 'Inactivos',
            value: '$disconnected',
            color: AppColors.muted,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryIndicator(
            label: 'Anomalías',
            value: '$anomalies',
            color: AppColors.red,
            alert: anomalies > 0,
          ),
        ),
      ],
    );
  }
}

class _SummaryIndicator extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool alert;

  const _SummaryIndicator({
    required this.label,
    required this.value,
    required this.color,
    this.alert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: alert ? AppColors.red : AppColors.border,
          width: alert ? 1.4 : 1.0,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: alert ? AppColors.red : color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusFilters extends StatelessWidget {
  final String? selectedStatus;
  final ValueChanged<String?> onSelect;
  final int totalCount;
  final int connectedCount;
  final int disconnectedCount;
  final int anomaliesCount;

  const _StatusFilters({
    required this.selectedStatus,
    required this.onSelect,
    required this.totalCount,
    required this.connectedCount,
    required this.disconnectedCount,
    required this.anomaliesCount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChipLabel(
            'Any Status',
            selected: selectedStatus == null,
            onTap: () => onSelect(null),
          ),
          const SizedBox(width: 8),
          ChipLabel(
            'Connected ($connectedCount)',
            selected: selectedStatus == 'connected',
            onTap: () => onSelect('connected'),
          ),
          const SizedBox(width: 8),
          ChipLabel(
            'Inactive ($disconnectedCount)',
            selected: selectedStatus == 'disconnected',
            onTap: () => onSelect('disconnected'),
          ),
          const SizedBox(width: 8),
          ChipLabel(
            'Anomalies ($anomaliesCount)',
            selected: selectedStatus == 'alert',
            onTap: () => onSelect('alert'),
          ),
        ],
      ),
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

  const _AutomationCard({required this.activeCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
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
                        'AUTOMATIZACIONES',
                        style: TextStyle(
                          color: AppColors.muted,
                          letterSpacing: 1.2,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$activeCount Activas',
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          Icon(Icons.circle, color: AppColors.orange, size: 7),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Optimización activa de energía',
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
                color: AppColors.blue.withValues(alpha: 0.08),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted),
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
        Column(
          children: items.map((item) {
            Color statusColor = item.isConnected
                ? AppColors.green
                : AppColors.muted;
            Color iconBg = item.alert
                ? const Color(0xFFFFE6E6)
                : (item.isConnected
                      ? const Color(0xFFF0F2FF)
                      : const Color(0xFFEBEBEB));
            Color iconColor = item.alert
                ? AppColors.red
                : (item.isConnected ? AppColors.blue : AppColors.muted);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: item.alert
                      ? AppColors.red.withValues(alpha: 0.5)
                      : AppColors.border,
                  width: item.alert ? 1.4 : 1.0,
                ),
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.alert ? alertIcon ?? Icons.warning_rounded : icon,
                      color: iconColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            // Connection status pill badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.isConnected ? 'ONLINE' : 'OFFLINE',
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${item.room} • ${item.subtitle}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Activity: ${item.lastSeen}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: AppColors.muted.withValues(alpha: 0.8),
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item.value == 'No leaks detected'
                            ? 'No leaks'
                            : (item.value == 'Leak detected'
                                  ? 'Leak'
                                  : item.value),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: item.alert ? AppColors.red : AppColors.blue,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      if (item.alert) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.red.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 10,
                                color: AppColors.red,
                              ),
                              SizedBox(width: 3),
                              Text(
                                'ALERTA',
                                style: TextStyle(
                                  color: AppColors.red,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
