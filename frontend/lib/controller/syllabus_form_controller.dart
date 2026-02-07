import 'package:flutter/material.dart';
import 'package:sbku_app/domain/entities/syllabus_entity.dart';
import 'package:sbku_app/model/class_model.dart';
import 'package:sbku_app/model/teacher_model.dart';
import 'package:sbku_app/model/subject_model.dart';
import 'package:sbku_app/model/shift_model.dart';
import 'package:sbku_app/model/semester_model.dart';
import 'package:sbku_app/model/year_model.dart';

class SyllabusFormController {
  /// ID controllers (for saving)
  final TextEditingController idController;
  final TextEditingController classIdController;
  final TextEditingController teacherIdController;
  final TextEditingController subjectIdController;
  final TextEditingController shiftIdController;
  final TextEditingController semesterIdController;
  final TextEditingController yearIdController;

  /// Display controllers (for UI)
  final TextEditingController classNameController;
  final TextEditingController teacherNameController;
  final TextEditingController subjectNameController;
  final TextEditingController shiftNameController;
  final TextEditingController semesterNameController;
  final TextEditingController yearNameController;

  SyllabusFormController({
    SyllabusEntity? entity,
    required Map<String, ClassModel> classMap,
    required Map<String, TeacherModel> teacherMap,
    required Map<String, SubjectModel> subjectMap,
    required Map<String, ShiftModel> shiftMap,
    required Map<String, SemesterModel> semesterMap,
    required Map<String, YearModel> yearMap,
  })  : idController = TextEditingController(text: entity?.id ?? ''),
        classIdController = TextEditingController(text: entity?.classId ?? ''),
        teacherIdController =
            TextEditingController(text: entity?.teacherId ?? ''),
        subjectIdController =
            TextEditingController(text: entity?.subjectId ?? ''),
        shiftIdController = TextEditingController(text: entity?.shiftId ?? ''),
        semesterIdController =
            TextEditingController(text: entity?.semesterId ?? ''),
        yearIdController = TextEditingController(text: entity?.yearId ?? ''),

        // 🔁 ID → NAME mapping happens HERE
        classNameController = TextEditingController(
          text: entity != null ? classMap[entity.classId]?.className ?? '' : '',
        ),
        teacherNameController = TextEditingController(
          text: entity != null
              ? teacherMap[entity.teacherId]?.fullName ?? ''
              : '',
        ),
        subjectNameController = TextEditingController(
          text: entity != null
              ? subjectMap[entity.subjectId]?.subjectName ?? ''
              : '',
        ),
        shiftNameController = TextEditingController(
          text: entity != null ? shiftMap[entity.shiftId]?.shiftName ?? '' : '',
        ),
        semesterNameController = TextEditingController(
          text:
              entity != null ? semesterMap[entity.semesterId]?.name ?? '' : '',
        ),
        yearNameController = TextEditingController(
          text: entity != null ? yearMap[entity.yearId]?.yearName ?? '' : '',
        );

  // ✅ Save → ENTITY (IDs only)
  SyllabusEntity toSyllabusEntity() {
    return SyllabusEntity(
      id: idController.text.trim(),
      classId: classIdController.text.trim(),
      teacherId: teacherIdController.text.trim(),
      subjectId: subjectIdController.text.trim(),
      shiftId: shiftIdController.text.trim(),
      semesterId: semesterIdController.text.trim(),
      yearId: yearIdController.text.trim(),
    );
  }

  // 🔁 When user selects a class (dropdown)
  void setClass(String classId, String className) {
    classIdController.text = classId;
    classNameController.text = className;
  }

  void setTeacher(String id, String name) {
    teacherIdController.text = id;
    teacherNameController.text = name;
  }

  void setSubject(String id, String name) {
    subjectIdController.text = id;
    subjectNameController.text = name;
  }

  void setShift(String id, String name) {
    shiftIdController.text = id;
    shiftNameController.text = name;
  }

  void setSemester(String id, String name) {
    semesterIdController.text = id;
    semesterNameController.text = name;
  }

  void setYear(String id, String name) {
    yearIdController.text = id;
    yearNameController.text = name;
  }

  bool validateAllFields() {
    return idController.text.isNotEmpty &&
        classIdController.text.isNotEmpty &&
        teacherIdController.text.isNotEmpty &&
        subjectIdController.text.isNotEmpty &&
        shiftIdController.text.isNotEmpty &&
        semesterIdController.text.isNotEmpty &&
        yearIdController.text.isNotEmpty;
  }

  void clearAll() {
    idController.clear();
    classIdController.clear();
    teacherIdController.clear();
    subjectIdController.clear();
    shiftIdController.clear();
    semesterIdController.clear();
    yearIdController.clear();

    classNameController.clear();
    teacherNameController.clear();
    subjectNameController.clear();
    shiftNameController.clear();
    semesterNameController.clear();
    yearNameController.clear();
  }

  void dispose() {
    idController.dispose();
    classIdController.dispose();
    teacherIdController.dispose();
    subjectIdController.dispose();
    shiftIdController.dispose();
    semesterIdController.dispose();
    yearIdController.dispose();

    classNameController.dispose();
    teacherNameController.dispose();
    subjectNameController.dispose();
    shiftNameController.dispose();
    semesterNameController.dispose();
    yearNameController.dispose();
  }
}
