import 'package:flutter/material.dart';
import 'package:sbku_app/model/syllabus_model.dart';
import 'package:sbku_app/presentation/screens/syllabus/show_syllabus.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import 'package:sbku_app/presentation/widgets/filter_row_widget.dart';
import 'package:sbku_app/service/syllabus_service.dart';

class SyllabusListViewScreen extends StatefulWidget {
  const SyllabusListViewScreen({super.key});

  @override
  State<SyllabusListViewScreen> createState() => _SyllabusListViewScreenState();
}

class _SyllabusListViewScreenState extends State<SyllabusListViewScreen> {
  final SyllabusService _service = SyllabusService();
  
  List<SyllabusModel> _allModels = [];
  bool _isLoading = true;
  String? _error;

  String? _selectedFaculty;
  String? _selectedMajor;
  String? _selectedShift;

  @override
  void initState() {
    super.initState();
    _fetchSyllabus();
  }

  Future<void> _fetchSyllabus() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final models = await _service.getSyllabus();
      setState(() {
        _allModels = models;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// ✅ Grouping logic for Year -> Semester -> Subjects
  Map<String, Map<String, List<SyllabusModel>>> get _groupedSyllabus {
    final filtered = _allModels.where((s) {
      if (_selectedFaculty != null && s.facultyName != _selectedFaculty) {
        return false;
      }
      if (_selectedMajor != null && s.majorName != _selectedMajor) {
        return false;
      }
      if (_selectedShift != null && s.shiftName != _selectedShift) {
        return false;
      }
      return true;
    }).toList();

    // {YearName: {SemesterName: [SyllabusModel]}}
    final result = <String, Map<String, List<SyllabusModel>>>{};

    for (final s in filtered) {
      result.putIfAbsent(s.yearName, () => {});
      result[s.yearName]!.putIfAbsent(s.semesterName, () => []);
      result[s.yearName]![s.semesterName]!.add(s);
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F9FC),
      appBar: AppBarWidget.simple(
        title: 'កម្មវិធីសិក្សា (Syllabus)',
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : _error != null 
          ? _buildErrorState()
          : Column(
              children: [
                _buildFilters(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchSyllabus,
                    child: _allModels.isEmpty && _error == null
                        ? _buildEmptyState()
                        : _buildCurriculumList(_groupedSyllabus),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilters() {
    return FilterRowWidget(
      filters: [
        FilterConfig(
          hint: 'មហាវិទ្យាល័យ',
          value: _selectedFaculty,
          items: _allModels.map((m) => m.facultyName).toSet().toList(),
          onChanged: (val) => setState(() => _selectedFaculty = val),
        ),
        FilterConfig(
          hint: 'ជំនាញ',
          value: _selectedMajor,
          items: _allModels.map((m) => m.majorName).toSet().toList(),
          onChanged: (val) => setState(() => _selectedMajor = val),
        ),
        FilterConfig(
          hint: 'វេនសិក្សា',
          value: _selectedShift,
          items: _allModels.map((m) => m.shiftName).toSet().toList(),
          onChanged: (val) => setState(() => _selectedShift = val),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(_error ?? 'An unexpected error occurred'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchSyllabus, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildCurriculumList(Map<String, Map<String, List<SyllabusModel>>> grouped) {
    // Collect years in order
    final yearKeys = grouped.keys.toList()..sort();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: yearKeys.length,
      itemBuilder: (context, index) {
        final yearName = yearKeys[index];
        final semesters = grouped[yearName]!;
        final semesterKeys = semesters.keys.toList()..sort();

        return Card(
          elevation: isDark ? 0 : 2,
          margin: const EdgeInsets.only(bottom: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Year Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFF1E3A8A), // Indigo or Slate
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  yearName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              // Semesters
              ...semesterKeys.map((semName) {
                final subjects = semesters[semName]!;
                return _buildSemesterSection(semName, subjects);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSemesterSection(String name, List<SyllabusModel> subjects) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Icon(Icons.school_outlined, size: 18, color: isDark ? Colors.blue.shade300 : Colors.blueGrey),
              const SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.blue.shade300 : Colors.blueGrey,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, endIndent: 16, indent: 16, color: isDark ? Colors.white10 : Colors.black12),
        ...subjects.map((s) => _buildSubjectTile(s)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSubjectTile(SyllabusModel s) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.blue.withOpacity(0.12) : Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.withOpacity(0.1)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShowSyllabusScreen(syllabus: s),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      s.subjectName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.blue.withOpacity(0.2) : Colors.indigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${s.creditHours} Credits',
                      style: TextStyle(
                        fontSize: 10, 
                        color: isDark ? Colors.blue.shade200 : Colors.indigo, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 14, color: isDark ? Colors.grey.shade400 : Colors.grey),
                  const SizedBox(width: 4),
                  Text(s.teacherName, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey)),
                  const Spacer(),
                  Icon(Icons.schedule, size: 14, color: isDark ? Colors.grey.shade400 : Colors.grey),
                  const SizedBox(width: 4),
                  Text(s.scheduleInfo, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books_outlined, size: 64, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            'មិនមានកម្មវិធីសិក្សាក្នុងជម្រើសនេះទេ',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'សូមជ្រើសរើសមហាវិទ្យាល័យ និងជំនាញឱ្យបានត្រឹមត្រូវ',
            style: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
