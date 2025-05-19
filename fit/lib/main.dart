import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/bottom_nav_bar.dart';

// lib/main.dart

void main() => runApp(const MyApp());
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext c) {
    return MaterialApp(
      title: 'Fitness Coach App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/login',
      routes: {
        '/login':     (_) => const LoginScreen(),
        '/register':  (_) => RegisterScreen(),
        // !!! осында HomeScreen емес, BottomNavBar беру керек !!!
        '/home':      (_) => const BottomNavBar(),
      },
    );
  }
}
