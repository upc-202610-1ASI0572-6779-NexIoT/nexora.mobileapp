import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final IconData icon;
  final String text;

  const SocialButton({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}