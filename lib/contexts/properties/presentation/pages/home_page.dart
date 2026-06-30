import 'package:flutter/material.dart';

import 'package:nexoraiot/app/theme/app_colors.dart';
import 'package:nexoraiot/contexts/properties/domain/entities/app_data.dart';
import 'package:nexoraiot/contexts/alerts/domain/entities/incident.dart';
import 'package:nexoraiot/contexts/consumption/domain/entities/consumption_view.dart';
import 'package:nexoraiot/shared/presentation/widgets/line_chart.dart';
import 'package:nexoraiot/shared/presentation/widgets/section_label.dart';
import 'package:nexoraiot/shared/presentation/widgets/white_card.dart';

class HomePage extends StatefulWidget {
  final AppData data;

  const HomePage({super.key, required this.data});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    // Devices count
    final allDevices = [
      ...data.gasSensors,
      ...data.airQuality,
      ...data.humidity,
    ];
    final totalDevices = allDevices.length;
    final connectedDevices = allDevices.where((d) => d.isConnected).length;
    final disconnectedDevices = allDevices.where((d) => !d.isConnected).length;
    final anomalousDevices = allDevices.where((d) => d.alert).length;

    // Alerts count
    final totalAlerts = data.incidents.length;
    final activeAlerts = data.incidents
        .where((i) => i.status == AlertStatus.active)
        .length;
    final resolvedAlerts = data.incidents
        .where((i) => i.status == AlertStatus.resolved)
        .length;
    final criticalAlerts = data.incidents
        .where((i) => i.criticality == AlertCriticality.high)
        .length;

    // Sensors
    final gasSensorsCount = data.gasSensors.length;
    final waterSensorsCount =
        data
            .consumption[ConsumptionMetric.water]?[ConsumptionRange.day]
            ?.areas
            .length ??
        0;
    final electricitySensorsCount =
        data
            .consumption[ConsumptionMetric.electricity]?[ConsumptionRange.day]
            ?.areas
            .length ??
        0;

    // Room distribution
    final roomCounts = <String, int>{};
    for (final device in allDevices) {
      roomCounts[device.room] = (roomCounts[device.room] ?? 0) + 1;
    }
    final sortedRooms = roomCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Platform state calculation
    String systemStateLabel = 'ÓPTIMO';
    Color systemStateColor = AppColors.green;
    IconData systemStateIcon = Icons.check_circle;
    String systemStateDesc =
        'Todos los sistemas están respondiendo correctamente';

    if (criticalAlerts > 0) {
      systemStateLabel = 'ALERTA CRÍTICA';
      systemStateColor = AppColors.red;
      systemStateIcon = Icons.error;
      systemStateDesc =
          '$criticalAlerts incidentes críticos que requieren atención';
    } else if (activeAlerts > 0) {
      systemStateLabel = 'ADVERTENCIA';
      systemStateColor = AppColors.orange;
      systemStateIcon = Icons.warning;
      systemStateDesc = '$activeAlerts incidentes menores pendientes';
    }

