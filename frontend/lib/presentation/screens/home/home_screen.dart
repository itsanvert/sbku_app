import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sbku_app/presentation/screens/attendance/attendance_list_catgories.dart';
import 'package:sbku_app/presentation/screens/staff/staff_list_view_screen.dart';
import 'package:sbku_app/presentation/screens/student/student_list_view_screen.dart';
import 'package:sbku_app/presentation/screens/syllabus/syllabus_list_view_screen.dart';
import 'package:sbku_app/presentation/screens/attendance/request_permission_screen.dart';
import 'package:sbku_app/presentation/screens/teacher/teacher_list_screen.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import 'package:sbku_app/presentation/widgets/campus_slider_widget.dart';
import 'package:sbku_app/presentation/widgets/greeting_card_widget.dart';
import 'package:sbku_app/presentation/widgets/feature_grid_widget.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late final AnimationController _animController;

  // ── Grid section (starts immediately) ────────────────────────────
  late final Animation<Offset> _gridSlide;

  // ── Slider section (staggered start) ─────────────────────────────
  late final Animation<Offset> _sliderSlide;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _gridSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve:
            const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _sliderSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve:
            const Interval(0.25, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isLoading = false);
        _animController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Widget _buildContent() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: GreetingCard(),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 550),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (Widget child, Animation<double> anim) {
            return FadeTransition(opacity: anim, child: child);
          },
          child: _isLoading
              ? const FeatureGridSkeleton(
                  key: ValueKey('grid_skeleton'),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: 6,
                )
              : SlideTransition(
                  key: const ValueKey('grid_content'),
                  position: _gridSlide,
                  child: FeatureGrid(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    features: const [
                      FeatureItem(
                        icon: Icons.people,
                        label: 'គ្រូបង្រៀន',
                        screen: TeacherListViewScreen(),
                      ),
                      FeatureItem(
                        icon: Icons.school,
                        label: 'សិស្ស',
                        screen: StudentListViewScreen(),
                      ),
                      FeatureItem(
                        icon: Icons.group,
                        label: 'បុគ្គលិក',
                        screen: StaffListViewScreen(),
                      ),
                      FeatureItem(
                        icon: Icons.event,
                        label: 'អវត្តមាន',
                        screen: AttendanceListCategoryScreen(),
                      ),
                      FeatureItem(
                        icon: Icons.list_alt,
                        label: 'ស្នើរសុំច្បាប់',
                        screen: RequestPermissionScreen(),
                      ),
                      FeatureItem(
                        icon: Icons.subject,
                        label: 'តារាងមុខវិជ្ជា',
                        screen: SyllabusListViewScreen(),
                      ),
                    ],
                  ),
                ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 550),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (Widget child, Animation<double> anim) {
            return FadeTransition(opacity: anim, child: child);
          },
          child: _isLoading
              ? const ImageSliderSkeleton(
                  key: ValueKey('slider_skeleton'),
                  itemPadding: EdgeInsets.symmetric(horizontal: 16),
                )
              : SlideTransition(
                  key: const ValueKey('slider_content'),
                  position: _sliderSlide,
                  child: ImageSlider.campus(
                    imagePaths: const [
                      'assets/images/campus.png',
                      'assets/images/campus.png',
                      'assets/images/campus.png',
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget.home(
        enableScaling: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: _buildContent(),
      ),
    );
  }
}
