import 'package:flutter/material.dart';

import 'package:nexoraiot/app/theme/app_colors.dart';
import 'package:nexoraiot/shared/presentation/widgets/chip_label.dart';
import 'package:nexoraiot/shared/presentation/widgets/line_chart.dart';
import 'package:nexoraiot/shared/presentation/widgets/section_label.dart';
import 'package:nexoraiot/shared/presentation/widgets/top_bar.dart';
import 'package:nexoraiot/shared/presentation/widgets/white_card.dart';
import 'package:nexoraiot/contexts/consumption/domain/entities/consumption_report.dart';
import 'package:nexoraiot/contexts/consumption/domain/entities/consumption_view.dart';
import 'package:nexoraiot/contexts/consumption/domain/repositories/consumption_repository.dart';
import 'package:nexoraiot/contexts/consumption/infrastructure/repositories/http_consumption_repository.dart';
import 'package:nexoraiot/contexts/consumption/presentation/pages/consumption_alert_page.dart';
import 'package:nexoraiot/contexts/consumption/presentation/widgets/live_consumption_card.dart';
import 'package:nexoraiot/contexts/consumption/presentation/widgets/report_time.dart';
import 'package:nexoraiot/contexts/properties/domain/entities/app_data.dart';

class ConsumptionPage extends StatefulWidget {
  final AppData data;
  final ValueChanged<int>? onDestinationSelected;
  final ConsumptionRepository? repository;

  const ConsumptionPage({
    super.key,
    required this.data,
    this.onDestinationSelected,
    this.repository,
  });

  @override
  State<ConsumptionPage> createState() => _ConsumptionPageState();
}

