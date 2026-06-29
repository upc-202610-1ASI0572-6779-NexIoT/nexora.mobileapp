import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:nexoraiot/app/theme/app_colors.dart';
import 'package:nexoraiot/shared/presentation/widgets/white_card.dart';
import 'package:nexoraiot/contexts/automations/domain/entities/automation.dart';
import 'package:nexoraiot/contexts/automations/presentation/pages/new_automation_flow.dart';
import 'package:nexoraiot/contexts/consumption/domain/entities/consumption_report.dart';
import 'package:nexoraiot/contexts/consumption/domain/entities/consumption_view.dart';
import 'package:nexoraiot/contexts/consumption/presentation/widgets/report_time.dart';
import 'package:nexoraiot/contexts/properties/domain/entities/app_data.dart';

/// Drill-down detail reached by tapping the report summary card. Shows a
/// period-over-period comparison, the top contributing source and a smart,
/// actionable suggestion (which can be turned into an automation).
class ConsumptionAlertPage extends StatelessWidget {
  final AppData data;
  final ConsumptionReport report;
  final ValueChanged<int>? onDestinationSelected;

  const ConsumptionAlertPage({
    super.key,
    required this.data,
    required this.report,
    this.onDestinationSelected,
  });

  Future<void> _createAutomation(BuildContext context) async {
    final created = await Navigator.of(context).push<Automation>(
      MaterialPageRoute(builder: (_) => const NewAutomationFlow()),
    );

    if (created == null || !context.mounted) return;

    data.automations.insert(0, created);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${created.name}" created'),
        backgroundColor: AppColors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final metricName = report.metric.label;
    final title = report.highUsage
        ? 'High $metricName Consumption'
        : '$metricName Consumption Detail';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(onBack: () => Navigator.of(context).pop()),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 18),
              child: Column(
                children: [
                  _Hero(report: report, title: title),
                  const SizedBox(height: 14),
                  _ComparisonCard(report: report),
                  if (report.sources.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _TopSourceCard(report: report),
                  ],
                  const SizedBox(height: 14),
                  _SuggestionCard(report: report),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _createAutomation(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Create automation',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
          _DetailBottomNavigation(
            onDestinationSelected: onDestinationSelected,
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.blue,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 4,
        left: 2,
        right: 12,
        bottom: 10,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'Consumption Detail',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final ConsumptionReport report;
  final String title;

  const _Hero({required this.report, required this.title});

  @override
  Widget build(BuildContext context) {
    final positive =
        report.comparable && !report.highUsage && !report.increase;
    final accent = report.highUsage
        ? AppColors.orange
        : (positive ? AppColors.green : AppColors.blue);
    final updated = report.lastReadingAt != null
        ? 'Updated ${relativeTime(report.lastReadingAt!)}'
        : '';

    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          child: Icon(
            report.highUsage
                ? Icons.warning_amber_rounded
                : (report.metric == ConsumptionMetric.water
                    ? Icons.water_drop_outlined
                    : Icons.bolt),
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 23,
            height: 1.2,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${report.totalLabel} ${report.unit} • ${report.range.headline.toLowerCase()}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 14,
            height: 1.35,
          ),
        ),
        if (updated.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            updated,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  final ConsumptionReport report;

  const _ComparisonCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final pct = report.deltaPercent.abs();
    final pctText = pct >= 10 ? pct.toStringAsFixed(0) : pct.toStringAsFixed(1);
    final accent = report.increase ? AppColors.orange : AppColors.green;

    if (!report.comparable) {
      return WhiteCard(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.timelapse, color: AppColors.muted, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PERIOD COMPARISON',
                    style: TextStyle(
                      color: AppColors.text,
                      letterSpacing: 1.2,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Not enough history yet to compare against the '
                    '${report.range.previousLabel}. Keep your devices online '
                    'and this will fill in over time.',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return WhiteCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'PERIOD COMPARISON',
                  style: TextStyle(
                    color: AppColors.text,
                    letterSpacing: 1.2,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                report.increase ? Icons.trending_up : Icons.trending_down,
                color: accent,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${report.increase ? '+' : '−'}$pctText%',
                style: TextStyle(
                  color: accent,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Text(
                  'vs ${report.range.previousLabel}',
                  style: const TextStyle(color: AppColors.text, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _CompareBars(
            previous: report.previousTotal,
            current: report.total,
            unit: report.unit,
            currentColor: accent,
          ),
        ],
      ),
    );
  }
}

class _CompareBars extends StatelessWidget {
  final double previous;
  final double current;
  final String unit;
  final Color currentColor;

  const _CompareBars({
    required this.previous,
    required this.current,
    required this.unit,
    required this.currentColor,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = math.max(previous, math.max(current, 0.0001));
    return Column(
      children: [
        _bar('Previous', previous, maxValue, const Color(0xFFB8C0D6)),
        const SizedBox(height: 12),
        _bar('Current', current, maxValue, currentColor),
      ],
    );
  }

  Widget _bar(String label, double value, double maxValue, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (value / maxValue).clamp(0.0, 1.0),
              minHeight: 10,
              color: color,
              backgroundColor: const Color(0xFFEDEEF3),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 78,
          child: Text(
            '${ConsumptionReport.formatNumber(value)} $unit',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
        ),
      ],
    );
  }
}

class _TopSourceCard extends StatelessWidget {
  final ConsumptionReport report;

  const _TopSourceCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final top = report.sources.first;
    return WhiteCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEDF5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              report.metric == ConsumptionMetric.water
                  ? Icons.water_drop_outlined
                  : Icons.electrical_services,
              color: AppColors.darkBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Top source',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  top.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${top.sharePercent.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: AppColors.darkBlue,
                  fontSize: 28,
                  height: 1.0,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'of total',
                style: TextStyle(
                  color: AppColors.muted.withOpacity(0.9),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final ConsumptionReport report;

  const _SuggestionCard({required this.report});

  String get _text {
    final isWater = report.metric == ConsumptionMetric.water;
    if (report.highUsage) {
      return isWater
          ? 'A peak above the safe flow can signal a leak or a tap left open. '
              'A leak auto-shutoff automation can react instantly.'
          : 'High current was detected. Spreading heavy appliances across the '
              'day helps avoid overload and breaker trips.';
    }
    if (report.increase) {
      return isWater
          ? 'Usage is climbing. Scheduling water-heavy tasks off-peak keeps '
              'consumption smooth.'
          : 'Usage is climbing. An eco schedule for climate devices can offset '
              'the increase.';
    }
    return isWater
        ? 'Great trend. Keep leak alerts on to maintain low usage.'
        : 'Great trend. Eco automations are paying off — keep them running.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF2F3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline,
              color: Color(0xFF9B3F00), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Smart Suggestion',
                  style: TextStyle(
                    color: AppColors.darkBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _text,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 14,
                    height: 1.28,
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

class _DetailBottomNavigation extends StatelessWidget {
  final ValueChanged<int>? onDestinationSelected;

  const _DetailBottomNavigation({required this.onDestinationSelected});

  void _select(BuildContext context, int index) {
    if (index != 3) {
      onDestinationSelected?.call(index);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_outlined, 'Home', false, 0),
      (Icons.desktop_windows_outlined, 'Devices', false, 1),
      (Icons.warning_amber_outlined, 'Alerts', false, 2),
      (Icons.bar_chart_outlined, 'Reports', true, 3),
      (Icons.person_outline, 'Profile', false, 4),
    ];

    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: InkWell(
                onTap: () => _select(context, item.$4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.$1,
                      size: 20,
                      color: item.$3 ? AppColors.blue : AppColors.muted,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.$2,
                      style: TextStyle(
                        color: item.$3 ? AppColors.blue : AppColors.muted,
                        fontSize: 10,
                        fontWeight:
                            item.$3 ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
