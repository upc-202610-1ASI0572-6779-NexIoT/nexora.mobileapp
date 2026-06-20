import 'package:flutter/material.dart';

import 'package:nexoraiot/app/theme/app_colors.dart';
import 'package:nexoraiot/contexts/alerts/presentation/pages/alerts_page.dart';
import 'package:nexoraiot/contexts/consumption/presentation/pages/consumption_page.dart';
import 'package:nexoraiot/contexts/properties/domain/entities/app_data.dart';
import 'package:nexoraiot/contexts/devices/presentation/pages/devices_page.dart';
import 'package:nexoraiot/contexts/properties/presentation/pages/home_page.dart';
import 'package:nexoraiot/contexts/iam/presentation/pages/profile_page.dart';

class MainShell extends StatefulWidget {
  final AppData data;

  const MainShell({
    super.key,
    required this.data,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  void _selectIndex(int value) {
    setState(() {
      index = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(data: widget.data),
      DevicesPage(data: widget.data),
      AlertsPage(data: widget.data),
      ConsumptionPage(
        data: widget.data,
        onDestinationSelected: _selectIndex,
      ),
      ProfilePage(data: widget.data),
    ];

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: _selectIndex,
        selectedItemColor: AppColors.blue,
        unselectedItemColor: AppColors.muted,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.desktop_windows_outlined),
            label: 'Devices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber_outlined),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
