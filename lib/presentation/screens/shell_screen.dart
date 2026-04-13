import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'home/home_screen.dart';
import 'courses/courses_screen.dart';
import 'ai_tutor/ai_tutor_screen.dart';
import 'profile/profile_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    CoursesScreen(),
    AITutorScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_rounded),
            label: '课程',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_rounded),
            label: 'AI 助手',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
