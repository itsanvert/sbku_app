import 'package:flutter/material.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import '../../../model/student_model.dart';
import '../../../data/dummy_students.dart';

class AddStudentScreen extends StatefulWidget {
  final StudentModel? student;

  const AddStudentScreen({super.key, this.student});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  late final TextEditingController _idController;
  late final TextEditingController _facultyController;
  late final TextEditingController _majorController;
  late final TextEditingController _generationController;
  late final TextEditingController _yearController;
  late final TextEditingController _emailController;
  late String _selectedGender;
  late String _selectedShift;

  @override
  void initState() {
    super.initState();
    if (widget.student != null) {
      final s = widget.student!;
      _idController = TextEditingController(text: s.id);
      _facultyController = TextEditingController(text: s.faculty);
      _majorController = TextEditingController(text: s.major);
      _generationController = TextEditingController(text: s.generation);
      _yearController = TextEditingController(text: s.year);
      _emailController = TextEditingController(text: s.email);
      _selectedGender = s.gender;
      _selectedShift = s.shift;
    } else {
      _idController = TextEditingController();
      _facultyController = TextEditingController();
      _majorController = TextEditingController();
      _generationController = TextEditingController();
      _yearController = TextEditingController();
      _emailController = TextEditingController();
      _selectedGender = 'Male';
      _selectedShift = 'Morning';
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _facultyController.dispose();
    _majorController.dispose();
    _generationController.dispose();
    _yearController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.student != null;

    return Scaffold(
      appBar: AppBarWidget(
        title: isEditing ? 'Edit Student' : 'Add Student',
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.person)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(
                'Student ID',
                _idController,
                enabled: !isEditing,
              ),
              _buildTextField('Faculty', _facultyController),
              _buildDropdown(
                'Gender',
                _selectedGender,
                ['Male', 'Female'],
                (v) => setState(() => _selectedGender = v!),
              ),
              _buildTextField('Major', _majorController),
              _buildDropdown(
                'Shift',
                _selectedShift,
                ['Morning', 'Evening'],
                (v) => setState(() => _selectedShift = v!),
              ),
              _buildTextField('Generation', _generationController),
              _buildTextField('Year', _yearController),
              _buildTextField('Email', _emailController),

              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: () {
                  final id = _idController.text.trim();
                  final faculty = _facultyController.text.trim();
                  final major = _majorController.text.trim();
                  final generation = _generationController.text.trim();
                  final year = _yearController.text.trim();
                  final email = _emailController.text.trim();

                  if (id.isEmpty ||
                      faculty.isEmpty ||
                      major.isEmpty ||
                      generation.isEmpty ||
                      year.isEmpty ||
                      email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                    return;
                  }

                  if (isEditing) {
                    final updated = StudentModel(
                      id: widget.student!.id,
                      name: widget.student!.name,
                      gender: _selectedGender,
                      faculty: faculty,
                      major: major,
                      shift: _selectedShift,
                      generation: generation,
                      year: year,
                      email: email,
                    );
                    final index = dummyStudents.indexWhere(
                      (s) => s.id == updated.id,
                    );
                    if (index != -1) dummyStudents[index] = updated;
                  } else {
                    final newStudent = StudentModel(
                      id: id,
                      name: id,
                      gender: _selectedGender,
                      faculty: faculty,
                      major: major,
                      shift: _selectedShift,
                      generation: generation,
                      year: year,
                      email: email,
                    );
                    dummyStudents.add(newStudent);
                  }

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE65100),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isEditing ? 'Update' : 'Save',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            enabled: enabled,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.orange, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: enabled ? Colors.white : Colors.grey[200],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>(
    String label,
    T value,
    List<T> items,
    void Function(T?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<T>(
            value: value,
            items: items
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e.toString()),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.orange, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
