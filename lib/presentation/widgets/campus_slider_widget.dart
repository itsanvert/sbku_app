import 'package:flutter/material.dart';
import 'dart:async';

class ImageSlider extends StatefulWidget {
  final List<String> imagePaths;
  final double height;
  final Duration autoPlayDuration;
  final double borderRadius;
  final EdgeInsets padding;
  final EdgeInsets itemPadding;
  final BoxFit imageFit;
  final bool showIndicators;
  final bool autoPlay;
  final Color? activeIndicatorColor;
  final Color? inactiveIndicatorColor;
  final double indicatorHeight;
  final double activeIndicatorWidth;
  final double inactiveIndicatorWidth;
  final double indicatorSpacing;
  final bool showBorder;
  final List<Color>? borderGradientColors;
  final double borderWidth;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final Duration transitionDuration;
  final Curve transitionCurve;

  const ImageSlider({
    super.key,
    required this.imagePaths,
    this.height = 220,
    this.autoPlayDuration = const Duration(seconds: 4),
    this.borderRadius = 12,
    this.padding = EdgeInsets.zero,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 16),
    this.imageFit = BoxFit.cover,
    this.showIndicators = true,
    this.autoPlay = true,
    this.activeIndicatorColor,
    this.inactiveIndicatorColor,
    this.indicatorHeight = 8,
    this.activeIndicatorWidth = 24,
    this.inactiveIndicatorWidth = 8,
    this.indicatorSpacing = 16,
    this.showBorder = true,
    this.borderGradientColors,
    this.borderWidth = 5,
    this.backgroundColor,
    this.boxShadow,
    this.transitionDuration = const Duration(milliseconds: 600),
    this.transitionCurve = Curves.easeInOutCubic,
  });

  // Factory constructor for campus style (your current design)
  factory ImageSlider.campus({
    Key? key,
    required List<String> imagePaths,
    double height = 220,
    Duration autoPlayDuration = const Duration(seconds: 4),
  }) {
    return ImageSlider(
      key: key,
      imagePaths: imagePaths,
      height: height,
      autoPlayDuration: autoPlayDuration,
      showBorder: true,
      borderGradientColors: const [
        Color.fromARGB(255, 255, 118, 20),
        Color.fromARGB(255, 138, 49, 0),
      ],
      borderWidth: 5,
      backgroundColor: Colors.white,
      activeIndicatorColor: Color(0xFFFF6A00),
      inactiveIndicatorColor: Color(0xFFFF6A00),
    );
  }

  // Factory constructor for simple style (no border)
  factory ImageSlider.simple({
    Key? key,
    required List<String> imagePaths,
    double height = 220,
    Duration autoPlayDuration = const Duration(seconds: 4),
    BoxFit imageFit = BoxFit.cover,
  }) {
    return ImageSlider(
      key: key,
      imagePaths: imagePaths,
      height: height,
      autoPlayDuration: autoPlayDuration,
      showBorder: false,
      imageFit: imageFit,
    );
  }

  // Factory constructor for banner style (full width, no padding)
  factory ImageSlider.banner({
    Key? key,
    required List<String> imagePaths,
    double height = 180,
    Duration autoPlayDuration = const Duration(seconds: 4),
  }) {
    return ImageSlider(
      key: key,
      imagePaths: imagePaths,
      height: height,
      autoPlayDuration: autoPlayDuration,
      showBorder: false,
      itemPadding: EdgeInsets.zero,
      borderRadius: 0,
    );
  }

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    if (widget.autoPlay) {
      _startAutoPlay();
    }
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
        duration: widget.transitionDuration,
        curve: widget.transitionCurve,
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
    final effectiveActiveColor =
        widget.activeIndicatorColor ?? const Color(0xFFFF6A00);
    final effectiveInactiveColor =
        widget.inactiveIndicatorColor ?? const Color(0xFFFF6A00);

    return Padding(
      padding: widget.padding,
      child: Column(
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
                  padding: widget.itemPadding,
                  child: _buildSlideItem(widget.imagePaths[index]),
                );
              },
            ),
          ),
          if (widget.showIndicators) ...[
            SizedBox(height: widget.indicatorSpacing),
            _buildIndicators(effectiveActiveColor, effectiveInactiveColor),
          ],
        ],
      ),
    );
  }

  Widget _buildSlideItem(String imagePath) {
    if (widget.showBorder) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            colors: widget.borderGradientColors ??
                [
                  const Color.fromARGB(255, 255, 118, 20),
                  const Color.fromARGB(255, 138, 49, 0),
                ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: widget.boxShadow ??
              [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
        ),
        child: Container(
          margin: EdgeInsets.all(widget.borderWidth),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: widget.backgroundColor ?? Colors.white,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Image.asset(
              imagePath,
              fit: widget.imageFit,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child:
                        Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: widget.boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Image.asset(
          imagePath,
          fit: widget.imageFit,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIndicators(Color activeColor, Color inactiveColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.imagePaths.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: widget.indicatorHeight,
          width: _currentPage == index
              ? widget.activeIndicatorWidth
              : widget.inactiveIndicatorWidth,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? activeColor
                : inactiveColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(widget.indicatorHeight / 2),
          ),
        ),
      ),
    );
  }
}
