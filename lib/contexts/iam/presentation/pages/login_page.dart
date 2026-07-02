import 'package:flutter/material.dart';

import 'package:nexoraiot/app/theme/app_colors.dart';
import 'package:nexoraiot/contexts/iam/application/services/session_service.dart';
import 'package:nexoraiot/contexts/iam/application/use_cases/login_use_case.dart';
import 'package:nexoraiot/contexts/iam/infrastructure/api/auth_api_service.dart';
import 'package:nexoraiot/contexts/iam/infrastructure/repositories/auth_repository_impl.dart';
import 'package:nexoraiot/contexts/iam/presentation/pages/register_page.dart';
import 'package:nexoraiot/shared/presentation/widgets/auth_primary_button.dart';
import 'package:nexoraiot/shared/presentation/widgets/auth_text_field.dart';
import 'package:nexoraiot/shared/presentation/widgets/social_button.dart';

import 'package:nexoraiot/app/router/main_shell.dart';
import 'package:nexoraiot/contexts/properties/infrastructure/repositories/http_properties_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late final LoginUseCase loginUseCase;

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    final repository = AuthRepositoryImpl(
      apiService: AuthApiService(),
      sessionService: SessionService(),
    );

    loginUseCase = LoginUseCase(repository);
  }

  Future<void> handleLogin() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        throw Exception('Complete all fields.');
      }

      if (!email.contains('@')) {
        throw Exception('Enter a valid email.');
      }

      await loginUseCase.execute(
        email: email,
        password: password,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful')),
      );

      final data = await HttpPropertiesRepository().getDashboardData();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => MainShell(data: data),
        ),
            (route) => false,
      );
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
              flex: 50,
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
                      'Your smart home,\nin a single app.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Monitor consumption, control devices and\nreceive alerts in real time.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 50,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
                color: const Color(0xFFF7F8F4),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      AuthTextField(
                        label: 'Email',
                        hint: 'maria.castillo@nexora.com',
                        controller: emailController,
                      ),
                      const SizedBox(height: 14),
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
                        text: 'Log in',
                        isLoading: isLoading,
                        onPressed: handleLogin,
                      ),
                      const SizedBox(height: 14),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          );
                        },
                        child: const Text('Create account'),
                      ),
                      const SizedBox(height: 8),
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
                          SocialButton(icon: Icons.apple, text: 'Apple'),
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