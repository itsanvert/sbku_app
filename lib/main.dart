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
    return MaterialApp(title: 'SBKU App', home: const HomePageScreen());
  }
}
