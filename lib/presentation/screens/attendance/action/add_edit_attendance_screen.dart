import 'package:flutter/material.dart';
import 'package:sbku_app/data/dummy_attendance.dart';
import 'package:sbku_app/data/dummy_faculty.dart';
import 'package:sbku_app/data/dummy_major.dart';

import 'package:sbku_app/data/dummy_shirt.dart';
import 'package:sbku_app/data/dummy_year.dart';
import 'package:sbku_app/data/dummy_class.dart';
import 'package:sbku_app/domain/entities/attendance_entity.dart';
import 'package:sbku_app/model/attendance_model.dart';

class AddAttendanceScreen extends StatefulWidget {
  final AttendanceModel? attendance;

  const AddAttendanceScreen({super.key, this.attendance});

  @override
  State<AddAttendanceScreen> createState() => _AddAttendanceScreenState();
}

class _AddAttendanceScreenState extends State<AddAttendanceScreen> {
  late final TextEditingController _studentNameController;

  String _facultyId = 'F01';
  String _majorId = 'M01';
  String _classId = 'C01';
  String _yearId = 'Y1';
  String _shiftId = 'SH1';
  bool _isPresent = true;

  @override
  void initState() {
    super.initState();

    _studentNameController = TextEditingController(
      text: widget.attendance?.studentName ?? '',
    );

    if (widget.attendance != null) {
      final e = widget.attendance!.entity;
      _facultyId = e.facultyId;
      _majorId = e.majorId;
      _classId = e.classId;
      _yearId = e.yearId;
      _shiftId = e.shiftId;
      _isPresent = e.isPresent;
    }
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    super.dispose();
  }

  void _saveAttendance() {
    final name = _studentNameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter student name')),
      );
      return;
    }

    final entity = AttendanceEntity(
      id: widget.attendance?.entity.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      studentId: widget.attendance?.entity.studentId ?? '',
      studentName: name,
      facultyId: _facultyId,
      majorId: _majorId,
      shiftId: _shiftId,
      classId: _classId,
      yearId: _yearId,
      date: DateTime.now(),
      isPresent: _isPresent,
    );

    if (widget.attendance != null) {
      final index =
          dummyAttendanceEntities.indexWhere((e) => e.id == entity.id);
      if (index != -1) {
        dummyAttendanceEntities[index] = entity;
      }
    } else {
      dummyAttendanceEntities.add(entity);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.attendance != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Attendance' : 'Add Attendance'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _textField('Student Name', _studentNameController),
              _dropdown(
                label: 'Faculty',
                value: _facultyId,
                items: dummyFaculties
                    .map((f) => DropdownMenuItem(
                        value: f.id, child: Text(f.facultyName)))
                    .toList(),
                onChanged: (v) => setState(() => _facultyId = v!),
              ),
              _dropdown(
                label: 'Major',
                value: _majorId,
                items: dummyMajors
                    .map((m) => DropdownMenuItem(
                        value: m.majorId, child: Text(m.majorName)))
                    .toList(),
                onChanged: (v) => setState(() => _majorId = v!),
              ),
              _dropdown(
                label: 'Class',
                value: _classId,
                items: dummyClasses
                    .map((c) => DropdownMenuItem(
                        value: c.classId, child: Text(c.className)))
                    .toList(),
                onChanged: (v) => setState(() => _classId = v!),
              ),
              _dropdown(
                label: 'Year',
                value: _yearId,
                items: dummyYears
                    .map((y) => DropdownMenuItem(
                        value: y.yearId, child: Text(y.yearName)))
                    .toList(),
                onChanged: (v) => setState(() => _yearId = v!),
              ),
              _dropdown(
                label: 'Shift',
                value: _shiftId,
                items: dummyShifts
                    .map((s) => DropdownMenuItem(
                        value: s.shiftId, child: Text(s.shiftName)))
                    .toList(),
                onChanged: (v) => setState(() => _shiftId = v!),
              ),
              SwitchListTile(
                title: const Text('Present'),
                value: _isPresent,
                onChanged: (v) => setState(() => _isPresent = v),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveAttendance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
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

  Widget _textField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
