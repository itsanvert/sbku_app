// controllers/student_form_controller.dart
import 'package:flutter/material.dart';
import '../model/student_model.dart';

class StudentFormController {
  final TextEditingController idController;
  final TextEditingController nameController;
  final TextEditingController dobController;
  final TextEditingController facultyController;
  final TextEditingController majorController;
  final TextEditingController generationController;
  final TextEditingController yearController;
  final TextEditingController emailController;

  String selectedGender;
  String selectedShift;

  StudentFormController({
    StudentModel? student,
  })  : idController = TextEditingController(text: student?.id ?? ''),
        nameController = TextEditingController(text: student?.name ?? ''),
        dobController = TextEditingController(text: student?.dob ?? ''),
        facultyController = TextEditingController(text: student?.faculty ?? ''),
        majorController = TextEditingController(text: student?.major ?? ''),
        generationController =
            TextEditingController(text: student?.generation ?? ''),
        yearController = TextEditingController(text: student?.year ?? ''),
        emailController = TextEditingController(text: student?.email ?? ''),
        selectedGender = student?.gender ?? 'Male',
        selectedShift = student?.shift ?? 'Morning';

  // Validation methods
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Check if all fields are filled
  bool validateAllFields() {
    return idController.text.trim().isNotEmpty &&
        facultyController.text.trim().isNotEmpty &&
        majorController.text.trim().isNotEmpty &&
        generationController.text.trim().isNotEmpty &&
        yearController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty;
  }

  // Create StudentModel from current form data
  StudentModel toStudentModel({
    required String? existingId,
    required String? existingName,
    required String? existingDob,
  }) {
    return StudentModel(
      id: existingId ?? idController.text.trim(),
      name: existingName ?? idController.text.trim(),
      gender: selectedGender,
      dob: existingDob ?? '', // You may want to add a DOB field
      faculty: facultyController.text.trim(),
      major: majorController.text.trim(),
      shift: selectedShift,
      generation: generationController.text.trim(),
      year: yearController.text.trim(),
      email: emailController.text.trim(),
    );
  }

  // Dispose all controllers
  void dispose() {
    idController.dispose();
    facultyController.dispose();
    majorController.dispose();
    generationController.dispose();
    yearController.dispose();
    emailController.dispose();
  }
}
