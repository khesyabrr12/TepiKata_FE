import 'package:flutter/material.dart';
import 'package:frontend/screens/homePage.dart';
import 'package:frontend/screens/landing.dart';
import 'package:frontend/screens/mainPage.dart';
import 'package:frontend/screens/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "TepiKata",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF4A6B5B)),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const MainPage(),
      },
    );
  }
  
}


