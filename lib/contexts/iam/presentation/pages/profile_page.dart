import 'package:flutter/material.dart';

import 'package:nexoraiot/app/theme/app_colors.dart';
import 'package:nexoraiot/shared/presentation/widgets/top_bar.dart';
import 'package:nexoraiot/shared/presentation/widgets/white_card.dart';
import 'package:nexoraiot/contexts/properties/domain/entities/app_data.dart';
import 'package:nexoraiot/contexts/iam/application/services/session_service.dart';
import 'package:nexoraiot/contexts/iam/presentation/pages/account_settings_page.dart';

import 'package:nexoraiot/contexts/iam/presentation/pages/login_page.dart';

class ProfilePage extends StatelessWidget {
  final AppData data;

  const ProfilePage({
    super.key,
    required this.data,
  });

  Future<void> _logout(BuildContext context) async {
    final sessionService = SessionService();
    await sessionService.clearSession();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session closed successfully')),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TopBar(title: 'Profile Options'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
            child: Column(
              children: [
                WhiteCard(
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDDE2FF),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.userName,
                              style: const TextStyle(
                                color: AppColors.darkBlue,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Premium Homeowner',
                              style: TextStyle(
                                color: AppColors.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _ProfileOption(
                  icon: Icons.manage_accounts_outlined,
                  title: 'Account Settings',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AccountSettingsPage(
                          initialName: data.userName,
                          initialEmail: 'maria.castillo@nexora.com',
                        ),
                      ),
                    );
                  },
                ),
                const _ProfileOption(
                  icon: Icons.security_outlined,
                  title: 'Security',
                ),
                const _ProfileOption(
                  icon: Icons.credit_card_outlined,
                  title: 'Subscription and\npayments',
                  active: true,
                  badge: 'Active',
                ),
                const _ProfileOption(
                  icon: Icons.language,
                  title: 'Language',
                  value: 'English',
                ),
                const _ProfileOption(
                  icon: Icons.notifications_none,
                  title: 'Notifications',
                ),
                const _ProfileOption(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () => _logout(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFFFB8B8),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.logout,
                          color: AppColors.red,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Log Out',
                          style: TextStyle(
                            color: AppColors.red,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Nexora Smart Home v2.4.1\nDesigned for Latin American Housing',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
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

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final bool active;
  final String? badge;
  final VoidCallback? onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    this.value,
    this.active = false,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final optionContent = Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFF8FAFF) : Colors.white,
        border: Border.all(
          color: active ? AppColors.blue : AppColors.border,
          width: active ? 1.4 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.blue,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: active ? AppColors.darkBlue : AppColors.text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: AppColors.orange,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                ),
              ),
            ),
          if (value != null)
            Text(
              value!,
              style: const TextStyle(
                color: AppColors.muted,
              ),
            ),
          const SizedBox(width: 4),
          const Icon(
            Icons.chevron_right,
            color: AppColors.muted,
          ),
        ],
      ),
    );

    if (onTap == null) {
      return optionContent;
    }

    return GestureDetector(
      onTap: onTap,
      child: optionContent,
    );
  }
}