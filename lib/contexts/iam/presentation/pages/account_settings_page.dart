import 'package:flutter/material.dart';

import 'package:nexoraiot/app/theme/app_colors.dart';
import 'package:nexoraiot/shared/presentation/widgets/top_bar.dart';
import 'package:nexoraiot/contexts/iam/application/services/session_service.dart';
import 'package:nexoraiot/contexts/iam/application/use_cases/update_profile_use_case.dart';
import 'package:nexoraiot/contexts/iam/infrastructure/api/auth_api_service.dart';
import 'package:nexoraiot/contexts/iam/infrastructure/repositories/auth_repository_impl.dart';

class AccountSettingsPage extends StatefulWidget {
  final String initialName;
  final String initialEmail;

  const AccountSettingsPage({
    super.key,
    required this.initialName,
    required this.initialEmail,
  });

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  late final TextEditingController fullNameController;
  late final TextEditingController emailController;
  late final UpdateProfileUseCase updateProfileUseCase;

  bool isSaving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    fullNameController = TextEditingController(text: widget.initialName);
    emailController = TextEditingController(text: widget.initialEmail);

    final repository = AuthRepositoryImpl(
      apiService: AuthApiService(),
      sessionService: SessionService(),
    );

    updateProfileUseCase = UpdateProfileUseCase(repository);
  }

  Future<void> saveChanges() async {
    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    try {
      final fullName = fullNameController.text.trim();
      final email = emailController.text.trim();

      if (fullName.isEmpty || email.isEmpty) {
        throw Exception('Complete all fields.');
      }

      if (!email.contains('@')) {
        throw Exception('Enter a valid email.');
      }

      await updateProfileUseCase.execute(
        token: 'temporary-auth-token',
        fullName: fullName,
        email: email,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );

      Navigator.pop(context);
    } catch (error) {
      setState(() {
        errorMessage = error.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TopBar(title: 'Account Settings'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 42,
                  backgroundColor: Color(0xFFDDE2FF),
                  child: Icon(
                    Icons.person,
                    color: AppColors.blue,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Change photo',
                  style: TextStyle(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 28),
                _InputField(
                  label: 'Full Name',
                  controller: fullNameController,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 14),
                _InputField(
                  label: 'Email',
                  controller: emailController,
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 14),
                const _DisabledField(
                  label: 'Phone Number',
                  value: '+51 955 1234 567',
                  icon: Icons.phone_outlined,
                ),
                const SizedBox(height: 14),
                const _DisabledField(
                  label: 'Country',
                  value: 'Perú',
                  icon: Icons.keyboard_arrow_down,
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: AppColors.red),
                  ),
                ],
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: isSaving ? null : saveChanges,
                    child: Text(isSaving ? 'Saving...' : 'Save Changes'),
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

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;

  const _InputField({
    required this.label,
    required this.controller,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: Icon(icon, color: AppColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _DisabledField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DisabledField({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: false,
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: Icon(icon, color: AppColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}