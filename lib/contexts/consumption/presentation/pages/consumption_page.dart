import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:nexoraiot/app/theme/app_colors.dart';
import 'package:nexoraiot/shared/presentation/widgets/chip_label.dart';
import 'package:nexoraiot/shared/presentation/widgets/line_chart.dart';
import 'package:nexoraiot/shared/presentation/widgets/section_label.dart';
import 'package:nexoraiot/shared/presentation/widgets/top_bar.dart';
import 'package:nexoraiot/shared/presentation/widgets/white_card.dart';
import 'package:nexoraiot/contexts/consumption/domain/entities/consumption_view.dart';
import 'package:nexoraiot/contexts/consumption/presentation/pages/consumption_alert_page.dart';
import 'package:nexoraiot/contexts/properties/domain/entities/app_data.dart';

class ConsumptionPage extends StatefulWidget {
  final AppData data;
  final ValueChanged<int>? onDestinationSelected;

  const ConsumptionPage({
    super.key,
    required this.data,
    this.onDestinationSelected,
  });

  @override
  State<ConsumptionPage> createState() => _ConsumptionPageState();
}

class _ConsumptionPageState extends State<ConsumptionPage> {
  ConsumptionMetric _metric = ConsumptionMetric.water;
  ConsumptionRange _range = ConsumptionRange.week;

  ConsumptionView get _view => widget.data.consumption[_metric]![_range]!;

  String _areaLabel(double value) {
    if (_metric == ConsumptionMetric.water) {
      return '${value.toStringAsFixed(0)} ${_metric.areaUnit}';
    }
    return '${value.toStringAsFixed(1)} ${_metric.areaUnit}';
  }

  Future<void> _openConsumptionAlert() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConsumptionAlertPage(
          data: widget.data,
          metric: _metric,
          range: _range,
          view: _view,
          onDestinationSelected: widget.onDestinationSelected,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final view = _view;
    final maxValue = view.areas.map((area) => area.value).reduce(math.max);

    return Column(
      children: [
        const TopBar(
          title: 'Consumption',
          actionIcon: Icons.filter_alt_outlined,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 24),
            child: Column(
              children: [
                _SegmentControl(
                  metric: _metric,
                  onChanged: (m) => setState(() => _metric = m),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final range in ConsumptionRange.values) ...[
                        ChipLabel(
                          range.chip,
                          selected: _range == range,
                          onTap: () => setState(() => _range = range),
                        ),
                        if (range != ConsumptionRange.values.last)
                          const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _openConsumptionAlert,
                    borderRadius: BorderRadius.circular(8),
                    child: WhiteCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _range.headline,
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.muted,
                                size: 20,
                              ),
                            ],
                          ),
                          if (view.highUsage) ...[
                            const SizedBox(height: 4),
                            const Text(
                              'High Usage Alert',
                              style: TextStyle(
                                color: AppColors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                view.totalLabel,
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.text,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 7),
                                child: Text(
                                  view.unit,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            view.deltaLabel,
                            style: TextStyle(
                              color: view.increase
                                  ? AppColors.orange
                                  : AppColors.green,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 125,
                            child: LineChart(
                              values: view.series,
                              showGrid: true,
                              showLastDot: true,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              for (final label in view.axisLabels)
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
                ),
                const SizedBox(height: 14),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: SectionLabel('DETAIL BY AREA'),
                ),
                const SizedBox(height: 8),
                WhiteCard(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    children: view.areas.map((area) {
                      final percent = area.value / maxValue;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    area.area,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Text(
                                  _areaLabel(area.value),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percent,
                                minHeight: 4,
                                color: AppColors.blue,
                                backgroundColor: AppColors.border,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
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

class _SegmentControl extends StatelessWidget {
  final ConsumptionMetric metric;
  final ValueChanged<ConsumptionMetric> onChanged;

  const _SegmentControl({
    required this.metric,
    required this.onChanged,
  });

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
              Icon(
                icon,
                size: 14,
                color: selected ? AppColors.blue : AppColors.muted,
              ),
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
