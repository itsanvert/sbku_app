// lib/main.dart
import 'package:flutter/material.dart';
import 'package:sbku_app/screen/home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SBKU App',
      theme: ThemeData(primarySwatch: Colors.orange, useMaterial3: true),
      home: const HomePageScreen(),
    );
  }
}
