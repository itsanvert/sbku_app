import 'package:flutter/material.dart';
import 'package:sbku_app/model/student_model.dart';
import 'package:sbku_app/presentation/screens/student/show_student.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import 'package:sbku_app/presentation/widgets/filter_row_widget.dart';
import 'package:sbku_app/presentation/widgets/list_item_widget.dart';
import 'package:sbku_app/service/student_service.dart';

class StudentListViewScreen extends StatefulWidget {
  const StudentListViewScreen({super.key});

  @override
  State<StudentListViewScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListViewScreen> {
  final StudentService _service = StudentService();

  late Stream<List<Student>> _studentStream;

  List<Student> _students = [];

  // Pagination
  int _page = 1;

  // Filters
  String? _selectedFaculty;
  String? _selectedShift;
  String? _selectedGeneration;

  @override
  void initState() {
    super.initState();
    _studentStream = _service.streamStudents();
    _loadStudents();
  }

  Future<void> _loadStudents({bool reset = false}) async {
    if (reset) _page = 1;


    try {
      final paginated = await _service.getStudents(page: _page);
      setState(() {
        _students = paginated.data;
      });
    } catch (e) {
          } finally {
          }
  }

  List<Student> get filteredStudents {
    var result = _students;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget.simple(
        title: 'បញ្ជីសិស្ស',
      ),
      body: Column(
        children: [
          FilterRowWidget(
            filters: [
              FilterConfig(
                value: _selectedFaculty,
                hint: 'មហាវិទ្យាល័យ',
                items: _students
                    .map((s) => s.faculty ?? '')
                    .where((f) => f.isNotEmpty)
                    .toSet()
                    .toList(),
                onChanged: (value) => setState(() => _selectedFaculty = value),
              ),
              FilterConfig(
                value: _selectedShift,
                hint: 'វេន',
                items: _students
                    .map((s) => s.shift ?? '')
                    .where((s) => s.isNotEmpty)
                    .toSet()
                    .toList(),
                onChanged: (value) => setState(() => _selectedShift = value),
              ),
              FilterConfig(
                value: _selectedGeneration,
                hint: 'ជំនាន់',
                items: _students
                    .map((s) => s.generation ?? '')
                    .where((g) => g.isNotEmpty)
                    .toSet()
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedGeneration = value),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<List<Student>>(
              stream: _studentStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text('Error: ${snapshot.error}'),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final students = snapshot.data ?? [];

                // Apply client-side filters
                var filtered = students;
                if (_selectedFaculty != null) {
                  filtered = filtered.where((s) => s.faculty == _selectedFaculty).toList();
                }
                if (_selectedShift != null) {
                  filtered = filtered.where((s) => s.shift == _selectedShift).toList();
                }
                if (_selectedGeneration != null) {
                  filtered = filtered.where((s) => s.generation == _selectedGeneration).toList();
                }

                if (filtered.isEmpty) {
                  return const Center(child: Text('រកមិនឃើញសិស្ស'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  padding: const EdgeInsets.only(bottom: 16),
                  itemBuilder: (context, index) {
                    final student = filtered[index];
                    return ListItemWidget<Student>(
                      item: student,
                      title: student.name,
                      subtitle: student.major ?? '—',
                      avatarImageUrl: student.avatarUrl,
                      avatarBackgroundColor: Colors.deepOrange,
                      avatarTextColor: Colors.white,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShowStudentScreen(
                                studentId: student.id.toString()),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          // Real-time synchronization enabled.
        ],
      ),
    );
  }
}
