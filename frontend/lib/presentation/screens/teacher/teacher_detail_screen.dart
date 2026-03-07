import 'package:flutter/material.dart';
import 'package:sbku_app/model/teacher_model.dart';
import 'package:sbku_app/service/teacher_service.dart';


class TeacherListPage extends StatefulWidget {
  const TeacherListPage({super.key});

  @override
  State<TeacherListPage> createState() => _TeacherListPageState();
}

class _TeacherListPageState extends State<TeacherListPage> {
  final TeacherService _service = TeacherService();
  final TextEditingController _searchController = TextEditingController();

  List<Teacher> _teachers = [];
  bool _loading = false;
  String? _error;
  int _page = 1;
  int _lastPage = 1;
  String _search = '';

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
      final result = await _service.getTeachers(
        page: _page,
        search: _search,
      );

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

  Future<void> _deleteTeacher(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Teacher?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _service.deleteTeacher(id);
      _loadTeachers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teachers')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search teachers…',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (val) {
                _search = val;
                _loadTeachers(reset: true);
              },
            ),
          ),

          // Content
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Text(_error!,
                            style: const TextStyle(color: Colors.red)))
                    : _teachers.isEmpty
                        ? const Center(child: Text('No teachers found'))
                        : ListView.separated(
                            itemCount: _teachers.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final t = _teachers[i];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    'https://ui-avatars.com/api/?name=${Uri.encodeComponent(t.name)}&background=6366f1&color=ffffff',
                                  ),
                                ),
                                title: Text(t.name),
                                subtitle: Text(t.email ?? '—'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _deleteTeacher(t.id),
                                ),
                              );
                            },
                          ),
          ),

          // Pagination
          if (!_loading)
            Row(
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
                Text('Page $_page of $_lastPage'),
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {/* open create form */},
        child: const Icon(Icons.add),
      ),
    );
  }
}
