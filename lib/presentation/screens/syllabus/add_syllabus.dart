import 'package:flutter/material.dart';
import 'package:sbku_app/controller/syllabus_form_controller.dart';
import 'package:sbku_app/data/dummy_class.dart';
import 'package:sbku_app/data/dummy_semester.dart';
import 'package:sbku_app/data/dummy_shirt.dart';
import 'package:sbku_app/data/dummy_staff.dart';
import 'package:sbku_app/data/dummy_subject.dart';
import 'package:sbku_app/data/dummy_syllabus.dart';
import 'package:sbku_app/data/dummy_teacher.dart';
import 'package:sbku_app/data/dummy_year.dart';
import 'package:sbku_app/domain/entities/syllabus_entity.dart';
import 'package:sbku_app/model/teacher_model.dart';
import 'package:sbku_app/presentation/widgets/appbar_widget.dart';
import 'package:sbku_app/presentation/widgets/appbutton_widget.dart';
import 'package:sbku_app/presentation/widgets/custom_text_field.dart';

// lookup data

class AddSyllabusScreen extends StatefulWidget {
  final SyllabusEntity? syllabus;

  const AddSyllabusScreen({super.key, this.syllabus});

  @override
  State<AddSyllabusScreen> createState() => _AddSyllabusScreenState();
}

class _AddSyllabusScreenState extends State<AddSyllabusScreen> {
  late final SyllabusFormController _formController;
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  bool get _isEditing => widget.syllabus != null;

  @override
  void initState() {
    super.initState();

    _formController = SyllabusFormController(
      entity: widget.syllabus,
      classMap: {for (final c in dummyClasses) c.classId: c},
      teacherMap: {for (final t in dummyTeachers) t.id: t},
      subjectMap: {for (final s in dummySubjects) s.id: s},
      shiftMap: {for (final s in dummyShifts) s.shiftId: s},
      semesterMap: {for (final s in dummySemesters) s.id: s},
      yearMap: {for (final y in dummyYears) y.yearId: y},
    );
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

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
      final entity = _formController.toSyllabusEntity();

      if (_isEditing) {
        final index = dummySyllabus.indexWhere((s) => s.id == entity.id);
        if (index != -1) {
          dummySyllabus[index] = entity;
        }
      } else {
        dummySyllabus.add(entity);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Syllabus updated successfully'
                  : 'Syllabus added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: _isEditing ? 'Edit Syllabus' : 'Add Syllabus',
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextField(
                  label: 'ថ្នាក់',
                  controller: _formController.classNameController,
                ),
                CustomTextField(
                  label: 'សាស្ត្រាចារ្យ',
                  controller: _formController.teacherNameController,
                ),
                CustomTextField(
                  label: 'មុខវិជ្ជា',
                  controller: _formController.subjectNameController,
                ),
                const SizedBox(height: 32),
                _isLoading
                    ? const CircularProgressIndicator()
                    : AppButton(
                        label: _isEditing ? 'Update Syllabus' : 'Add Syllabus',
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