class _ConsumptionPageState extends State<ConsumptionPage> {
  late final ConsumptionRepository _repository;
  ConsumptionMetric _metric = ConsumptionMetric.water;
  ConsumptionRange _range = ConsumptionRange.week;
  Future<ConsumptionReport>? _future;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? HttpConsumptionRepository();
    _load();
  }

  void _load() {
    _future = _repository.getReport(metric: _metric, range: _range);
  }

  void _setMetric(ConsumptionMetric metric) {
    if (metric == _metric) return;
    setState(() {
      _metric = metric;
      _load();
    });
  }

  void _setRange(ConsumptionRange range) {
    if (range == _range) return;
    setState(() {
      _range = range;
      _load();
    });
  }

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  Future<void> _openDetail(ConsumptionReport report) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConsumptionAlertPage(
          data: widget.data,
          report: report,
          onDestinationSelected: widget.onDestinationSelected,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TopBar(title: 'Reports'),
        _Filters(
          metric: _metric,
          range: _range,
          onMetric: _setMetric,
          onRange: _setRange,
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.blue,
            onRefresh: _refresh,
            child: FutureBuilder<ConsumptionReport>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _LoadingState();
                }
                if (snapshot.hasError) {
                  return _ErrorState(onRetry: _refresh);
                }
                final report = snapshot.data;
                if (report == null || !report.hasData) {
                  return const _EmptyState();
                }
                return _ReportBody(
                  report: report,
                  onOpenDetail: () => _openDetail(report),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Report body
// ---------------------------------------------------------------------------

class _ReportBody extends StatelessWidget {
  final ConsumptionReport report;
  final VoidCallback onOpenDetail;

  const _ReportBody({required this.report, required this.onOpenDetail});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 24),
      child: Column(
        children: [
          _SummaryCard(report: report, onTap: onOpenDetail),
          const SizedBox(height: 12),
          _KpiRow(report: report),
          const SizedBox(height: 14),
          _InsightCard(report: report),
          if (report.sources.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Align(
              alignment: Alignment.centerLeft,
              child: SectionLabel('BY SOURCE'),
            ),
            const SizedBox(height: 8),
            _SourceBreakdown(report: report),
          ],
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final ConsumptionReport report;
  final VoidCallback onTap;

  const _SummaryCard({required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: WhiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    report.range.headline,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const Spacer(),
                  if (report.highUsage) ...[
                    const _Badge(text: 'HIGH USAGE'),
                    const SizedBox(width: 6),
                  ],
                  const Icon(Icons.chevron_right,
                      color: AppColors.muted, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    report.totalLabel,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      report.unit,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (report.comparable)
                Row(
                  children: [
                    Icon(
                      report.increase
                          ? Icons.trending_up
                          : Icons.trending_down,
                      size: 15,
                      color:
                          report.increase ? AppColors.orange : AppColors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      report.deltaLabel,
                      style: TextStyle(
                        color: report.increase
                            ? AppColors.orange
                            : AppColors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              else
                const Row(
                  children: [
                    Icon(Icons.timelapse, size: 15, color: AppColors.muted),
                    SizedBox(width: 4),
                    Text(
                      'Building history to compare',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              const SizedBox(height: 18),
              SizedBox(
                height: 125,
                child: LineChart(
                  values: report.series,
                  showGrid: true,
                  showLastDot: true,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final label
                      in buildAxisLabels(report.lastReadingAt, report.range))
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  final ConsumptionReport report;

  const _KpiRow({required this.report});

  @override
  Widget build(BuildContext context) {
    final peakTime =
        report.peakAt != null ? clockTime(report.peakAt!) : '—';
    final updated = report.lastReadingAt != null
        ? relativeTime(report.lastReadingAt!)
        : '—';

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.show_chart,
            iconColor: report.highUsage ? AppColors.orange : AppColors.blue,
            value: report.peakLabel,
            unit: report.rateUnit,
            label: 'Peak · $peakTime',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.equalizer_outlined,
            iconColor: AppColors.blue,
            value: report.averageValueLabel,
            unit: report.unit,
            label: 'Avg ${report.averageLabel}',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.schedule,
            iconColor: AppColors.green,
            value: updated,
            unit: '',
            label: 'Updated',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String unit;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.unit,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                    height: 1.0,
                  ),
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 3),
                Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: Text(
                    unit,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final ConsumptionReport report;

  const _InsightCard({required this.report});

  String get _text {
    if (report.highUsage) {
      return 'Peak ${report.metric.label.toLowerCase()} reached '
          '${report.peakLabel} ${report.rateUnit}, above the safe limit of '
          '${ConsumptionReport.formatNumber(report.safeThreshold)} ${report.rateUnit}. '
          'Review usage during peak hours.';
    }
    if (!report.comparable) {
      return 'Collecting readings to build your usage baseline. Period '
          'comparisons will appear once there is enough history.';
    }
    final pct = report.deltaPercent.abs();
    final pctText = pct >= 10 ? pct.toStringAsFixed(0) : pct.toStringAsFixed(1);
    if (report.increase) {
      return 'Usage is up $pctText% vs the ${report.range.previousLabel}. '
          'Keep an eye on the trend to avoid surprises.';
    }
    return 'Usage is down $pctText% vs the ${report.range.previousLabel}. '
        'Nice — consumption is trending in the right direction.';
  }

  @override
  Widget build(BuildContext context) {
    final positive =
        report.comparable && !report.highUsage && !report.increase;
    final accent = report.highUsage
        ? AppColors.orange
        : (positive ? AppColors.green : AppColors.blue);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            report.highUsage
                ? Icons.warning_amber_rounded
                : (positive ? Icons.eco_outlined : Icons.insights_outlined),
            color: accent,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Insight',
                  style: TextStyle(
                    color: AppColors.darkBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _text,
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
}

class _SourceBreakdown extends StatelessWidget {
  final ConsumptionReport report;

  const _SourceBreakdown({required this.report});

  @override
  Widget build(BuildContext context) {
    final maxValue = report.sources
        .map((s) => s.value)
        .fold<double>(0, (a, b) => b > a ? b : a);

    return WhiteCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      child: Column(
        children: [
          for (final source in report.sources)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          source.label,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        '${ConsumptionReport.formatNumber(source.value)} ${report.unit}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: maxValue > 0 ? source.value / maxValue : 0,
                            minHeight: 5,
                            color: AppColors.blue,
                            backgroundColor: AppColors.border,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 38,
                        child: Text(
                          '${source.sharePercent.toStringAsFixed(0)}%',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;

  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.red,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filters
// ---------------------------------------------------------------------------

class _Filters extends StatelessWidget {
  final ConsumptionMetric metric;
  final ConsumptionRange range;
  final ValueChanged<ConsumptionMetric> onMetric;
  final ValueChanged<ConsumptionRange> onRange;

  const _Filters({
    required this.metric,
    required this.range,
    required this.onMetric,
    required this.onRange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 0),
      child: Column(
        children: [
          _SegmentControl(metric: metric, onChanged: onMetric),
          const SizedBox(height: 12),
          const LiveConsumptionCard(),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final r in ConsumptionRange.values) ...[
                  ChipLabel(
                    r.chip,
                    selected: range == r,
                    onTap: () => onRange(r),
                  ),
                  if (r != ConsumptionRange.values.last)
                    const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentControl extends StatelessWidget {
  final ConsumptionMetric metric;
  final ValueChanged<ConsumptionMetric> onChanged;

  const _SegmentControl({required this.metric, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1EA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _Segment(
            icon: Icons.water_drop_outlined,
            label: 'Water',
            selected: metric == ConsumptionMetric.water,
            onTap: () => onChanged(ConsumptionMetric.water),
          ),
          _Segment(
            icon: Icons.bolt,
            label: 'Electricity',
            selected: metric == ConsumptionMetric.electricity,
            onTap: () => onChanged(ConsumptionMetric.electricity),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Segment({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 14, color: selected ? AppColors.blue : AppColors.muted),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.blue : AppColors.muted,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Async states
// ---------------------------------------------------------------------------

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 80),
        child: CircularProgressIndicator(color: AppColors.blue),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 90, 24, 24),
      children: const [
        Icon(Icons.insights_outlined, size: 54, color: AppColors.muted),
        SizedBox(height: 14),
        Text(
          'No readings yet',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Once your devices start sending data, your consumption report will '
          'appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, height: 1.35),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 90, 24, 24),
      children: [
        const Icon(Icons.cloud_off_outlined, size: 54, color: AppColors.muted),
        const SizedBox(height: 14),
        const Text(
          "Couldn't load report",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Please check your connection and try again.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, height: 1.35),
        ),
        const SizedBox(height: 18),
        Center(
          child: OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.blue,
              side: const BorderSide(color: AppColors.blue),
            ),
          ),
        ),
      ],
    );
  }
}
