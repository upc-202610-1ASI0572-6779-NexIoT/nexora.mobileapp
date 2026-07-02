import 'package:flutter/material.dart';

import 'package:nexoraiot/app/theme/app_colors.dart';
import 'package:nexoraiot/contexts/iam/application/services/session_service.dart';
import 'package:nexoraiot/contexts/iam/presentation/pages/login_page.dart';
import 'package:nexoraiot/contexts/properties/infrastructure/repositories/http_properties_repository.dart';
import 'package:nexoraiot/contexts/properties/domain/entities/app_data.dart';
import 'package:nexoraiot/contexts/properties/domain/repositories/properties_repository.dart';
import 'router/main_shell.dart';

class NexoraApp extends StatelessWidget {
  const NexoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexora IoT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue),
        useMaterial3: true,
      ),
      home: const AppLoader(),
    );
  }
}

class AppLoader extends StatefulWidget {
  const AppLoader({super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  final SessionService _sessionService = SessionService();
  final PropertiesRepository _repository = HttpPropertiesRepository();

  late final Future<bool> _sessionFuture;

  @override
  void initState() {
    super.initState();
    _sessionFuture = _sessionService.hasActiveSession();
  }

  Future<AppData> _loadDashboardData() {
    return _repository.getDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _sessionFuture,
      builder: (context, sessionSnapshot) {
        if (!sessionSnapshot.hasData) {
          return const _LoadingScreen();
        }

        final hasSession = sessionSnapshot.data ?? false;

        if (!hasSession) {
          return const LoginPage();
        }

        return FutureBuilder<AppData>(
          future: _loadDashboardData(),
          builder: (context, dataSnapshot) {
            if (!dataSnapshot.hasData) {
              return const _LoadingScreen();
            }

            return MainShell(data: dataSnapshot.data!);
          },
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.blue,
        ),
      ),
    );
  }
}