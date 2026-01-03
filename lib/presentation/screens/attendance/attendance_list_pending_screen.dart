import 'package:flutter/material.dart';
import 'package:sbku_app/data/dummy_attendance.dart';
import 'package:sbku_app/data/dummy_faculty.dart';
import 'package:sbku_app/data/dummy_major.dart';
import 'package:sbku_app/model/attendance_model.dart';
import 'package:sbku_app/presentation/screens/attendance/action/add_edit_attendance_screen.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import 'package:sbku_app/presentation/widgets/appbutton_widget.dart';
import 'package:sbku_app/presentation/widgets/empty_state_widget.dart';
import 'package:sbku_app/presentation/widgets/filter_row_widget.dart';
import 'package:sbku_app/data/dummy_class.dart';

import 'package:sbku_app/data/dummy_shirt.dart';
import 'package:sbku_app/data/dummy_year.dart';

import 'package:sbku_app/presentation/widgets/list_item_widget.dart';

class AttendanceListPendingScreen extends StatefulWidget {
  const AttendanceListPendingScreen({super.key});

  @override
  State<AttendanceListPendingScreen> createState() =>
      _AttendanceListPendingScreenState();
}

class _AttendanceListPendingScreenState
    extends State<AttendanceListPendingScreen> {
  String? _selectedFacultyId;
  String? _selectedShiftId;
  String? _selectedYearId;
  // ✅ Map Entity → UI Model
  late final List<AttendanceModel> _attendances = dummyAttendanceEntities
      .map((e) => AttendanceModel(
            entity: e,
            facultyName: dummyFaculties
                .firstWhere((f) => f.facultyId == e.facultyId)
                .facultyName,
            majorName:
                dummyMajors.firstWhere((m) => m.majorId == e.majorId).majorName,
            shiftName:
                dummyShifts.firstWhere((s) => s.shiftId == e.shiftId).shiftName,
            className: dummyClasses
                .firstWhere((c) => c.classId == e.classId)
                .className,
            yearName:
                dummyYears.firstWhere((y) => y.yearId == e.yearId).yearName,
            startTime:
                dummyShifts.firstWhere((s) => s.shiftId == e.shiftId).startTime,
            endTime:
                dummyShifts.firstWhere((s) => s.shiftId == e.shiftId).endTime,
          ))
      .toList();

  // ✅ Filtering (ID-based)
  List<AttendanceModel> get filteredAttendance {
    return _attendances.where((attendance) {
      final facultyMatch = _selectedFacultyId == null ||
          attendance.entity.facultyId == _selectedFacultyId;

      final shiftMatch = _selectedShiftId == null ||
          attendance.entity.shiftId == _selectedShiftId;

      final yearMatch = _selectedYearId == null ||
          attendance.entity.yearId == _selectedYearId;

      return facultyMatch && shiftMatch && yearMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget.simple(
        title: 'ដំណើរអវត្តមាន',
      ),
      body: Column(
        children: [
          // 🔹 Filters
          FilterRowWidget(
            filters: [
              // FACULTY
              FilterConfig(
                value: _selectedFacultyId,
                hint: 'មហាវិទ្យាល័យ',
                items: dummyFaculties.map((f) => f.facultyId).toList(),
                labelBuilder: (id) => dummyFaculties
                    .firstWhere((f) => f.facultyId == id)
                    .facultyName,
                onChanged: (value) =>
                    setState(() => _selectedFacultyId = value),
              ),

              // YEAR
              FilterConfig(
                value: _selectedYearId,
                hint: 'ឆ្នាំទី',
                items: dummyYears.map((y) => y.yearId).toList(),
                labelBuilder: (id) =>
                    dummyYears.firstWhere((y) => y.yearId == id).yearName,
                onChanged: (value) => setState(() => _selectedYearId = value),
              ),

              // SHIFT
              FilterConfig(
                value: _selectedShiftId,
                hint: 'វេន',
                items: dummyShifts.map((s) => s.shiftId).toList(),
                labelBuilder: (id) =>
                    dummyShifts.firstWhere((s) => s.shiftId == id).shiftName,
                onChanged: (value) => setState(() => _selectedShiftId = value),
              ),
            ],
          ),
          // 🔹 List
          Expanded(
            child: filteredAttendance.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.people_outline,
                    title: 'រកមិនឃើញសិស្ស',
                    subtitle: 'សូមកែប្រែការតម្រង',
                  )
                : ListView.builder(
                    itemCount: filteredAttendance.length,
                    padding: const EdgeInsets.only(bottom: 16),
                    itemBuilder: (context, index) {
                      final attendance = filteredAttendance[index];

                      return ListItemWidget<AttendanceModel>(
                        item: attendance,
                        title: attendance.studentName,
                        subtitle: attendance.shiftName,
                        avatarText: attendance.avatarLetter,
                        avatarBackgroundColor: Colors.purple[50],
                        avatarTextColor: Colors.purple,
                      );
                    },
                  ),
          ),
          AppButton(
            label: 'ទទួលបញ្ជី',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddAttendanceScreen(),
              ),
            ),
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}
