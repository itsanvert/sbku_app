// presentation/screens/add_student_screen.dart
import 'package:flutter/material.dart';
import 'package:sbku_app/controller/student_form_controller.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import 'package:sbku_app/presentation/widgets/appbutton_widget.dart';
import 'package:sbku_app/presentation/widgets/custom_text_field.dart';

import 'package:sbku_app/presentation/widgets/custome_dropdown.dart';

import '../../../model/student_model.dart';
import '../../../data/dummy_students.dart';

class AddStudentScreen extends StatefulWidget {
  final StudentModel? student;

  const AddStudentScreen({super.key, this.student});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  late final StudentFormController _formController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _formController = StudentFormController(student: widget.student);
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.student != null;

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        _updateStudent();
      } else {
        _addNewStudent();
      }

      if (mounted) {
        _showSuccessMessage();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _updateStudent() {
    final updated = _formController.toStudentModel(
      existingId: widget.student!.id,
      existingName: widget.student!.name,
      existingDob: widget.student!.dob,
    );

    final index = dummyStudents.indexWhere((s) => s.id == updated.id);
    if (index != -1) {
      dummyStudents[index] = updated;
    }
  }

  void _addNewStudent() {
    final newStudent = _formController.toStudentModel(
      existingId: null,
      existingName: null,
      existingDob: '', // Consider adding a date picker for DOB
    );
    dummyStudents.add(newStudent);
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditing
              ? 'Student updated successfully'
              : 'Student added successfully',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: _isEditing ? 'Edit Student' : 'Add Student',
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement share functionality
            },
            icon: const Icon(Icons.share),
          ),
          IconButton(
            onPressed: () {
              // TODO: Implement profile functionality
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextField(
                  label: 'Student ID',
                  controller: _formController.idController,
                  enabled: !_isEditing,
                  validator: (value) =>
                      _formController.validateRequired(value, 'Student ID'),
                ),
                CustomTextField(
                  label: 'Faculty',
                  controller: _formController.facultyController,
                  validator: (value) =>
                      _formController.validateRequired(value, 'Faculty'),
                ),
                CustomDropdown<String>(
                  label: 'Gender',
                  value: _formController.selectedGender,
                  items: const ['Male', 'Female'],
                  onChanged: (value) {
                    setState(() {
                      _formController.selectedGender = value!;
                    });
                  },
                ),
                CustomTextField(
                  label: 'Major',
                  controller: _formController.majorController,
                  validator: (value) =>
                      _formController.validateRequired(value, 'Major'),
                ),
                CustomDropdown<String>(
                  label: 'Shift',
                  value: _formController.selectedShift,
                  items: const ['Morning', 'Evening'],
                  onChanged: (value) {
                    setState(() {
                      _formController.selectedShift = value!;
                    });
                  },
                ),
                CustomTextField(
                  label: 'Generation',
                  controller: _formController.generationController,
                  validator: (value) =>
                      _formController.validateRequired(value, 'Generation'),
                ),
                CustomTextField(
                  label: 'Year',
                  controller: _formController.yearController,
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      _formController.validateRequired(value, 'Year'),
                ),
                CustomTextField(
                  label: 'Email',
                  controller: _formController.emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _formController.validateEmail,
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: _isEditing ? 'Update Student' : 'Add Student',
                  onPressed: _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
