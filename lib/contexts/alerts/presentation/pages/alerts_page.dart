import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:nexoraiot/app/theme/app_colors.dart';
import 'package:nexoraiot/contexts/alerts/domain/entities/incident.dart';
import 'package:nexoraiot/contexts/alerts/domain/repositories/alerts_repository.dart';
import 'package:nexoraiot/contexts/alerts/infrastructure/repositories/app_data_alerts_repository.dart';
import 'package:nexoraiot/contexts/properties/domain/entities/app_data.dart';
import 'package:nexoraiot/shared/presentation/widgets/line_chart.dart';
import 'package:nexoraiot/shared/presentation/widgets/section_label.dart';
import 'package:nexoraiot/shared/presentation/widgets/top_bar.dart';
import 'package:nexoraiot/shared/presentation/widgets/white_card.dart';

enum _AlertFilter { all, active, pending, resolved }

class AlertsPage extends StatefulWidget {
  final AppData data;
  final AlertsRepository? repository;

  const AlertsPage({super.key, required this.data, this.repository});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  _AlertFilter _filter = _AlertFilter.all;
  late final AlertsRepository _repository;
  late Future<List<Incident>> _futureAlerts;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? AppDataAlertsRepository(widget.data);
    _futureAlerts = _repository.getAlerts();
  }

  List<Incident> _applyFilter(List<Incident> alerts) {
    return switch (_filter) {
      _AlertFilter.active =>
        alerts.where((alert) => alert.status == AlertStatus.active).toList(),
      _AlertFilter.pending =>
        alerts.where((alert) => alert.status == AlertStatus.pending).toList(),
      _AlertFilter.resolved =>
        alerts.where((alert) => alert.status == AlertStatus.resolved).toList(),
      _AlertFilter.all => alerts,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TopBar(title: 'Alertas', actionIcon: Icons.search),
        Expanded(
          child: FutureBuilder<List<Incident>>(
            future: _futureAlerts,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.blue),
                );
              }

              final alerts = [...snapshot.data!]
                ..sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
              final dashboard = _AlertsDashboard(alerts);
              final filtered = _applyFilter(alerts);

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryGrid(dashboard: dashboard),
                    const SizedBox(height: 22),
                    const SectionLabel('POR ESTADO'),
                    const SizedBox(height: 10),
                    _StatusBreakdown(
                      dashboard: dashboard,
                      selected: _filter,
                      onSelected: (filter) => setState(() => _filter = filter),
                    ),
                    const SizedBox(height: 22),
                    const SectionLabel('TIPO DE SENSOR'),
                    const SizedBox(height: 10),
                    _SensorBreakdown(dashboard: dashboard),
                    const SizedBox(height: 22),
                    const SectionLabel('CRITICIDAD'),
                    const SizedBox(height: 10),
                    _CriticalityBreakdown(dashboard: dashboard),
                    const SizedBox(height: 22),
                    const SectionLabel('DISPOSITIVOS CON MAS ALERTAS'),
                    const SizedBox(height: 10),
                    _TopDevicesCard(entries: dashboard.topDevices),
                    const SizedBox(height: 22),
                    const SectionLabel('EVOLUCION RECIENTE'),
                    const SizedBox(height: 10),
                    _TrendCard(values: dashboard.trend),
                    const SizedBox(height: 22),
                    const SectionLabel('ULTIMAS ALERTAS'),
                    const SizedBox(height: 10),
                    if (filtered.isEmpty)
                      const _EmptyAlerts()
                    else
                      ...filtered.map(
                        (alert) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _AlertCard(alert: alert),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AlertsDashboard {
  final List<Incident> alerts;

  _AlertsDashboard(this.alerts);

  int get total => alerts.length;

  int get active => _countStatus(AlertStatus.active);

  int get pending => _countStatus(AlertStatus.pending);

  int get resolved => _countStatus(AlertStatus.resolved);

  int get high => _countCriticality(AlertCriticality.high);

  int get medium => _countCriticality(AlertCriticality.medium);

  int get low => _countCriticality(AlertCriticality.low);

  int sensorCount(AlertSensorType type) {
    return alerts.where((alert) => alert.sensorType == type).length;
  }

  List<MapEntry<String, int>> get topDevices {
    final counts = <String, int>{};
    for (final alert in alerts) {
      counts[alert.deviceName] = (counts[alert.deviceName] ?? 0) + 1;
    }
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(3).toList();
  }

  List<double> get trend {
    if (alerts.isEmpty) return const [0, 0, 0, 0, 0, 0, 0];

    final latest = alerts
        .map(
          (alert) => DateTime(
            alert.detectedAt.year,
            alert.detectedAt.month,
            alert.detectedAt.day,
          ),
        )
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final counts = List<double>.filled(7, 0);

    for (final alert in alerts) {
      final day = DateTime(
        alert.detectedAt.year,
        alert.detectedAt.month,
        alert.detectedAt.day,
      );
      final index = 6 - latest.difference(day).inDays;
      if (index >= 0 && index < counts.length) {
        counts[index] += 1;
      }
    }

    return counts;
  }

  int _countStatus(AlertStatus status) {
    return alerts.where((alert) => alert.status == status).length;
  }

  int _countCriticality(AlertCriticality criticality) {
    return alerts.where((alert) => alert.criticality == criticality).length;
  }
}

class _SummaryGrid extends StatelessWidget {
  final _AlertsDashboard dashboard;

  const _SummaryGrid({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.95,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _SummaryCard(
          title: 'Total',
          value: dashboard.total,
          icon: Icons.notifications_active_outlined,
          color: AppColors.blue,
        ),
        _SummaryCard(
          title: 'Activas',
          value: dashboard.active,
          icon: Icons.error_outline,
          color: AppColors.red,
        ),
        _SummaryCard(
          title: 'Pendientes',
          value: dashboard.pending,
          icon: Icons.schedule_outlined,
          color: AppColors.orange,
        ),
        _SummaryCard(
          title: 'Resueltas',
          value: dashboard.resolved,
          icon: Icons.check_circle_outline,
          color: AppColors.green,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$value',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 24,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
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

class _StatusBreakdown extends StatelessWidget {
  final _AlertsDashboard dashboard;
  final _AlertFilter selected;
  final ValueChanged<_AlertFilter> onSelected;

  const _StatusBreakdown({
    required this.dashboard,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatusTile(
            label: 'Todas',
            value: dashboard.total,
            color: AppColors.blue,
            selected: selected == _AlertFilter.all,
            onTap: () => onSelected(_AlertFilter.all),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatusTile(
            label: 'Activas',
            value: dashboard.active,
            color: AppColors.red,
            selected: selected == _AlertFilter.active,
            onTap: () => onSelected(_AlertFilter.active),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatusTile(
            label: 'Pend.',
            value: dashboard.pending,
            color: AppColors.orange,
            selected: selected == _AlertFilter.pending,
            onTap: () => onSelected(_AlertFilter.pending),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatusTile(
            label: 'Res.',
            value: dashboard.resolved,
            color: AppColors.green,
            selected: selected == _AlertFilter.resolved,
            onTap: () => onSelected(_AlertFilter.resolved),
          ),
        ),
      ],
    );
  }
}

class _StatusTile extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _StatusTile({
    required this.label,
    required this.value,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.09) : AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                color: color,
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
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SensorBreakdown extends StatelessWidget {
  final _AlertsDashboard dashboard;

  const _SensorBreakdown({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _DistributionRow(
            icon: Icons.sensors_outlined,
            label: 'Sensor de gas',
            value: dashboard.sensorCount(AlertSensorType.gas),
            total: dashboard.total,
            color: AppColors.orange,
          ),
          const SizedBox(height: 12),
          _DistributionRow(
            icon: Icons.water_drop_outlined,
            label: 'Consumo de agua',
            value: dashboard.sensorCount(AlertSensorType.water),
            total: dashboard.total,
            color: AppColors.blue,
          ),
          const SizedBox(height: 12),
          _DistributionRow(
            icon: Icons.bolt_outlined,
            label: 'Consumo de electricidad',
            value: dashboard.sensorCount(AlertSensorType.electricity),
            total: dashboard.total,
            color: const Color(0xFFE7B83E),
          ),
        ],
      ),
    );
  }
}

class _CriticalityBreakdown extends StatelessWidget {
  final _AlertsDashboard dashboard;

  const _CriticalityBreakdown({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CriticalityCard(
            label: 'Alta',
            value: dashboard.high,
            icon: Icons.priority_high_rounded,
            color: AppColors.red,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _CriticalityCard(
            label: 'Media',
            value: dashboard.medium,
            icon: Icons.warning_amber_rounded,
            color: AppColors.orange,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _CriticalityCard(
            label: 'Baja',
            value: dashboard.low,
            icon: Icons.info_outline,
            color: AppColors.green,
          ),
        ),
      ],
    );
  }
}

class _CriticalityCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _CriticalityCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 20,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DistributionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final int total;
  final Color color;

  const _DistributionRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : value / total;

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$value',
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: AppColors.background,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopDevicesCard extends StatelessWidget {
  final List<MapEntry<String, int>> entries;

  const _TopDevicesCard({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const _EmptyAlerts();

    final maxValue = entries.map((entry) => entry.value).reduce(math.max);

    return WhiteCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          for (final entry in entries) ...[
            _DeviceAlertRow(name: entry.key, count: entry.value, max: maxValue),
            if (entry != entries.last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _DeviceAlertRow extends StatelessWidget {
  final String name;
  final int count;
  final int max;

  const _DeviceAlertRow({
    required this.name,
    required this.count,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: max == 0 ? 0 : count / max,
              minHeight: 6,
              backgroundColor: AppColors.background,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.blue),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$count',
          style: const TextStyle(
            color: AppColors.blue,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _TrendCard extends StatelessWidget {
  final List<double> values;

  const _TrendCard({required this.values});

  @override
  Widget build(BuildContext context) {
    final hasValues = values.any((value) => value > 0);

    return WhiteCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Alertas por dia',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(
                hasValues ? Icons.show_chart : Icons.horizontal_rule,
                color: hasValues ? AppColors.blue : AppColors.muted,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 86,
            child: LineChart(
              values: values,
              showGrid: true,
              showLastDot: hasValues,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Hace 6d',
                style: TextStyle(color: AppColors.muted, fontSize: 10),
              ),
              Text(
                'Hace 3d',
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

class _AlertCard extends StatelessWidget {
  final Incident alert;

  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final criticalityColor = _criticalityColor(alert.criticality);
    final statusColor = _statusColor(alert.status);

    return WhiteCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: criticalityColor.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(alert.icon, color: criticalityColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.anomaly,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${alert.deviceName} - ${alert.deviceLocation}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _Badge(label: alert.statusLabel, color: statusColor),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge(label: alert.sensorLabel, color: AppColors.blue),
              _Badge(
                label: 'Criticidad ${alert.criticalityLabel}',
                color: criticalityColor,
              ),
              _Badge(label: alert.time, color: AppColors.muted),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _AlertFact(label: 'Valor', value: alert.recordedValue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AlertFact(label: 'Umbral', value: alert.threshold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _criticalityColor(AlertCriticality value) {
    return switch (value) {
      AlertCriticality.high => AppColors.red,
      AlertCriticality.medium => AppColors.orange,
      AlertCriticality.low => AppColors.green,
    };
  }

  Color _statusColor(AlertStatus value) {
    return switch (value) {
      AlertStatus.active => AppColors.red,
      AlertStatus.pending => AppColors.orange,
      AlertStatus.resolved => AppColors.green,
    };
  }
}

class _AlertFact extends StatelessWidget {
  final String label;
  final String value;

  const _AlertFact({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 12,
            height: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptyAlerts extends StatelessWidget {
  const _EmptyAlerts();

  @override
  Widget build(BuildContext context) {
    return const WhiteCard(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 18),
          child: Text(
            'No hay alertas para mostrar',
            style: TextStyle(color: AppColors.muted),
          ),
        ),
      ),
    );
  }
}
