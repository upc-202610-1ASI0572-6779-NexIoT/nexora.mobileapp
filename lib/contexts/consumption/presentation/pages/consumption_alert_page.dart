import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:nexoraiot/app/theme/app_colors.dart';
import 'package:nexoraiot/shared/presentation/widgets/white_card.dart';
import 'package:nexoraiot/contexts/automations/domain/entities/automation.dart';
import 'package:nexoraiot/contexts/automations/presentation/pages/new_automation_flow.dart';
import 'package:nexoraiot/contexts/consumption/domain/entities/consumption_area.dart';
import 'package:nexoraiot/contexts/consumption/domain/entities/consumption_view.dart';
import 'package:nexoraiot/contexts/properties/domain/entities/app_data.dart';

class ConsumptionAlertPage extends StatelessWidget {
  final AppData data;
  final ConsumptionMetric metric;
  final ConsumptionRange range;
  final ConsumptionView view;
  final ValueChanged<int>? onDestinationSelected;

  const ConsumptionAlertPage({
    super.key,
    required this.data,
    required this.metric,
    required this.range,
    required this.view,
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
    final topConsumer = view.areas.reduce(
      (current, next) => next.value > current.value ? next : current,
    );
    final percent = _deltaPercent(view.deltaLabel);
    final metricName = metric == ConsumptionMetric.water ? 'Water' : 'Energy';
    final title = 'High $metricName Consumption\nDetected';
    final savings = metric == ConsumptionMetric.water ? '8%' : '15';
    final suggestion = metric == ConsumptionMetric.water
        ? 'Reducing peak-area use could save approximately $savings% this month.'
        : 'Setting the AC to 24°C could save you approximately \$$savings this month.';

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
                  _AlertHero(
                    title: title,
                    message:
                        'Your ${metric.label.toLowerCase()} usage is $percent% higher than usual this ${range == ConsumptionRange.day ? 'morning' : range.chip.toLowerCase()}.',
                  ),
                  const SizedBox(height: 14),
                  _UsageComparisonCard(
                    percent: percent,
                    range: range,
                    values: view.series,
                  ),
                  const SizedBox(height: 14),
                  _TopConsumerCard(
                    metric: metric,
                    topConsumer: topConsumer,
                  ),
                  const SizedBox(height: 14),
                  _SuggestionCard(text: suggestion),
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
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          _AlertBottomNavigation(
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
              'Consumption Alert',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_alt_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _AlertHero extends StatelessWidget {
  final String title;
  final String message;

  const _AlertHero({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: AppColors.orange,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 24,
            height: 1.25,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 14,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _UsageComparisonCard extends StatelessWidget {
  final int percent;
  final ConsumptionRange range;
  final List<double> values;

  const _UsageComparisonCard({
    required this.percent,
    required this.range,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    final labels = _labelsFor(range);
    final comparedTo = range == ConsumptionRange.day ? 'yesterday' : 'last ${range.chip.toLowerCase()}';

    return WhiteCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Expanded(
                child: Text(
                  'USAGE COMPARISON',
                  style: TextStyle(
                    color: AppColors.text,
                    letterSpacing: 1.4,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                Icons.trending_up,
                color: AppColors.orange,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+$percent%',
                style: const TextStyle(
                  color: Color(0xFF9B3F00),
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Text(
                  'vs $comparedTo',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: _ComparisonBars(
              values: values,
              labels: labels,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _labelsFor(ConsumptionRange range) {
    return switch (range) {
      ConsumptionRange.day => ['12 AM', '6 AM', '12 PM', '6 PM', 'Now'],
      ConsumptionRange.week => ['Week 1', 'Week 2', 'Week 3', 'Week 4', 'Today'],
      ConsumptionRange.month => ['May', 'Jun', 'Jul', 'Aug', 'Now'],
      ConsumptionRange.year => ['2022', '2023', '2024', '2025', 'Now'],
    };
  }
}

class _ComparisonBars extends StatelessWidget {
  final List<double> values;
  final List<String> labels;

  const _ComparisonBars({
    required this.values,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final sample = _sample(values, labels.length);
    final maxValue = sample.reduce(math.max);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: FractionallySizedBox(
                    heightFactor: math.max(0.16, sample[i] / maxValue),
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _barColor(i),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  labels[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: i == labels.length - 1
                        ? AppColors.text
                        : AppColors.muted,
                    fontSize: 10,
                    fontWeight: i == labels.length - 1
                        ? FontWeight.w800
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (i != labels.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }

  Color _barColor(int index) {
    if (index == labels.length - 1) return AppColors.orange;
    if (index == labels.length - 2) return const Color(0xFFA8B2D0);
    return const Color(0xFFEDEEF3);
  }

  List<double> _sample(List<double> source, int count) {
    if (source.length <= count) return source;
    final step = (source.length - 1) / (count - 1);
    return List.generate(count, (index) => source[(index * step).round()]);
  }
}

class _TopConsumerCard extends StatelessWidget {
  final ConsumptionMetric metric;
  final ConsumptionArea topConsumer;

  const _TopConsumerCard({
    required this.metric,
    required this.topConsumer,
  });

  @override
  Widget build(BuildContext context) {
    final value = metric == ConsumptionMetric.water
        ? topConsumer.value.toStringAsFixed(0)
        : topConsumer.value.toStringAsFixed(1);

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
              metric == ConsumptionMetric.water
                  ? Icons.water_drop_outlined
                  : Icons.ac_unit,
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
                  'Top Consumer',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  topConsumer.area,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    height: 1.0,
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
                value,
                style: const TextStyle(
                  color: AppColors.darkBlue,
                  fontSize: 30,
                  height: 0.95,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '${metric.areaUnit}\ntoday',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 10,
                  height: 1.1,
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
  final String text;

  const _SuggestionCard({required this.text});

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
          const Icon(
            Icons.lightbulb_outline,
            color: Color(0xFF9B3F00),
            size: 20,
          ),
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
                  text,
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

class _AlertBottomNavigation extends StatelessWidget {
  final ValueChanged<int>? onDestinationSelected;

  const _AlertBottomNavigation({
    required this.onDestinationSelected,
  });

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

int _deltaPercent(String label) {
  final match = RegExp(r'\d+').firstMatch(label);
  return int.tryParse(match?.group(0) ?? '') ?? 18;
}
