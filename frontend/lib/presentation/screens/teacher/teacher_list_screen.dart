import 'package:flutter/material.dart';
import 'package:sbku_app/data/dummy_teacher.dart';
import 'package:sbku_app/model/teacher_model.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import 'package:sbku_app/presentation/widgets/filter_row_widget.dart';
import 'package:sbku_app/presentation/widgets/list_item_widget.dart';
import '../../../model/student_model.dart';

class TeacherListViewScreen extends StatefulWidget {
  const TeacherListViewScreen({super.key});

  @override
  State<TeacherListViewScreen> createState() => _TeacherListScreenState();
}

class _TeacherListScreenState extends State<TeacherListViewScreen> {
  String? _selectedFaculty;
  String? _selectedShift;
  String? _selectedGeneration;

  List<TeacherModel> get filteredTeachers {
    var result = dummyTeachers;

    if (_selectedFaculty != null) {
      result =
          result.where((s) => s.specialization == _selectedFaculty).toList();
    }

    if (_selectedShift != null) {
      result = result.where((s) => s.year == _selectedShift).toList();
    }

    if (_selectedGeneration != null) {
      result = result.where((s) => s.schedule == _selectedGeneration).toList();
    }

    return result;
  }

  void _showDeleteDialog(StudentModel teacher) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('លុបសិស្ស'),
        content: Text('តើអ្នកប្រាកដថាចង់លុប ${teacher.name} ឬទេ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('បោះបង់'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                dummyTeachers.removeWhere((s) => s.id == teacher.id);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${teacher.name} ត្រូវបានលុបដោយជោគជ័យ'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('លុប'),
          ),
        ],
      ),
    );
  }

  // void _navigateToEdit(StudentModel teacher) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => AddStudentScreen(teacher: teacher),
  //     ),
  //   );
  // }

  // void _navigateToAdd() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => const AddStudentScreen(),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget.simple(
        title: 'បញ្ជីសិស្ស',
        actions: [
          IconButton(
            onPressed: () {
              // Share functionality
            },
            icon: const Icon(Icons.share, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters Row
          FilterRowWidget(
            filters: [
              FilterConfig(
                value: _selectedFaculty,
                hint: 'មហាវិទ្យាល័យ',
                items:
                    Set<String>.from(dummyTeachers.map((s) => s.specialization))
                        .toList(),
                onChanged: (value) => setState(() => _selectedFaculty = value),
              ),
              FilterConfig(
                value: _selectedShift,
                hint: 'វេន',
                items:
                    Set<String>.from(dummyTeachers.map((s) => s.year)).toList(),
                onChanged: (value) => setState(() => _selectedShift = value),
              ),
              FilterConfig(
                value: _selectedGeneration,
                hint: 'ជំនាន់',
                items: Set<String>.from(dummyTeachers.map((s) => s.schedule))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedGeneration = value),
              ),
            ],
          ),

          // Student List
          Expanded(
            child: filteredTeachers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'រកមិនឃើញសិស្ស',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'សូមកែប្រែការតម្រង',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTeachers.length,
                    padding: const EdgeInsets.only(bottom: 16),
                    itemBuilder: (context, index) {
                      final teacher = filteredTeachers[index];
                      return ListItemWidget<TeacherModel>(
                        item: teacher,
                        title: teacher.fullName,
                        subtitle: teacher.specialization,
                        avatarImageUrl: teacher.imagePath,
                        avatarBackgroundColor: Colors.deepOrange,
                        avatarTextColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) =>
                          //         ShowStudentScreen(studentId: teacher.id),
                          //   ),
                          // );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
