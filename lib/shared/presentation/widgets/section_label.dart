import 'package:flutter/material.dart';

import 'package:nexoraiot/app/theme/app_colors.dart';

class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel(
      this.text, {
        super.key,
      });

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
