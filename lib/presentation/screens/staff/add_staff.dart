import 'package:flutter/material.dart';
import '../../../model/staff_model.dart';
import '../../../data/dummy_staff.dart';

class StaffListViewScreen extends StatefulWidget {
  final StaffModel? staff;

  const StaffListViewScreen({super.key, this.staff});

  @override
  State<StaffListViewScreen> createState() => _StaffListViewScreenState();
}

class _StaffListViewScreenState extends State<StaffListViewScreen> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _staffIdController;
  late final TextEditingController _specController;
  late final TextEditingController _phoneController;
  late final TextEditingController _userIdController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();

    if (widget.staff != null) {
      final s = widget.staff!;
      _fullNameController = TextEditingController(text: s.fullName);
      _staffIdController = TextEditingController(text: s.staffid);
      _specController = TextEditingController(text: s.specalization);
      _phoneController = TextEditingController(text: s.phone);
      _userIdController = TextEditingController(text: s.userid);
      _emailController = TextEditingController(text: s.email);
    } else {
      _fullNameController = TextEditingController();
      _staffIdController = TextEditingController();
      _specController = TextEditingController();
      _phoneController = TextEditingController();
      _userIdController = TextEditingController();
      _emailController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _staffIdController.dispose();
    _specController.dispose();
    _phoneController.dispose();
    _userIdController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.staff != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(isEditing ? 'Edit Staff' : 'Add Staff'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField('Staff ID', _staffIdController),
              _buildTextField('Full Name', _fullNameController),
              _buildTextField('Specialization', _specController),
              _buildTextField('Phone', _phoneController),
              _buildTextField('User ID', _userIdController),
              _buildTextField('Email', _emailController),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_fullNameController.text.isEmpty ||
                      _staffIdController.text.isEmpty ||
                      _specController.text.isEmpty ||
                      _phoneController.text.isEmpty ||
                      _userIdController.text.isEmpty ||
                      _emailController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                    return;
                  }

                  if (isEditing) {
                    final updated = StaffModel(
                      id: widget.staff!.id,
                      staffid: _staffIdController.text.trim(),
                      fullName: _fullNameController.text.trim(),
                      specalization: _specController.text.trim(),
                      phone: _phoneController.text.trim(),
                      userid: _userIdController.text.trim(),
                      email: _emailController.text.trim(),
                    );

                    final index =
                        dummyStaffList.indexWhere((s) => s.id == updated.id);
                    if (index != -1) dummyStaffList[index] = updated;
                  } else {
                    dummyStaffList.add(
                      StaffModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        staffid: _staffIdController.text.trim(),
                        fullName: _fullNameController.text.trim(),
                        specalization: _specController.text.trim(),
                        phone: _phoneController.text.trim(),
                        userid: _userIdController.text.trim(),
                        email: _emailController.text.trim(),
                      ),
                    );
                  }

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE65100),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
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

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
