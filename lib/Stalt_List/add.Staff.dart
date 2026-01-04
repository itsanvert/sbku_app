import 'package:flutter/material.dart';
import '../../model/staff.dart';
import '../../data/dummy_staffs.dart';

class AddStaffScreen extends StatefulWidget {
  final StaffModel? staff;

  const AddStaffScreen({super.key, this.staff});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  late TextEditingController _nameController;
  late TextEditingController _departmentController;
  late TextEditingController _positionController;
  late TextEditingController _emailController;

  String? _selectedGender;
  String? _selectedShift;

  @override
  void initState() {
    super.initState();

    final s = widget.staff;

    _nameController = TextEditingController(text: s?.name ?? '');
    _departmentController = TextEditingController(text: s?.department ?? '');
    _positionController = TextEditingController(text: s?.position ?? '');
    _emailController = TextEditingController(text: s?.email ?? '');

    _selectedGender = s?.gender ?? 'M';
    _selectedShift = s?.shift ?? 'Morning';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _departmentController.dispose();
    _positionController.dispose();
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
              _buildTextField('Name', _nameController),

              _buildDropdown<String>(
                label: 'Gender',
                value: _selectedGender,
                items: const ['M', 'F'],
                onChanged: (v) => setState(() => _selectedGender = v),
                displayText: (v) => v == 'M' ? 'Male' : 'Female',
              ),

              _buildTextField('Department', _departmentController),
              _buildTextField('Position', _positionController),

              _buildDropdown<String>(
                label: 'Shift',
                value: _selectedShift,
                items: const ['Morning', 'Evening'],
                onChanged: (v) => setState(() => _selectedShift = v),
                displayText: (v) => v,
              ),

              _buildTextField('Email', _emailController),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _saveStaff,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE65100),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
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

  void _saveStaff() {
    if (_nameController.text.trim().isEmpty ||
        _departmentController.text.trim().isEmpty ||
        _positionController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _selectedGender == null ||
        _selectedShift == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (widget.staff != null) {
      final updated = StaffModel(
        id: widget.staff!.id,
        name: _nameController.text.trim(),
        gender: _selectedGender!,
        department: _departmentController.text.trim(),
        position: _positionController.text.trim(),
        shift: _selectedShift!,
        email: _emailController.text.trim(),
      );

      final index =
          dummyStaffs.indexWhere((s) => s.id == widget.staff!.id);
      if (index != -1) dummyStaffs[index] = updated;
    } else {
      dummyStaffs.add(
        StaffModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          gender: _selectedGender!,
          department: _departmentController.text.trim(),
          position: _positionController.text.trim(),
          shift: _selectedShift!,
          email: _emailController.text.trim(),
        ),
      );
    }

    Navigator.pop(context);
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Colors.orange, width: 2),
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

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) displayText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<T>(
            value: value,
            isExpanded: true,
            items: items
                .map(
                  (e) => DropdownMenuItem<T>(
                    value: e,
                    child: Text(displayText(e)),
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
                borderSide:
                    const BorderSide(color: Colors.orange, width: 2),
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