    return Column(
      children: [
        _HomeHeader(
          userName: data.userName,
          homeName: data.homeName,
          stateLabel: systemStateLabel,
          stateColor: systemStateColor,
          stateIcon: systemStateIcon,
          stateDesc: systemStateDesc,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 20, 14, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('RESUMEN DE ESTADO'),
                const SizedBox(height: 12),

                // Device summary and Alert summary row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Dispositivos',
                        icon: Icons.sensors_outlined,
                        iconColor: AppColors.blue,
                        mainValue: '$totalDevices',
                        mainValueLabel: 'Registrados',
                        items: [
                          _SummaryItem(
                            label: 'Conectados',
                            value: '$connectedDevices',
                            color: AppColors.green,
                          ),
                          _SummaryItem(
                            label: 'Desconectados',
                            value: '$disconnectedDevices',
                            color: AppColors.muted,
                          ),
                          _SummaryItem(
                            label: 'Anomalías',
                            value: '$anomalousDevices',
                            color: AppColors.red,
                            bold: anomalousDevices > 0,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Alertas',
                        icon: Icons.notification_important_outlined,
                        iconColor: AppColors.orange,
                        mainValue: '$totalAlerts',
                        mainValueLabel: 'Generadas',
                        items: [
                          _SummaryItem(
                            label: 'Activas',
                            value: '$activeAlerts',
                            color: activeAlerts > 0
                                ? AppColors.orange
                                : AppColors.muted,
                            bold: activeAlerts > 0,
                          ),
                          _SummaryItem(
                            label: 'Críticas',
                            value: '$criticalAlerts',
                            color: criticalAlerts > 0
                                ? AppColors.red
                                : AppColors.muted,
                            bold: criticalAlerts > 0,
                          ),
                          _SummaryItem(
                            label: 'Resueltas',
                            value: '$resolvedAlerts',
                            color: AppColors.green,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Sensors and room distribution row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Sensores',
                        icon: Icons.analytics_outlined,
                        iconColor: AppColors.green,
                        mainValue:
                            '${gasSensorsCount + waterSensorsCount + electricitySensorsCount}',
                        mainValueLabel: 'Monitoreados',
                        items: [
                          _SummaryItem(
                            label: 'Gas Natural',
                            value: '$gasSensorsCount',
                            color: AppColors.blue,
                          ),
                          _SummaryItem(
                            label: 'Flujo de Agua',
                            value: '$waterSensorsCount',
                            color: AppColors.blue,
                          ),
                          _SummaryItem(
                            label: 'Consumo Eléc.',
                            value: '$electricitySensorsCount',
                            color: AppColors.blue,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoomDistributionCard(
                        rooms: sortedRooms,
                        totalDevices: totalDevices,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                const SectionLabel('ACTIVIDAD RECIENTE'),
                const SizedBox(height: 12),

                // Show the top 3 latest incidents
                if (data.incidents.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'No hay actividad reciente registrada',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ),
                  )
                else
                  ...data.incidents
                      .take(3)
                      .map((incident) => _ActivityTile(incident: incident)),

                const SizedBox(height: 20),

                const SectionLabel('TENDENCIA GENERAL DE ACTIVIDAD (24H)'),
                const SizedBox(height: 12),

                _TrendCard(values: data.latest24h),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final String userName;
  final String homeName;
  final String stateLabel;
  final Color stateColor;
  final IconData stateIcon;
  final String stateDesc;

  const _HomeHeader({
    required this.userName,
    required this.homeName,
    required this.stateLabel,
    required this.stateColor,
    required this.stateIcon,
    required this.stateDesc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkBlue, AppColors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 18,
        right: 18,
        bottom: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NEXORA PLATFORM'.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.home, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      homeName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: stateColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(stateIcon, color: stateColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ESTADO DEL SISTEMA',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stateLabel,
                        style: TextStyle(
                          color: stateColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stateDesc,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String mainValue;
  final String mainValueLabel;
  final List<_SummaryItem> items;

  const _SummaryCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.mainValue,
    required this.mainValueLabel,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                mainValue,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  mainValueLabel,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.label,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        color: AppColors.text.withValues(alpha: 0.85),
                        fontSize: 11,
                        fontWeight: item.bold
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.value,
                      style: TextStyle(
                        color: item.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SummaryItem {
  final String label;
  final String value;
  final Color color;
  final bool bold;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });
}

class _RoomDistributionCard extends StatelessWidget {
  final List<MapEntry<String, int>> rooms;
  final int totalDevices;

  const _RoomDistributionCard({
    required this.rooms,
    required this.totalDevices,
  });

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.room_preferences_outlined,
                  color: AppColors.blue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'ZONAS / AMBIENTES',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (rooms.isEmpty)
            const Text(
              'Sin dispositivos',
              style: TextStyle(color: AppColors.muted, fontSize: 11),
            )
          else ...[
            Text(
              '${rooms.length} Sectores',
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 10),
            ...rooms.take(3).map((entry) {
              final pct = totalDevices == 0 ? 0.0 : entry.value / totalDevices;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${entry.value}',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: AppColors.background,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.blue,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final Incident incident;

  const _ActivityTile({required this.incident});

  @override
  Widget build(BuildContext context) {
    Color levelColor;
    String levelText;

    switch (incident.criticality) {
      case AlertCriticality.high:
        levelColor = AppColors.red;
        levelText = 'Alta';
        break;
      case AlertCriticality.medium:
        levelColor = AppColors.orange;
        levelText = 'Media';
        break;
      case AlertCriticality.low:
        levelColor = AppColors.green;
        levelText = 'Baja';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: levelColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(incident.icon, color: levelColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  incident.title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  incident.subtitle,
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                incident.time,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  levelText,
                  style: TextStyle(
                    color: levelColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final List<double> values;

  const _TrendCard({required this.values});

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Nivel de actividad (últimas 24h)',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: const [
                  Icon(Icons.trending_down, color: AppColors.green, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Estable',
                    style: TextStyle(
                      color: AppColors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 90,
            child: LineChart(values: values, showGrid: true, showLastDot: true),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Hace 24h',
                style: TextStyle(color: AppColors.muted, fontSize: 10),
              ),
              Text(
                'Hace 12h',
                style: TextStyle(color: AppColors.muted, fontSize: 10),
              ),
              Text(
                'Actual',
                style: TextStyle(color: AppColors.muted, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
