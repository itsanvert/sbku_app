import 'package:flutter/material.dart';
import 'package:sbku_app/model/teacher_model.dart';
import 'package:sbku_app/presentation/screens/teacher/show_teacher.dart';
import 'package:sbku_app/service/teacher_service.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import 'package:sbku_app/presentation/widgets/filter_row_widget.dart';
import 'package:sbku_app/presentation/widgets/list_item_widget.dart';

class TeacherListViewScreen extends StatefulWidget {
  const TeacherListViewScreen({super.key});

  @override
  State<TeacherListViewScreen> createState() => _TeacherListScreenState();
}

class _TeacherListScreenState extends State<TeacherListViewScreen> {
  final TeacherService _service = TeacherService();

  List<Teacher> _teachers = [];
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
    _loadTeachers();
  }

  Future<void> _loadTeachers({bool reset = false}) async {
    if (reset) _page = 1;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _service.getTeachers(page: _page);
      setState(() {
        _teachers = result.data;
        _lastPage = result.lastPage;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  // ── Client-side filtering (same logic as before) ──────────────────
  List<Teacher> get filteredTeachers {
    var result = _teachers;

    if (_selectedFaculty != null) {
      result = result.where((t) => t.faculty == _selectedFaculty).toList();
    }
    if (_selectedShift != null) {
      result =
          result.where((t) => t.year?.toString() == _selectedShift).toList();
    }
    if (_selectedGeneration != null) {
      result = result.where((t) => t.schedule == _selectedGeneration).toList();
    }

    return result;
  }

  // ── Filter options derived from loaded data ───────────────────────
  List<String> get _faculties => _teachers
      .map((t) => t.faculty ?? '')
      .where((f) => f.isNotEmpty)
      .toSet()
      .toList();

  List<String> get _shifts => _teachers
      .map((t) => t.year?.toString() ?? '')
      .where((s) => s.isNotEmpty)
      .toSet()
      .toList();

  List<String> get _generations => _teachers
      .map((t) => t.schedule ?? '')
      .where((s) => s.isNotEmpty)
      .toSet()
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget.simple(
        title: 'បញ្ជីគ្រូ',
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filters (same as before) ───────────────────────────────
          FilterRowWidget(
            filters: [
              FilterConfig(
                value: _selectedFaculty,
                hint: 'មហាវិទ្យាល័យ',
                items: _faculties,
                onChanged: (value) => setState(() => _selectedFaculty = value),
              ),
              FilterConfig(
                value: _selectedShift,
                hint: 'វេន',
                items: _shifts,
                onChanged: (value) => setState(() => _selectedShift = value),
              ),
              FilterConfig(
                value: _selectedGeneration,
                hint: 'ជំនាន់',
                items: _generations,
                onChanged: (value) =>
                    setState(() => _selectedGeneration = value),
              ),
            ],
          ),

          // ── Content ────────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 60, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _loadTeachers,
                              icon: const Icon(Icons.refresh),
                              label: const Text('ព្យាយាមម្តងទៀត'),
                            ),
                          ],
                        ),
                      )
                    : filteredTeachers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline,
                                    size: 80, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text(
                                  'រកមិនឃើញគ្រូ',
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
                                      fontSize: 14, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => _loadTeachers(reset: true),
                            child: ListView.builder(
                              itemCount: filteredTeachers.length,
                              padding: const EdgeInsets.only(bottom: 16),
                              itemBuilder: (context, index) {
                                final teacher = filteredTeachers[index];
                                return ListItemWidget<Teacher>(
                                  item: teacher,
                                  title: teacher.name,
                                  subtitle: teacher.faculty ?? '—',
                                  avatarImageUrl: teacher.avatarUrl,
                                  avatarBackgroundColor: Colors.deepOrange,
                                  avatarTextColor:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ShowTeacherScreen(
                                        teacherId: teacher.id,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),

          // ── Pagination ─────────────────────────────────────────────
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
                            _loadTeachers();
                          }
                        : null,
                  ),
                  Text(
                    'ទំព័រ $_page នៃ $_lastPage',
                    style: const TextStyle(fontSize: 13),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _page < _lastPage
                        ? () {
                            _page++;
                            _loadTeachers();
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
