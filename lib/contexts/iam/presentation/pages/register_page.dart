import 'package:flutter/material.dart';

import 'package:nexoraiot/app/theme/app_colors.dart';
import 'package:nexoraiot/contexts/iam/application/services/session_service.dart';
import 'package:nexoraiot/contexts/iam/application/use_cases/register_use_case.dart';
import 'package:nexoraiot/contexts/iam/infrastructure/api/auth_api_service.dart';
import 'package:nexoraiot/contexts/iam/infrastructure/repositories/auth_repository_impl.dart';
import 'package:nexoraiot/shared/presentation/widgets/auth_primary_button.dart';
import 'package:nexoraiot/shared/presentation/widgets/auth_text_field.dart';
import 'package:nexoraiot/shared/presentation/widgets/social_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late final RegisterUseCase registerUseCase;

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    final repository = AuthRepositoryImpl(
      apiService: AuthApiService(),
      sessionService: SessionService(),
    );

    registerUseCase = RegisterUseCase(repository);
  }

  Future<void> handleRegister() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final firstName = firstNameController.text.trim();
      final lastName = lastNameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (firstName.isEmpty ||
          lastName.isEmpty ||
          email.isEmpty ||
          password.isEmpty) {
        throw Exception('Complete all fields.');
      }

      if (!email.contains('@')) {
        throw Exception('Enter a valid email.');
      }

      if (password.length < 6) {
        throw Exception('Password must have at least 6 characters.');
      }

      await registerUseCase.execute(
        fullName: '$firstName $lastName',
        email: email,
        password: password,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully')),
      );

      Navigator.pop(context);
    } catch (error) {
      setState(() {
        errorMessage = error.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blue,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 42,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '▰ Nexora',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Create your account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Join us to manage your smart home devices\nseamlessly from anywhere',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 58,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F8F4),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      AuthTextField(
                        label: 'First Name',
                        hint: 'Maria',
                        controller: firstNameController,
                      ),
                      const SizedBox(height: 12),
                      AuthTextField(
                        label: 'Last Name',
                        hint: 'Castillo',
                        controller: lastNameController,
                      ),
                      const SizedBox(height: 12),
                      AuthTextField(
                        label: 'Email',
                        hint: 'maria.castillo@nexora.com',
                        controller: emailController,
                      ),
                      const SizedBox(height: 12),
                      AuthTextField(
                        label: 'Password',
                        hint: '••••••••••',
                        controller: passwordController,
                        obscureText: true,
                        suffixIcon: Icons.visibility_outlined,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Forgot your password? →',
                          style: TextStyle(
                            color: AppColors.blue,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (errorMessage != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: AppColors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      AuthPrimaryButton(
                        text: 'Sign up',
                        isLoading: isLoading,
                        onPressed: handleRegister,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: const [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'or',
                              style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: const [
                          SocialButton(
                            icon: Icons.apple,
                            text: 'Apple',
                          ),
                          SizedBox(width: 12),
                          SocialButton(
                            icon: Icons.g_mobiledata,
                            text: 'Google',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}