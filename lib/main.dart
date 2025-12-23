// lib/main.dart
import 'package:flutter/material.dart';
import 'package:sbku_app/screens/home/home_screen.dart';

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
      home: const HomePageScreen(),
    );
  }
}
