import 'package:flutter/material.dart';
import 'package:sbku_app/widgets/campus_card.dart';
import 'package:sbku_app/widgets/card_widget.dart';
import 'package:sbku_app/widgets/feature_grid.dart';
import '../../widgets/header_widget.dart';

class HomePageScreen extends StatelessWidget {
  const HomePageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const GreetingCard(),
            const SizedBox(height: 16),

            const FeatureGrid(),
            const SizedBox(height: 16),
            const CampusSlider(
              imagePaths: [
                'assets/images/campus.png',
                'assets/images/campus.png',
                'assets/images/campus.png',
              ],
            ),
          ],
        ),
      ),
    );
  }
}
