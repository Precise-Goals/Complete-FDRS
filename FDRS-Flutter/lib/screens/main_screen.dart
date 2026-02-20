import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/main_viewmodel.dart';
import 'sos_screen.dart';
import 'knowledge_base_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MainViewModel(),
      child: Consumer<MainViewModel>(
        builder: (context, model, child) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                _buildScreen(context, model),
                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: _buildBottomNav(context, model),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScreen(BuildContext context, MainViewModel model) {
    final authService = context.watch<AuthService>();
    final screens = [
      const SosScreen(),
      const KnowledgeBaseScreen(),
      authService.isLoggedIn ? const ProfileScreen() : const LoginScreen(),
    ];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: screens[model.currentIndex],
    );
  }

  Widget _buildBottomNav(BuildContext context, MainViewModel model) {
    return Center(
      child: Container(
        height: 70,
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(20, 20, 20, 0.85),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.1)),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.8),
              blurRadius: 40,
              offset: Offset(0, -10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(context, model, 0, Icons.home_rounded, 'Home'),
                _buildNavItem(
                    context, model, 1, Icons.info_outline_rounded, 'Info'),
                _buildNavItem(
                    context, model, 2, Icons.person_outline_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, MainViewModel model, int index,
      IconData icon, String label) {
    bool isSelected = model.currentIndex == index;

    return GestureDetector(
      onTap: () => model.onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: isSelected
                  ? BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        if (index == 1)
                          const BoxShadow(
                            color: Color(0x66FF9500),
                            blurRadius: 15,
                          ),
                      ],
                    )
                  : null,
              child: Icon(
                icon,
                color: isSelected
                    ? (index == 1 ? const Color(0xFFFF9500) : Colors.white)
                    : Colors.grey[500],
                size: 28,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: isSelected ? Colors.white : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
