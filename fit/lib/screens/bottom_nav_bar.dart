// lib/screens/bottom_nav_bar.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'workout_plan_screen.dart';
import 'trainer_list_screen.dart';
import 'chat_threads_screen.dart';
import 'profile_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  bool? _isTrainer;
  int? _trainerId;

  @override
  void initState() {
    super.initState();
    _determineRole();
  }

  Future<void> _determineRole() async {
    final api = ApiService();
    // 1) Профиль мен currentUserId
    await api.getProfile();
    final meId = api.currentUserId;
    // 2) Жаттықтырушылар тізімі
    final list = await api.getTrainers();
    final trainers = List<Map<String, dynamic>>.from(list);
    // 3) Өз user-ің жаттықтырушы ма?
    final mine = trainers.firstWhere(
      (t) => (t['user'] as int) == meId,
      orElse: () => <String, dynamic>{},
    );
    setState(() {
      if (mine.isNotEmpty) {
        _isTrainer = true;
        _trainerId = mine['id'] as int;
      } else {
        _isTrainer = false;
      }
    });
  }

  void _onTap(int idx) => setState(() => _selectedIndex = idx);

  @override
  Widget build(BuildContext context) {
    // Рөл анықталмағанша индикатор көрсетеміз
    if (_isTrainer == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Экрандар тізімі
    final screens = <Widget>[
      const HomeScreen(),
      WorkoutPlanScreen(),
      // Егер жаттықтырушы болса – чат тізімі, әйтпесе – жаттықтырушылар тізімі
      if (_isTrainer! && _trainerId != null)
        ChatThreadsScreen(trainerId: _trainerId!)
      else
        const TrainerListScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[50],
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}
