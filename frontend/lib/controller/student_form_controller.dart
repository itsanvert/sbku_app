// controllers/student_form_controller.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sbku_app/model/year_model.dart';
import '../model/student_model.dart';

class StudentFormController {
  // Text controllers
  final TextEditingController idController;
  final TextEditingController nameController;
  final TextEditingController dobController;
  final TextEditingController facultyController;
  final TextEditingController majorController;
  final TextEditingController generationController;
  final TextEditingController emailController;

  // Dropdown / selection values
  String selectedGender;
  String selectedShift;
  String? selectedYearId;

  // Image
  final ImagePicker _picker = ImagePicker();
  File? profileImage;
  Uint8List? profileImageBytes; // For web
  String? profileImagePath;

  StudentFormController({
    StudentModel? student,
  })  : idController = TextEditingController(text: student?.id ?? ''),
        nameController = TextEditingController(text: student?.name ?? ''),
        dobController = TextEditingController(text: student?.dob ?? ''),
        facultyController = TextEditingController(text: student?.faculty ?? ''),
        majorController = TextEditingController(text: student?.major ?? ''),
        generationController =
            TextEditingController(text: student?.generation ?? ''),
        emailController = TextEditingController(text: student?.email ?? ''),
        selectedGender = student?.gender ?? 'Male',
        selectedShift = student?.shift ?? 'Morning',
        selectedYearId = YearModel.nameToId(student?.year),
        profileImagePath = student?.profileImagePath {
    // Load existing image if path exists (mobile only)
    if (!kIsWeb && profileImagePath != null && profileImagePath!.isNotEmpty) {
      try {
        profileImage = File(profileImagePath!);
      } catch (e) {
        debugPrint('Error loading image: $e');
      }
    }
  }

  // ---------------------------
  // Image picker - Gallery
  // ---------------------------
  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        if (kIsWeb) {
          // For web, read as bytes
          profileImageBytes = await image.readAsBytes();
          profileImagePath = image.name;
        } else {
          // For mobile, use file
          profileImage = File(image.path);
          profileImagePath = image.path;
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      rethrow;
    }
  }

  // ---------------------------
  // Image picker - Camera
  // ---------------------------
  Future<void> takeProfilePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        if (kIsWeb) {
          profileImageBytes = await image.readAsBytes();
          profileImagePath = image.name;
        } else {
          profileImage = File(image.path);
          profileImagePath = image.path;
        }
      }
    } catch (e) {
      debugPrint('Error taking photo: $e');
      rethrow;
    }
  }

  // ---------------------------
  // Remove profile image
  // ---------------------------
  void removeProfileImage() {
    profileImage = null;
    profileImageBytes = null;
    profileImagePath = null;
  }

  // ---------------------------
  // Check if image exists
  // ---------------------------
  bool get hasImage =>
      kIsWeb ? profileImageBytes != null : profileImage != null;

  // ---------------------------
  // Show image source selection
  // ---------------------------
  Future<void> showImageSourceDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.orange),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  await pickProfileImage();
                },
              ),
              if (!kIsWeb) // Camera only available on mobile
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.orange),
                  title: const Text('Camera'),
                  onTap: () async {
                    Navigator.pop(context);
                    await takeProfilePhoto();
                  },
                ),
              if (hasImage)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    removeProfileImage();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------
  // Validation
  // ---------------------------
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
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  bool validateAllFields() {
    return idController.text.trim().isNotEmpty &&
        nameController.text.trim().isNotEmpty &&
        dobController.text.trim().isNotEmpty &&
        facultyController.text.trim().isNotEmpty &&
        majorController.text.trim().isNotEmpty &&
        generationController.text.trim().isNotEmpty &&
        selectedYearId != null &&
        emailController.text.trim().isNotEmpty;
  }

  // ---------------------------
  // Controller → Model
  // ---------------------------
  StudentModel toStudentModel({String? existingId}) {
    return StudentModel(
      id: existingId ?? idController.text.trim(),
      name: nameController.text.trim(),
      gender: selectedGender,
      dob: dobController.text.trim(),
      faculty: facultyController.text.trim(),
      major: majorController.text.trim(),
      year: selectedYearId ?? '',
      shift: selectedShift,
      generation: generationController.text.trim(),
      email: emailController.text.trim(),
      profileImagePath: profileImagePath,
    );
  }

  // ---------------------------
  // Clear all fields
  // ---------------------------
  void clearAll() {
    idController.clear();
    nameController.clear();
    dobController.clear();
    facultyController.clear();
    majorController.clear();
    generationController.clear();
    emailController.clear();
    selectedGender = 'Male';
    selectedShift = 'Morning';
    selectedYearId = null;
    removeProfileImage();
  }

  // ---------------------------
  // Dispose
  // ---------------------------
  void dispose() {
    idController.dispose();
    nameController.dispose();
    dobController.dispose();
    facultyController.dispose();
    majorController.dispose();
    generationController.dispose();
    emailController.dispose();
  }
}
