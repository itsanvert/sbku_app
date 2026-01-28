import 'package:flutter/material.dart';
import 'package:sbku_app/data/dummy_class.dart';
import 'package:sbku_app/data/dummy_semester.dart';
import 'package:sbku_app/data/dummy_shirt.dart';
import 'package:sbku_app/data/dummy_subject.dart';
import 'package:sbku_app/data/dummy_syllabus.dart';
import 'package:sbku_app/data/dummy_teacher.dart';
import 'package:sbku_app/data/dummy_year.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';

class ShowSyllabusScreen extends StatelessWidget {
  final String syllabusId;

  const ShowSyllabusScreen({super.key, required this.syllabusId});

  @override
  Widget build(BuildContext context) {
    final syllabus = dummySyllabus.firstWhere((s) => s.id == syllabusId);

    // 🔹 Lookups
    final className = dummyClasses
        .firstWhere(
          (c) => c.classId == syllabus.classId,
          orElse: () => dummyClasses.first,
        )
        .className;

    final teacherName = dummyTeachers
        .firstWhere(
          (t) => t.id == syllabus.teacherId,
          orElse: () => dummyTeachers.first,
        )
        .fullName;

    final subjectName = dummySubjects
        .firstWhere(
          (s) => s.id == syllabus.subjectId,
          orElse: () => dummySubjects.first,
        )
        .subjectName;

    final shiftName = dummyShifts
        .firstWhere(
          (s) => s.shiftId == syllabus.shiftId,
          orElse: () => dummyShifts.first,
        )
        .shiftName;

    final semesterName = dummySemesters
        .firstWhere(
          (s) => s.id == syllabus.semesterId,
          orElse: () => dummySemesters.first,
        )
        .name;

    final yearName = dummyYears
        .firstWhere(
          (y) => y.yearId == syllabus.yearId,
          orElse: () => dummyYears.first,
        )
        .yearName;

    return Scaffold(
      appBar: AppBarWidget(
        title: "ព័ត៌មានមុខវិជ្ជា",
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.person)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey,
              child: Icon(Icons.menu_book),
            ),
            const SizedBox(height: 24),
            _row('Class', className),
            _row('Teacher', teacherName),
            _row('Subject', subjectName),
            _row('Shift', shiftName),
            _row('Semester', semesterName),
            _row('Year', yearName),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }
}
