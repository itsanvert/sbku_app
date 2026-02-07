import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double height;
  final double borderRadius;
  final Gradient gradient;
  final Color textColor;
  final double horizontalMargin;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 50, // 👈 smaller height
    this.borderRadius = 10,
    this.textColor = Colors.white,
    this.horizontalMargin = 24, // 👈 controls width
    this.gradient = const LinearGradient(
      colors: [
        Color(0xFFFF6A00),
        Color(0xFFB33A00),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
      child: SizedBox(
        width: double.infinity, // 👈 full available width
        height: height,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(borderRadius),
            onTap: onPressed,
            child: Ink(
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15, // 👈 slightly smaller text
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
