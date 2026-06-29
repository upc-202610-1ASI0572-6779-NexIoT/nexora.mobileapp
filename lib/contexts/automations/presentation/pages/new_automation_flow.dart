import 'package:flutter/material.dart';

import 'package:nexoraiot/app/theme/app_colors.dart';
import 'package:nexoraiot/contexts/automations/infrastructure/repositories/fake_automation_repository.dart';
import 'package:nexoraiot/contexts/automations/domain/entities/automation.dart';
import 'package:nexoraiot/contexts/automations/domain/repositories/automation_repository.dart';

class NewAutomationFlow extends StatefulWidget {
  const NewAutomationFlow({super.key});

  @override
  State<NewAutomationFlow> createState() => _NewAutomationFlowState();
}

class _NewAutomationFlowState extends State<NewAutomationFlow> {
  static const _stepTitles = [
    'Pick a trigger',
    'Select Action',
    'Set timer',
    'Review & save',
  ];

  static const _timerPresets = [5, 10, 15, 30, 60];

  final AutomationRepository _repository = FakeAutomationRepository();
  final _nameController = TextEditingController();

  int _step = 0;

  // Draft values collected through the wizard.
  TriggerType? _trigger;
  ActionType? _action;
  int _timerMinutes = 15;
  bool _nobodyHome = true;
  bool _notify = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _back() {
    if (_step == 0) {
      Navigator.of(context).pop();
    } else {
      setState(() => _step -= 1);
    }
  }

  void _goTo(int step) => setState(() => _step = step);

  Future<void> _save() async {
    final name = _nameController.text.trim();
    setState(() => _saving = true);

    final created = await _repository.createAutomation(
      Automation(
        name: name.isEmpty ? 'New automation' : name,
        trigger: _trigger!,
        action: _action!,
        timerMinutes: _timerMinutes,
        onlyWhenNobodyHome: _nobodyHome,
        notifyOnRun: _notify,
      ),
    );

    if (!mounted) return;
    Navigator.of(context).pop(created);
  }

  Future<void> _pickCustomTimer() async {
    final minutes = await showDialog<int>(
      context: context,
      builder: (_) => _CustomTimerDialog(initialMinutes: _timerMinutes),
    );

    if (minutes != null && minutes > 0) {
      setState(() => _timerMinutes = minutes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _WizardHeader(
            step: _step,
            title: _stepTitles[_step],
            onBack: _back,
            onCancel: () => Navigator.of(context).pop(),
          ),
          Expanded(child: _buildStep()),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildTriggerStep();
      case 1:
        return _buildActionStep();
      case 2:
        return _buildTimerStep();
      default:
        return _buildReviewStep();
    }
  }

  // --------------------------------------------------------------- Step 1
  Widget _buildTriggerStep() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      children: [
        const _StepLabel('WHEN...'),
        const SizedBox(height: 12),
        ...TriggerType.values.map(
          (trigger) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _OptionRow(
              icon: trigger.icon,
              title: trigger.label,
              selected: _trigger == trigger,
              onTap: () {
                setState(() => _trigger = trigger);
                _goTo(1);
              },
            ),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------- Step 2
  Widget _buildActionStep() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      children: [
        const _StepLabel('THEN PERFORM...'),
        const SizedBox(height: 12),
        ...ActionType.values.map(
          (action) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _OptionRow(
              icon: action.icon,
              title: action.label,
              subtitle: action.optionSubtitle,
              selected: _action == action,
              onTap: () {
                setState(() => _action = action);
                _goTo(2);
              },
            ),
          ),
        ),
        const SizedBox(height: 6),
        const _ProTipCard(),
      ],
    );
  }

