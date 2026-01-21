import 'package:flutter/material.dart';
import 'package:sbku_app/presentation/screens/student/add_student.dart';
import 'package:sbku_app/presentation/screens/student/show_student.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import 'package:sbku_app/presentation/widgets/filter_row_widget.dart';
import 'package:sbku_app/presentation/widgets/list_item_widget.dart';
import '../../../data/dummy_students.dart';

import '../../../model/student_model.dart';

class StudentListViewScreen extends StatefulWidget {
  const StudentListViewScreen({super.key});

  @override
  State<StudentListViewScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListViewScreen> {
  String? _selectedFaculty;
  String? _selectedShift;
  String? _selectedGeneration;

  List<StudentModel> get filteredStudents {
    var result = dummyStudents;

    if (_selectedFaculty != null) {
      result = result.where((s) => s.faculty == _selectedFaculty).toList();
    }

    if (_selectedShift != null) {
      result = result.where((s) => s.shift == _selectedShift).toList();
    }

    if (_selectedGeneration != null) {
      result =
          result.where((s) => s.generation == _selectedGeneration).toList();
    }

    return result;
  }

  void _showDeleteDialog(StudentModel student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('លុបសិស្ស'),
        content: Text('តើអ្នកប្រាកដថាចង់លុប ${student.name} ឬទេ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('បោះបង់'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                dummyStudents.removeWhere((s) => s.id == student.id);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${student.name} ត្រូវបានលុបដោយជោគជ័យ'),
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

  void _navigateToEdit(StudentModel student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddStudentScreen(student: student),
      ),
    );
  }

  void _navigateToAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddStudentScreen(),
      ),
    );
  }

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
          IconButton(
            onPressed: _navigateToAdd,
            icon: const Icon(Icons.add, color: Colors.white),
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
                items: Set<String>.from(dummyStudents.map((s) => s.faculty))
                    .toList(),
                onChanged: (value) => setState(() => _selectedFaculty = value),
              ),
              FilterConfig(
                value: _selectedShift,
                hint: 'វេន',
                items: Set<String>.from(dummyStudents.map((s) => s.shift))
                    .toList(),
                onChanged: (value) => setState(() => _selectedShift = value),
              ),
              FilterConfig(
                value: _selectedGeneration,
                hint: 'ជំនាន់',
                items: Set<String>.from(dummyStudents.map((s) => s.generation))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedGeneration = value),
              ),
            ],
          ),

          // Student List
          Expanded(
            child: filteredStudents.isEmpty
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
                    itemCount: filteredStudents.length,
                    padding: const EdgeInsets.only(bottom: 16),
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      return ListItemWidget<StudentModel>(
                        item: student,
                        title: student.name,
                        subtitle: student.major,
                        avatarImageUrl: student.profileImagePath,
                        avatarBackgroundColor: Colors.deepOrange,
                        avatarTextColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ShowStudentScreen(studentId: student.id),
                            ),
                          );
                        },
                        actions: [
                          ItemAction.text(
                            label: 'កែ',
                            onPressed: () => _navigateToEdit(student),
                            color: Colors.green,
                          ),
                          ItemAction.text(
                            label: 'លុប',
                            onPressed: () => _showDeleteDialog(student),
                            color: Colors.red,
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
