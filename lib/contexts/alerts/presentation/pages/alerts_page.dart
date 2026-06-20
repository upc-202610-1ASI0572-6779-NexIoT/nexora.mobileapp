import 'package:flutter/material.dart';

import 'package:nexoraiot/app/theme/app_colors.dart';
import 'package:nexoraiot/shared/presentation/widgets/top_bar.dart';
import 'package:nexoraiot/shared/presentation/widgets/white_card.dart';
import 'package:nexoraiot/contexts/alerts/domain/entities/incident.dart';
import 'package:nexoraiot/contexts/properties/domain/entities/app_data.dart';

enum _AlertFilter { all, active, solved }

class AlertsPage extends StatefulWidget {
  final AppData data;

  const AlertsPage({
    super.key,
    required this.data,
  });

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  _AlertFilter _filter = _AlertFilter.all;

  List<Incident> get _incidents => widget.data.incidents;

  bool _isActive(Incident i) => i.level != IncidentLevel.solved;

  int get _activeCount => _incidents.where(_isActive).length;
  int get _solvedCount => _incidents.length - _activeCount;

  List<Incident> get _filtered {
    switch (_filter) {
      case _AlertFilter.active:
        return _incidents.where(_isActive).toList();
      case _AlertFilter.solved:
        return _incidents.where((i) => !_isActive(i)).toList();
      case _AlertFilter.all:
        return _incidents;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Column(
      children: [
        const TopBar(
          title: 'Incidents Center',
          actionIcon: Icons.search,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(10, 22, 10, 24),
            child: Column(
              children: [
                Row(
                  children: const [
                    Expanded(
                      child: _IncidentSummaryCard(
                        title: 'Critical',
                        icon: Icons.error_outline,
                        color: AppColors.orange,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _IncidentSummaryCard(
                        title: 'Warning',
                        icon: Icons.warning_amber_outlined,
                        color: Color(0xFFE7B83E),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _IncidentSummaryCard(
                        title: 'Solved',
                        icon: Icons.check_circle_outline,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _AlertTab(
                        label: 'All • ${_incidents.length}',
                        selected: _filter == _AlertFilter.all,
                        onTap: () =>
                            setState(() => _filter = _AlertFilter.all),
                      ),
                      const SizedBox(width: 30),
                      _AlertTab(
                        label: 'Active • $_activeCount',
                        selected: _filter == _AlertFilter.active,
                        onTap: () =>
                            setState(() => _filter = _AlertFilter.active),
                      ),
                      const SizedBox(width: 30),
                      _AlertTab(
                        label: 'Solved • $_solvedCount',
                        selected: _filter == _AlertFilter.solved,
                        onTap: () =>
                            setState(() => _filter = _AlertFilter.solved),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(
                  color: AppColors.text,
                  height: 1,
                  thickness: 1,
                ),
                const SizedBox(height: 20),
                if (filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Text(
                      'No incidents to show',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ),
                ...filtered.map((incident) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _IncidentCard(incident: incident),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AlertTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AlertTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(
        label,
        style: TextStyle(
          color: selected ? AppColors.text : AppColors.muted,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _IncidentSummaryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _IncidentSummaryCard({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final Incident incident;

  const _IncidentCard({
    required this.incident,
  });

  @override
  Widget build(BuildContext context) {
    final isCritical = incident.level == IncidentLevel.critical;

    return WhiteCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEDF5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              incident.icon,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isCritical
                            ? AppColors.orange
                            : const Color(0xFFE7B83E),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        isCritical ? 'CRIT' : 'WARN',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      incident.time,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  incident.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  incident.subtitle,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            incident.status,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
