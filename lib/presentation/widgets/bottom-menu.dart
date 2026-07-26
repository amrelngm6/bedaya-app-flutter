import 'package:bedaya2/core/modules/doctors/presentation/pages/doctors_list_page.dart';
import 'package:bedaya2/core/modules/patients/presentation/pages/settings_page.dart';
import 'package:bedaya2/core/modules/services/presentation/pages/services_list_page.dart';
import 'package:bedaya2/presentation/widgets/side_menu_bottom.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:bedaya2/presentation/pages/home_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int currentIndex = 0;

  final pages = const [
    HomePage(),
    ServicesListPage(),
    DoctorsListPage(),
    SettingsPage(),
    SideMenuBottom(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && currentIndex != 0) {
          setState(() {
            currentIndex = 0;
          });
        }
      },
      child: Scaffold(
        body: IndexedStack(index: currentIndex, children: pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'home'.tr(),
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: 'services'.tr(),
            ),
            NavigationDestination(
              icon: Icon(Icons.medical_services_outlined),
              selectedIcon: Icon(Icons.medical_services),
              label: 'Doctors'.tr(),
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'settings'.tr(),
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_outlined),
              selectedIcon: Icon(Icons.menu),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
