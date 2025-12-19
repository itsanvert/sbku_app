// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/student_list_screen.dart';
import 'screens/test_luncher_screen .dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Student CRUD',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const TestLauncherScreen(),
    );
  }
}
