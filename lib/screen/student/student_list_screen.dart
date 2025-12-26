import 'package:flutter/material.dart';
import '../../data/dummy_students.dart';
import 'add_student_screen.dart';
import '../../model/student/student.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
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
      result = result
          .where((s) => s.generation == _selectedGeneration)
          .toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student List / Page'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddStudentScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🎯 FILTERS ROW — FIXED OVERFLOW
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Faculty Filter
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedFaculty,
                      isExpanded: true, // ✅ ADDED THIS
                      hint: Row(
                        mainAxisSize: MainAxisSize.min, // ✅ ADDED THIS
                        children: const [
                          Icon(
                            Icons.filter_alt,
                            color: Colors.orange,
                            size: 18,
                          ),
                          SizedBox(width: 4),
                          Flexible(
                            // ✅ WRAPPED IN FLEXIBLE
                            child: Text(
                              'Faculty',
                              style: TextStyle(color: Colors.orange),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      items: [
                        for (final faculty in Set<String>.from(
                          dummyStudents.map((s) => s.faculty),
                        ))
                          DropdownMenuItem<String>(
                            value: faculty,
                            child: Text(
                              faculty,
                              overflow: TextOverflow.ellipsis, // ✅ ADDED THIS
                            ),
                          ),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedFaculty = value),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Shift Filter
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedShift,
                      isExpanded: true, // ✅ ADDED THIS
                      hint: Row(
                        mainAxisSize: MainAxisSize.min, // ✅ ADDED THIS
                        children: const [
                          Icon(
                            Icons.filter_alt,
                            color: Colors.orange,
                            size: 18,
                          ),
                          SizedBox(width: 4),
                          Flexible(
                            // ✅ WRAPPED IN FLEXIBLE
                            child: Text(
                              'Shift',
                              style: TextStyle(color: Colors.orange),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      items: [
                        for (final shift in Set<String>.from(
                          dummyStudents.map((s) => s.shift),
                        ))
                          DropdownMenuItem<String>(
                            value: shift,
                            child: Text(
                              shift,
                              overflow: TextOverflow.ellipsis, // ✅ ADDED THIS
                            ),
                          ),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedShift = value),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Generation Filter
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedGeneration,
                      isExpanded: true, // ✅ ADDED THIS
                      hint: Row(
                        mainAxisSize: MainAxisSize.min, // ✅ ADDED THIS
                        children: const [
                          Icon(
                            Icons.filter_alt,
                            color: Colors.orange,
                            size: 18,
                          ),
                          SizedBox(width: 4),
                          Flexible(
                            // ✅ WRAPPED IN FLEXIBLE
                            child: Text(
                              'Generation',
                              style: TextStyle(color: Colors.orange),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      items: [
                        for (final generation in Set<String>.from(
                          dummyStudents.map((s) => s.generation),
                        ))
                          DropdownMenuItem<String>(
                            value: generation,
                            child: Text(
                              generation,
                              overflow: TextOverflow.ellipsis, // ✅ ADDED THIS
                            ),
                          ),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedGeneration = value),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),

          //  LIST — MATCH YOUR DESIGN
          Expanded(
            child: ListView.builder(
              itemCount: filteredStudents.length,
              itemBuilder: (context, index) {
                final student = filteredStudents[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      // 🖼️ Avatar Circle
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.purple[50],
                        ),
                        child: Center(
                          child: Text(
                            student.avatarLetter,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Name + Major
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              student.major,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Edit / Delete Buttons — Purple Text
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddStudentScreen(student: student),
                                ),
                              );
                            },
                            child: const Text(
                              'Edit',
                              style: TextStyle(color: Colors.purple),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete?'),
                                  content: const Text(
                                    'Are you sure want to delete this student?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        dummyStudents.removeWhere(
                                          (s) => s.id == student.id,
                                        );
                                        setState(() {}); // Refresh UI
                                        Navigator.pop(ctx);
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.purple),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
