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

  List<Student> _students = [];
  bool _loading = false;
  String? _error;

  // Pagination
  int _page = 1;
  int _lastPage = 1;

  // Filters
  String? _selectedFaculty;
  String? _selectedShift;
  String? _selectedGeneration;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents({bool reset = false}) async {
    if (reset) _page = 1;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _service.getStudents(page: _page);
      setState(() {
        _students = result.data;
        _lastPage = result.lastPage;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
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

  void _showDeleteDialog(Student student) {
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
            onPressed: () async {
              try {
                await _service.deleteStudent(student.id);
                Navigator.pop(ctx);
                _loadStudents(); // Reload list
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${student.name} ត្រូវបានលុបដោយជោគជ័យ'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('លុប'),
          ),
        ],
      ),
    );
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
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error!),
                            ElevatedButton(
                              onPressed: _loadStudents,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filteredStudents.isEmpty
                        ? const Center(child: Text('រកមិនឃើញសិស្ស'))
                        : RefreshIndicator(
                            onRefresh: () => _loadStudents(reset: true),
                            child: ListView.builder(
                              itemCount: filteredStudents.length,
                              padding: const EdgeInsets.only(bottom: 16),
                              itemBuilder: (context, index) {
                                final student = filteredStudents[index];
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
                            ),
                          ),
          ),
          if (!_loading && _lastPage > 1)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _page > 1
                        ? () {
                            _page--;
                            _loadStudents();
                          }
                        : null,
                  ),
                  Text('ទំព័រ $_page នៃ $_lastPage'),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _page < _lastPage
                        ? () {
                            _page++;
                            _loadStudents();
                          }
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