  // --------------------------------------------------------------- Step 3
  Widget _buildTimerStep() {
    final unit = _timerMinutes < 60 ? 'min' : 'h';
    final amount =
        _timerMinutes < 60 ? '$_timerMinutes' : '${_timerMinutes ~/ 60}';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      children: [
        const _StepLabel('THEN TURN OFF AFTER...'),
        const SizedBox(height: 14),
        Center(
          child: Container(
            width: 150,
            padding: const EdgeInsets.symmetric(vertical: 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.blue, width: 1.6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    color: AppColors.blue,
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Text(
                    unit,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ..._timerPresets.map(
              (m) => _TimerChip(
                label: m < 60 ? '$m min' : '${m ~/ 60} h',
                selected: _timerMinutes == m,
                onTap: () => setState(() => _timerMinutes = m),
              ),
            ),
            _TimerChip(
              label: 'Custom',
              icon: Icons.edit_outlined,
              selected: !_timerPresets.contains(_timerMinutes),
              onTap: _pickCustomTimer,
            ),
          ],
        ),
        const SizedBox(height: 26),
        const _StepLabel('ONLY WHEN...'),
        const SizedBox(height: 12),
        _ToggleRow(
          icon: Icons.location_on_outlined,
          title: 'Nobody home',
          value: _nobodyHome,
          activeColor: AppColors.orange,
          onChanged: (v) => setState(() => _nobodyHome = v),
        ),
        const SizedBox(height: 10),
        _ToggleRow(
          icon: Icons.notifications_none,
          title: 'Send notification',
          value: _notify,
          onChanged: (v) => setState(() => _notify = v),
        ),
        const SizedBox(height: 18),
        const _SmartTipCard(),
        const SizedBox(height: 20),
        _PrimaryButton(
          label: 'Continue',
          onTap: () => _goTo(3),
        ),
      ],
    );
  }

  // --------------------------------------------------------------- Step 4
  Widget _buildReviewStep() {
    final trigger = _trigger!;
    final action = _action!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      children: [
        const _StepLabel('NAME'),
        const SizedBox(height: 10),
        TextField(
          controller: _nameController,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: 'Vacation Mode · Eco',
            hintStyle: const TextStyle(color: AppColors.muted),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.blue, width: 1.6),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const _StepLabel('SUMMARY'),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _SummaryRow(
                badge: 'IF',
                badgeColor: AppColors.blue,
                title: trigger.summaryTitle,
                subtitle: trigger.summarySubtitle,
              ),
              const Divider(height: 1, color: AppColors.border),
              _SummaryRow(
                badge: 'THEN',
                badgeColor: AppColors.orange,
                title: '${action.summaryTitle} · '
                    '${_timerMinutes < 60 ? '$_timerMinutes min' : '${_timerMinutes ~/ 60} h'}',
                subtitle: action.summarySubtitle,
              ),
              const Divider(height: 1, color: AppColors.border),
              _SummaryRow(
                badge: 'WHEN',
                badgeColor: AppColors.muted,
                title: _nobodyHome ? 'Nobody home' : 'Anytime',
                subtitle: _nobodyHome
                    ? 'Presence sensor trigger'
                    : 'No extra condition',
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: _OutlinedButton(
                label: 'Test',
                onTap: _saving
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Running test…'),
                            backgroundColor: AppColors.blue,
                          ),
                        );
                      },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _PrimaryButton(
                label: 'Save automation',
                loading: _saving,
                onTap: _saving ? null : _save,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// =========================================================== Header + progress
class _WizardHeader extends StatelessWidget {
  final int step;
  final String title;
  final VoidCallback onBack;
  final VoidCallback onCancel;

  const _WizardHeader({
    required this.step,
    required this.title,
    required this.onBack,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 8,
        right: 16,
        bottom: 14,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, color: AppColors.text),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STEP ${step + 1} / 4',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onCancel,
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: List.generate(4, (i) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i == 3 ? 0 : 6),
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= step ? AppColors.darkBlue : AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================== Option row
class _OptionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _OptionRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.blue : AppColors.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================================================================== Toggles
class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final Color activeColor;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.activeColor = AppColors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Switch(
            value: value,
            activeColor: activeColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ================================================================= Timer chips
class _TimerChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _TimerChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.blue : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.blue : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: selected ? Colors.white : AppColors.blue,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.text,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================== Summary row
class _SummaryRow extends StatelessWidget {
  final String badge;
  final Color badgeColor;
  final String title;
  final String subtitle;

  const _SummaryRow({
    required this.badge,
    required this.badgeColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    );
  }
}

// ===================================================================== Cards
class _ProTipCard extends StatelessWidget {
  const _ProTipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.white, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pro-tip',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'You can add multiple actions to the same trigger '
                  'in the next step to create richer routines.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
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

class _SmartTipCard extends StatelessWidget {
  const _SmartTipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEDEFF7), Color(0xFFF6F1EC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SMART TIP',
                  style: TextStyle(
                    color: AppColors.orange,
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Nexora learns your habits to suggest better timers.',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.blue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

// =================================================================== Buttons
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;

  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.blue.withOpacity(0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

class _OutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _OutlinedButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.blue,
          side: const BorderSide(color: AppColors.blue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

// ================================================================ Step label
class _StepLabel extends StatelessWidget {
  final String text;

  const _StepLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.muted,
        fontSize: 12,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

// ========================================================== Custom timer dialog
// Owns its own TextEditingController so the framework disposes it only after the
// dialog's exit animation completes (disposing it manually right after
// showDialog() resolves crashes while the TextField is still on screen).
class _CustomTimerDialog extends StatefulWidget {
  final int initialMinutes;

  const _CustomTimerDialog({required this.initialMinutes});

  @override
  State<_CustomTimerDialog> createState() => _CustomTimerDialogState();
}

class _CustomTimerDialogState extends State<_CustomTimerDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: '${widget.initialMinutes}');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(int.tryParse(_controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Custom timer'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        autofocus: true,
        onSubmitted: (_) => _submit(),
        decoration: const InputDecoration(
          suffixText: 'min',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('Set'),
        ),
      ],
    );
  }
}
