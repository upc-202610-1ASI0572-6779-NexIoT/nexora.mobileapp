import 'package:flutter/material.dart';

import 'package:nexoraiot/app/theme/app_colors.dart';
import 'package:nexoraiot/shared/presentation/widgets/section_label.dart';
import 'package:nexoraiot/shared/presentation/widgets/white_card.dart';
import 'package:nexoraiot/contexts/automations/domain/entities/automation.dart';
import 'new_automation_flow.dart';

class AutomationsPage extends StatefulWidget {
  final List<Automation> automations;

  const AutomationsPage({
    super.key,
    required this.automations,
  });

  @override
  State<AutomationsPage> createState() => _AutomationsPageState();
}

class _AutomationsPageState extends State<AutomationsPage> {
  // Operate on the shared list so toggles and new automations stay in sync
  // with the count shown on the Devices tab.
  List<Automation> get _automations => widget.automations;

  int get _activeCount => _automations.where((a) => a.enabled).length;

  Future<void> _createAutomation() async {
    final created = await Navigator.of(context).push<Automation>(
      MaterialPageRoute(builder: (_) => const NewAutomationFlow()),
    );

    if (created == null || !mounted) return;

    setState(() => _automations.insert(0, created));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('“${created.name}” created'),
        backgroundColor: AppColors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _Header(onBack: () => Navigator.of(context).pop()),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 20, 14, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryCard(activeCount: _activeCount),
                  const SizedBox(height: 16),
                  _NewAutomationButton(onTap: _createAutomation),
                  const SizedBox(height: 24),
                  const SectionLabel('YOUR AUTOMATIONS'),
                  const SizedBox(height: 10),
                  ..._automations.map((automation) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AutomationTile(
                        automation: automation,
                        onChanged: (value) {
                          setState(() => automation.enabled = value);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
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
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 8,
        right: 16,
        bottom: 12,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'Automations',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int activeCount;

  const _SummaryCard({required this.activeCount});

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
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
                    'AUTOMATIONS',
                    style: TextStyle(
                      color: AppColors.muted,
                      letterSpacing: 1.2,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$activeCount Active',
                    style: const TextStyle(
                      color: AppColors.blue,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.circle,
                        color: AppColors.orange,
                        size: 7,
                      ),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Text(
                          'System optimizing energy usage',
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
            color: AppColors.blue.withOpacity(0.08),
          ),
        ],
      ),
    );
  }
}

class _NewAutomationButton extends StatelessWidget {
  final VoidCallback onTap;

  const _NewAutomationButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'New automation',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _AutomationTile extends StatelessWidget {
  final Automation automation;
  final ValueChanged<bool> onChanged;

  const _AutomationTile({
    required this.automation,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F2FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              automation.action.icon,
              color: AppColors.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  automation.name,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  automation.summaryLine,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: automation.enabled,
              activeColor: AppColors.blue,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
