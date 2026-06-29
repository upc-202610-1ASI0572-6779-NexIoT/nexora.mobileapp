import 'dart:async';

import 'package:flutter/material.dart';

import 'package:nexoraiot/app/config/app_config.dart';
import 'package:nexoraiot/app/theme/app_colors.dart';
import 'package:nexoraiot/shared/presentation/widgets/white_card.dart';
import 'package:nexoraiot/contexts/consumption/domain/entities/live_reading.dart';
import 'package:nexoraiot/contexts/consumption/domain/repositories/consumption_repository.dart';
import 'package:nexoraiot/contexts/consumption/infrastructure/repositories/http_consumption_repository.dart';

/// Real-time strip showing the instantaneous current (A) and water flow (L/min)
/// straight from the devices — the same values shown in the Wokwi simulation.
/// Polls the backend's `/telemetries/latest` endpoint on a fixed interval.
class LiveConsumptionCard extends StatefulWidget {
  final ConsumptionRepository? repository;

  const LiveConsumptionCard({super.key, this.repository});

  @override
  State<LiveConsumptionCard> createState() => _LiveConsumptionCardState();
}

class _LiveConsumptionCardState extends State<LiveConsumptionCard> {
  late final ConsumptionRepository _repository;
  Timer? _timer;
  LiveReading? _water;
  LiveReading? _power;
  bool _loaded = false;
  bool _live = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? HttpConsumptionRepository();
    _fetch();
    _timer = Timer.periodic(AppConfig.livePollInterval, (_) => _fetch());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetch() async {
    try {
      final results = await Future.wait([
        _repository.getLatestReading(AppConfig.waterDeviceId),
        _repository.getLatestReading(AppConfig.powerDeviceId),
      ]);
      if (!mounted) return;
      setState(() {
        _water = results[0];
        _power = results[1];
        _loaded = true;
        _live = true;
      });
    } catch (_) {
      // Keep the last known values; just drop the "live" indicator.
      if (!mounted) return;
      setState(() {
        _loaded = true;
        _live = false;
      });
    }
  }

  String _fmt(double? value) =>
      value == null ? '—' : value.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'REAL-TIME',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              _LiveDot(live: _live && _loaded),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _LiveMetric(
                  icon: Icons.bolt,
                  iconColor: AppColors.orange,
                  label: 'Current',
                  value: _fmt(_power?.electricityReading),
                  unit: 'A',
                ),
              ),
              Container(
                width: 1,
                height: 44,
                color: AppColors.border,
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: _LiveMetric(
                  icon: Icons.water_drop_outlined,
                  iconColor: AppColors.blue,
                  label: 'Water flow',
                  value: _fmt(_water?.waterReading),
                  unit: 'L/min',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LiveMetric extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;

  const _LiveMetric({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                        height: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LiveDot extends StatefulWidget {
  final bool live;

  const _LiveDot({required this.live});

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.live ? AppColors.green : AppColors.muted;
    return Row(
      children: [
        widget.live
            ? FadeTransition(
                opacity: Tween<double>(begin: 0.35, end: 1.0).animate(
                  _controller,
                ),
                child: _dot(color),
              )
            : _dot(color),
        const SizedBox(width: 6),
        Text(
          widget.live ? 'LIVE' : 'OFFLINE',
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _dot(Color color) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
