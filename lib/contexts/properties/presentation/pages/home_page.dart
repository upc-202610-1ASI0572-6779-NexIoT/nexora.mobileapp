import 'package:flutter/material.dart';

import 'package:nexoraiot/app/theme/app_colors.dart';
import 'package:nexoraiot/shared/presentation/widgets/line_chart.dart';
import 'package:nexoraiot/shared/presentation/widgets/section_label.dart';
import 'package:nexoraiot/shared/presentation/widgets/white_card.dart';
import 'package:nexoraiot/contexts/properties/domain/entities/app_data.dart';

class HomePage extends StatefulWidget {
  final AppData data;

  const HomePage({
    super.key,
    required this.data,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool bedroomLights = true;
  bool livingRoomLights = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HomeHeader(data: widget.data),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _AlertBanner(),
                const SizedBox(height: 20),
                const SectionLabel('REAL TIME CONSUMPTION'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.water_drop_outlined,
                        iconColor: AppColors.blue,
                        title: 'WATER TODAY',
                        value: '${widget.data.waterToday}',
                        unit: 'L',
                        variation: '↑ 12%',
                        variationColor: AppColors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.bolt,
                        iconColor: AppColors.orange,
                        title: 'ENERGY TODAY',
                        value: widget.data.energyToday.toStringAsFixed(1),
                        unit: 'kWh',
                        variation: '↓ 8%',
                        variationColor: AppColors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _ChartCard(
                  title: 'Latest 24 h',
                  action: 'See details',
                  values: widget.data.latest24h,
                  height: 72,
                ),
                const SizedBox(height: 20),
                Row(
                  children: const [
                    Expanded(child: SectionLabel('QUICK CONTROL')),
                    Text(
                      'View all',
                      style: TextStyle(
                        color: AppColors.blue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _SwitchCard(
                        icon: Icons.light_mode_outlined,
                        title: 'Bedroom lights',
                        subtitle: '100%',
                        value: bedroomLights,
                        onChanged: (value) {
                          setState(() {
                            bedroomLights = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SwitchCard(
                        icon: Icons.lightbulb_outline,
                        title: 'Living room lights',
                        subtitle: '60%',
                        value: livingRoomLights,
                        onChanged: (value) {
                          setState(() {
                            livingRoomLights = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _HomeSecureCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final AppData data;

  const _HomeHeader({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.blue,
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Good morning',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  data.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFF344EA0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF2B46A0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.circle,
                  size: 9,
                  color: Color(0xFF57E36F),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${data.homeName} · All active systems',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  const _AlertBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.orange,
          width: 1.4,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0E5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.orange,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Possible leak detected',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Master bathroom · 4 min ago',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.muted,
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String unit;
  final String variation;
  final Color variationColor;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.unit,
    required this.variation,
    required this.variationColor,
  });

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                ),
              ),
              const Spacer(),
              Text(
                variation,
                style: TextStyle(
                  color: variationColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  unit,
                  style: const TextStyle(
                    color: AppColors.muted,
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

class _ChartCard extends StatelessWidget {
  final String title;
  final String action;
  final List<double> values;
  final double height;

  const _ChartCard({
    required this.title,
    required this.action,
    required this.values,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                action,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: height,
            child: LineChart(values: values),
          ),
        ],
      ),
    );
  }
}

class _SwitchCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.blue,
              ),
              const Spacer(),
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: value,
                  activeColor: AppColors.blue,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeSecureCard extends StatelessWidget {
  const _HomeSecureCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.green,
          width: 1.3,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F7EA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.home_outlined,
              color: AppColors.green,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Home secure',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Everything looks good at San Isidro\nHouse. You can relax.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.muted,
          ),
        ],
      ),
    );
  }
}
