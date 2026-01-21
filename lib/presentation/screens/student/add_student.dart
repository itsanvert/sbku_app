// presentation/screens/add_student_screen.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sbku_app/controller/student_form_controller.dart';
import 'package:sbku_app/data/dummy_year.dart';
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
        Navigator.pop(context, true);
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
    );

    final index = dummyStudents.indexWhere((s) => s.id == updated.id);
    if (index != -1) {
      dummyStudents[index] = updated;
    }
  }

  void _addNewStudent() {
    final newStudent = _formController.toStudentModel(
      existingId: null,
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

  Future<void> _handleImageUpload() async {
    await _formController.showImageSourceDialog(context);
    setState(() {});
  }

  // Build profile image widget - handles both web and mobile
  Widget _buildProfileImage() {
    ImageProvider? imageProvider;

    if (_formController.hasImage) {
      if (kIsWeb) {
        imageProvider = MemoryImage(_formController.profileImageBytes!);
      } else {
        imageProvider = FileImage(_formController.profileImage!);
      }
    }

    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.orange.shade100,
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? Icon(
              Icons.person,
              size: 60,
              color: Colors.orange.shade300,
            )
          : null,
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
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _isLoading ? null : _handleImageUpload,
                  child: Stack(
                    children: [
                      _buildProfileImage(),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to ${_formController.hasImage ? 'change' : 'add'} photo',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'អត្តលេខនិស្សិត',
                  controller: _formController.idController,
                  enabled: !_isEditing,
                  validator: (value) =>
                      _formController.validateRequired(value, 'Student ID'),
                ),
                CustomTextField(
                  label: 'ឈ្មោះនិស្សិត',
                  controller: _formController.nameController,
                  enabled: !_isEditing,
                  validator: (value) =>
                      _formController.validateRequired(value, 'Student Name'),
                ),
                CustomDropdown<String>(
                  label: 'ភេទ',
                  value: _formController.selectedGender,
                  items: const ['Male', 'Female'],
                  onChanged: (value) {
                    setState(() {
                      _formController.selectedGender = value!;
                    });
                  },
                ),
                GestureDetector(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );

                    if (pickedDate != null) {
                      setState(() {
                        _formController.dobController.text =
                            "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: CustomTextField(
                      controller: _formController.dobController,
                      label: 'ថ្ងៃខែឆ្នាំកំណើត',
                      suffixIcon: Icons.calendar_today,
                      validator: (value) => _formController.validateRequired(
                          value, 'Date of Birth'),
                    ),
                  ),
                ),
                CustomTextField(
                  label: 'ជំនាញ',
                  controller: _formController.majorController,
                  validator: (value) =>
                      _formController.validateRequired(value, 'Major'),
                ),
                CustomTextField(
                  label: 'មហាវិទ្យាល័យ',
                  controller: _formController.facultyController,
                  validator: (value) =>
                      _formController.validateRequired(value, 'Faculty'),
                ),
                CustomDropdown(
                  label: 'ឆ្នាំសិក្សា',
                  value: _formController.selectedYearId,
                  items: dummyYears.map((y) => y.yearId).toList(),
                  onChanged: (value) {
                    setState(() {
                      _formController.selectedYearId = value!;
                    });
                  },
                ),
                CustomDropdown<String>(
                  label: 'វេនសិក្សា',
                  value: _formController.selectedShift,
                  items: const ['Morning', 'Evening', 'Afternoon', 'Weekend'],
                  onChanged: (value) {
                    setState(() {
                      _formController.selectedShift = value!;
                    });
                  },
                ),
                CustomTextField(
                  label: 'អ៊ីមែល',
                  controller: _formController.emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _formController.validateEmail,
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : AppButton(
                        label: _isEditing ? 'Update Student' : 'Add Student',
                        onPressed: _handleSave,
                      ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
