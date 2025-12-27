// lib/main.dart
import 'package:flutter/material.dart';
import 'package:sbku_app/screen/home/home_screen.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'SBKU App',
    theme: ThemeData(primarySwatch: Colors.orange, useMaterial3: true),
    home: const HomePageScreen(),
  ));
}
