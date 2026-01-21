// presentation/screens/add_staff_screen.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sbku_app/controller/staff_form_controller.dart';
import 'package:sbku_app/data/dummy_staff.dart';
import 'package:sbku_app/model/staff_model.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import 'package:sbku_app/presentation/widgets/appbutton_widget.dart';
import 'package:sbku_app/presentation/widgets/custom_text_field.dart';

class AddStaffScreen extends StatefulWidget {
  final StaffModel? staff;

  const AddStaffScreen({super.key, this.staff});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  late final StaffFormController _formController;
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _formController = StaffFormController(staff: widget.staff);
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.staff != null;

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Optional: You can add more specific validation if needed
    if (!_formController.validateAllFields()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        _updateStaff();
      } else {
        _addNewStaff();
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

  void _updateStaff() {
    final updated = _formController.toStaffModel();

    final index = dummyStaffs.indexWhere((s) => s.id == updated.id);
    if (index != -1) {
      dummyStaffs[index] = updated;
    }
  }

  void _addNewStaff() {
    final newStaff = _formController.toStaffModel();
    dummyStaffs.add(newStaff);
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditing
              ? 'Staff updated successfully'
              : 'Staff added successfully',
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
    if (mounted) setState(() {});
  }

  // Build profile image widget - supports both mobile & web
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
        title: _isEditing ? 'Edit Staff' : 'Add Staff',
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement share functionality if needed
            },
            icon: const Icon(Icons.share),
          ),
          IconButton(
            onPressed: () {
              // TODO: Implement profile or other action
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

                // Profile Image Section
                GestureDetector(
                  onTap: _isLoading ? null : _handleImageUpload,
                  child: Stack(
                    alignment: Alignment.bottomRight,
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
                            border: Border.all(color: Colors.white, width: 2),
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

                const SizedBox(height: 32),

                // Form Fields
                CustomTextField(
                  label: 'អត្តលេខ (ID)',
                  controller: _formController.idController,
                  enabled: !_isEditing, // usually ID shouldn't change
                  validator: (v) => _formController.validateRequired(v, 'ID'),
                ),

                CustomTextField(
                  label: 'លេខកូដបុគ្គលិក (Staff ID)',
                  controller: _formController.staffIdController,
                  validator: (v) =>
                      _formController.validateRequired(v, 'Staff ID'),
                ),

                CustomTextField(
                  label: 'ឈ្មោះពេញ',
                  controller: _formController.fullNameController,
                  validator: (v) =>
                      _formController.validateRequired(v, 'Full Name'),
                ),

                CustomTextField(
                  label: 'ជំនាញ / ឯកទេស',
                  controller: _formController.specializationController,
                  validator: (v) =>
                      _formController.validateRequired(v, 'Specialization'),
                ),

                CustomTextField(
                  label: 'ទូរស័ព្ទ',
                  controller: _formController.phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      _formController.validateRequired(v, 'Phone'),
                ),

                CustomTextField(
                  label: 'អ៊ីមែល',
                  controller: _formController.emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _formController.validateEmail,
                ),

                CustomTextField(
                  label: 'User ID (បើមាន)',
                  controller: _formController.userIdController,
                  validator: (v) =>
                      _formController.validateRequired(v, 'User ID'),
                ),

                const SizedBox(height: 32),

                // Submit Button
                _isLoading
                    ? const CircularProgressIndicator()
                    : AppButton(
                        label: _isEditing ? 'Update Staff' : 'Add Staff',
                        onPressed: _handleSave,
                      ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
