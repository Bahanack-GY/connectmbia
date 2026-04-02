import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'home/home_screen.dart';
import 'chat/discussions_list_screen.dart';
import 'notifications/notifications_screen.dart';
import 'profile/profile_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/modern_app_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      extendBody: true,
      appBar: _currentIndex == 0
          ? const HomeGlassAppBar()
          : _currentIndex == 2
              ? ModernAppBar(
                  title: 'Profil'.tr(),
                  actions: [
                    ModernAppBarAction(
                      icon: Icons.notifications_none,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                )
              : null,
      body: IndexedStack(
        index: _currentIndex,
        children: const [HomeBody(), DiscussionsListScreen(), ProfileScreen()],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
