import 'package:flutter/material.dart';

import 'package:nexoraiot/app/theme/app_colors.dart';

class TopBar extends StatelessWidget {
  final String title;
  final IconData? actionIcon;

  const TopBar({
    super.key,
    required this.title,
    this.actionIcon,
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
        bottom: 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          if (actionIcon != null) Icon(actionIcon, color: Colors.white),
        ],
      ),
    );
  }
}
