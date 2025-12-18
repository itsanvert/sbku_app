import 'package:flutter/material.dart';
import 'dart:async';

class CampusSlider extends StatefulWidget {
  final List<String> imagePaths;
  final double height;
  final Duration autoPlayDuration;

  const CampusSlider({
    super.key,
    required this.imagePaths,
    this.height = 220,
    this.autoPlayDuration = const Duration(seconds: 4),
  });

  @override
  State<CampusSlider> createState() => _CampusSliderState();
}

class _CampusSliderState extends State<CampusSlider> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    // Changed viewportFraction to 1.0 to show only one slide at a time
    _pageController = PageController(viewportFraction: 1.0);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(widget.autoPlayDuration, (timer) {
      if (_currentPage < widget.imagePaths.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.imagePaths.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CampusCard(imagePath: widget.imagePaths[index]),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.imagePaths.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentPage == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? const Color(0xFFFF6A00)
                    : const Color(0xFFFF6A00).withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CampusCard extends StatelessWidget {
  final String imagePath;

  const CampusCard({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF6A00)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(imagePath, fit: BoxFit.cover),
      ),
    );
  }
}

// Usage Example:
// CampusSlider(
//   imagePaths: [
//     'assets/images/campus1.png',
//     'assets/images/campus2.png',
//     'assets/images/campus3.png',
//   ],
// )
