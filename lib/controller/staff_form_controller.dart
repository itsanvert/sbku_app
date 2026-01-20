import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../model/staff_model.dart';

class StaffFormController {
  // ---------------------------
  // Text controllers
  // ---------------------------
  final TextEditingController idController;
  final TextEditingController staffIdController;
  final TextEditingController fullNameController;
  final TextEditingController specializationController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController userIdController;

  // ---------------------------
  // Image
  // ---------------------------
  final ImagePicker _picker = ImagePicker();
  File? profileImage;
  Uint8List? profileImageBytes; // Web
  String? profileImagePath;

  StaffFormController({StaffModel? staff})
      : idController = TextEditingController(text: staff?.id ?? ''),
        staffIdController = TextEditingController(text: staff?.staffid ?? ''),
        fullNameController = TextEditingController(text: staff?.fullName ?? ''),
        specializationController =
            TextEditingController(text: staff?.specalization ?? ''),
        phoneController = TextEditingController(text: staff?.phone ?? ''),
        emailController = TextEditingController(text: staff?.email ?? ''),
        userIdController = TextEditingController(text: staff?.userid ?? ''),
        profileImagePath = null {
    // Load existing image (mobile only)
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
          profileImageBytes = await image.readAsBytes();
          profileImagePath = image.name;
        } else {
          profileImage = File(image.path);
          profileImagePath = image.path;
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
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
    }
  }

  // ---------------------------
  // Remove image
  // ---------------------------
  void removeProfileImage() {
    profileImage = null;
    profileImageBytes = null;
    profileImagePath = null;
  }

  bool get hasImage =>
      kIsWeb ? profileImageBytes != null : profileImage != null;

  // ---------------------------
  // Image source dialog
  // ---------------------------
  Future<void> showImageSourceDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
            if (!kIsWeb)
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
      ),
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
      return 'Invalid email address';
    }
    return null;
  }

  bool validateAllFields() {
    return idController.text.trim().isNotEmpty &&
        staffIdController.text.trim().isNotEmpty &&
        fullNameController.text.trim().isNotEmpty &&
        specializationController.text.trim().isNotEmpty &&
        phoneController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        userIdController.text.trim().isNotEmpty;
  }

  // ---------------------------
  // Controller → Model
  // ---------------------------
  StaffModel toStaffModel() {
    return StaffModel(
      id: idController.text.trim(),
      staffid: staffIdController.text.trim(),
      fullName: fullNameController.text.trim(),
      specalization: specializationController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim(),
      userid: userIdController.text.trim(),
    );
  }

  // ---------------------------
  // Clear all fields
  // ---------------------------
  void clearAll() {
    idController.clear();
    staffIdController.clear();
    fullNameController.clear();
    specializationController.clear();
    phoneController.clear();
    emailController.clear();
    userIdController.clear();
    removeProfileImage();
  }

  // ---------------------------
  // Dispose
  // ---------------------------
  void dispose() {
    idController.dispose();
    staffIdController.dispose();
    fullNameController.dispose();
    specializationController.dispose();
    phoneController.dispose();
    emailController.dispose();
    userIdController.dispose();
  }
}
