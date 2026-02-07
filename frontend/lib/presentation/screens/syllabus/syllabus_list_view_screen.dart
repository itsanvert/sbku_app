import 'package:flutter/material.dart';
import 'package:sbku_app/data/dummy_class.dart';
import 'package:sbku_app/data/dummy_semester.dart';
import 'package:sbku_app/data/dummy_shirt.dart';
import 'package:sbku_app/data/dummy_staff.dart';
import 'package:sbku_app/data/dummy_subject.dart';
import 'package:sbku_app/data/dummy_syllabus.dart';
import 'package:sbku_app/data/dummy_teacher.dart';

import 'package:sbku_app/data/dummy_year.dart';

import 'package:sbku_app/domain/entities/syllabus_entity.dart';
import 'package:sbku_app/model/syllabus_model.dart';
import 'package:sbku_app/model/class_model.dart';
import 'package:sbku_app/model/teacher_model.dart';
import 'package:sbku_app/model/subject_model.dart';
import 'package:sbku_app/model/shift_model.dart';
import 'package:sbku_app/model/semester_model.dart';
import 'package:sbku_app/model/year_model.dart';

import 'package:sbku_app/presentation/screens/syllabus/add_syllabus.dart';
import 'package:sbku_app/presentation/screens/syllabus/show_syllabus.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import 'package:sbku_app/presentation/widgets/filter_row_widget.dart';
import 'package:sbku_app/presentation/widgets/list_item_widget.dart';

class SyllabusListViewScreen extends StatefulWidget {
  const SyllabusListViewScreen({super.key});

  @override
  State<SyllabusListViewScreen> createState() => _SyllabusListViewScreenState();
}

class _SyllabusListViewScreenState extends State<SyllabusListViewScreen> {
  String? _selectedClass;
  String? _selectedDepartment;

  // 🔹 Lookup maps (built once)
  late final Map<String, ClassModel> _classMap = {
    for (final c in dummyClasses) c.id: c,
  };

  late final Map<String, TeacherModel> _teacherMap = {
    for (final t in dummyTeachers) t.id: t,
  };

  late final Map<String, SubjectModel> _subjectMap = {
    for (final s in dummySubjects) s.id: s,
  };

  late final Map<String, ShiftModel> _shiftMap = {
    for (final s in dummyShifts) s.id: s,
  };

  late final Map<String, SemesterModel> _semesterMap = {
    for (final s in dummySemesters) s.id: s,
  };

  late final Map<String, YearModel> _yearMap = {
    for (final y in dummyYears) y.id: y,
  };

  /// ✅ ENTITY → MODEL (UI mapping with lookups)
  List<SyllabusModel> get _syllabusModels {
    return dummySyllabus.map((SyllabusEntity e) {
      return SyllabusModel(
        id: e.id,
        className: _classMap[e.classId]?.className ?? '',
        teacherName: _teacherMap[e.teacherId]?.fullName ?? '',
        subjectName: _subjectMap[e.subjectId]?.subjectName ?? '',
        shiftName: _shiftMap[e.shiftId]?.shiftName ?? '',
        semesterName: _semesterMap[e.semesterId]?.name ?? '',
        yearName: _yearMap[e.yearId]?.yearName ?? '',
      );
    }).toList();
  }

  List<SyllabusModel> get _filteredSyllabus {
    return _syllabusModels.where((s) {
      if (_selectedClass != null && s.className != _selectedClass) {
        return false;
      }
      return true;
    }).toList();
  }

  void _navigateToAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddSyllabusScreen()),
    ).then((_) => setState(() {}));
  }

  void _navigateToEdit(SyllabusModel syllabus) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddSyllabusScreen(
            syllabus: dummySyllabus.firstWhere((s) => s.id == syllabus.id),
          ),
        )).then((_) => setState(() {}));
  }

  void _showDeleteDialog(SyllabusModel syllabus) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('លុប'),
        content: Text('តើអ្នកប្រាកដថាចង់លុប ${syllabus.subjectName} ឬទេ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('បោះបង់'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                dummySyllabus.removeWhere((e) => e.id == syllabus.id);
              });
              Navigator.pop(ctx);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${syllabus.subjectName} ត្រូវបានលុបដោយជោគជ័យ'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('លុប'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final syllabusList = _filteredSyllabus;
    final hasFilter = _selectedClass != null;

    return Scaffold(
      appBar: AppBarWidget.simple(
        title: 'បញ្ជីមុខវិជ្ជា',
        actions: [
          IconButton(
            onPressed: _navigateToAdd,
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          FilterRowWidget(
            filters: [
              FilterConfig(
                hint: 'ថ្នាក់',
                value: _selectedClass,
                items: _syllabusModels.map((s) => s.className).toSet().toList(),
                onChanged: (value) => setState(() => _selectedClass = value),
              ),
              FilterConfig(
                hint: 'នាយកដ្ឋាន',
                value: _selectedDepartment,
                items: dummyStaffs.map((s) => s.department).toSet().toList(),
                onChanged: (value) =>
                    setState(() => _selectedDepartment = value),
              ),
            ],
          ),
          Expanded(
            child: syllabusList.isEmpty
                ? Center(
                    child: Text(
                      hasFilter
                          ? 'រកមិនឃើញតារាងមុខវិជ្ជា'
                          : 'មិនទាន់មានតារាងមុខវិជ្ជា',
                    ),
                  )
                : ListView.builder(
                    itemCount: syllabusList.length,
                    itemBuilder: (context, index) {
                      final syllabus = syllabusList[index];

                      return ListItemWidget<SyllabusModel>(
                        item: syllabus,
                        title: syllabus.className,
                        subtitle: syllabus.teacherName,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ShowSyllabusScreen(
                                syllabusId: syllabus.id,
                              ),
                            ),
                          );
                        },
                        actions: [
                          ItemAction.text(
                            label: 'កែ',
                            color: Colors.green,
                            onPressed: () => _navigateToEdit(syllabus),
                          ),
                          ItemAction.text(
                            label: 'លុប',
                            color: Colors.red,
                            onPressed: () => _showDeleteDialog(syllabus),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
