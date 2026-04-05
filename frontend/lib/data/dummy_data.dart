import 'package:sbku_app/domain/entities/attendance_entity.dart';
import 'package:sbku_app/domain/entities/syllabus_entity.dart';
import 'package:sbku_app/model/attendance_session_model.dart';
import 'package:sbku_app/model/staff_model.dart';

// ── Simple lightweight models used only for display ────────────────────────

class FacultyDummy {
  final String id;
  final String facultyName;
  const FacultyDummy({required this.id, required this.facultyName});
}

class ClassDummy {
  final String id;
  final String className;
  const ClassDummy({required this.id, required this.className});
}

class ShiftDummy {
  final String id;
  final String shiftName;
  final String startTime;
  final String endTime;
  const ShiftDummy({
    required this.id,
    required this.shiftName,
    this.startTime = '07:00',
    this.endTime = '11:00',
  });
}

class MajorDummy {
  final String id;
  final String majorName;
  const MajorDummy({required this.id, required this.majorName});
}

class YearDummy {
  final String id;
  final String yearName;
  const YearDummy({required this.id, required this.yearName});
}

// ── Dummy faculty list ──────────────────────────────────────────────────────

final List<FacultyDummy> dummyFaculties = [
  const FacultyDummy(id: 'F001', facultyName: 'មហាវិទ្យាល័យបច្ចេកវិទ្យា'),
  const FacultyDummy(id: 'F002', facultyName: 'មហាវិទ្យាល័យគ្រប់គ្រង'),
  const FacultyDummy(id: 'F003', facultyName: 'មហាវិទ្យាល័យសេដ្ឋកិច្ច'),
];

// ── Dummy class list ────────────────────────────────────────────────────────

final List<ClassDummy> dummyClasses = [
  const ClassDummy(id: 'C001', className: 'IT-Y1-A'),
  const ClassDummy(id: 'C002', className: 'IT-Y2-A'),
  const ClassDummy(id: 'C003', className: 'BM-Y1-A'),
];

// ── Dummy shift list ────────────────────────────────────────────────────────

final List<ShiftDummy> dummyShifts = [
  const ShiftDummy(id: 'SH1', shiftName: 'ព្រឹក (Morning)', startTime: '07:00', endTime: '11:00'),
  const ShiftDummy(id: 'SH2', shiftName: 'រសៀល (Afternoon)', startTime: '13:00', endTime: '17:00'),
  const ShiftDummy(id: 'SH3', shiftName: 'ល្ងាច (Evening)', startTime: '17:30', endTime: '21:00'),
];

// ── Dummy major list ────────────────────────────────────────────────────────

final List<MajorDummy> dummyMajors = [
  const MajorDummy(id: 'M01', majorName: 'Computer Science'),
  const MajorDummy(id: 'M02', majorName: 'Business Administration'),
  const MajorDummy(id: 'M03', majorName: 'Accounting'),
];

// ── Dummy year list ─────────────────────────────────────────────────────────

final List<YearDummy> dummyYears = [
  const YearDummy(id: 'Y1', yearName: 'ឆ្នាំទី 1 (Year 1)'),
  const YearDummy(id: 'Y2', yearName: 'ឆ្នាំទី 2 (Year 2)'),
  const YearDummy(id: 'Y3', yearName: 'ឆ្នាំទី 3 (Year 3)'),
  const YearDummy(id: 'Y4', yearName: 'ឆ្នាំទី 4 (Year 4)'),
  const YearDummy(id: 'Y5', yearName: 'ឆ្នាំទី 5 (Year 5)'),
];

// ── Dummy student name lookup ────────────────────────────────────────────────

final Map<String, String> _studentNameMap = {
  'S001': 'Sokha Chan',
  'S002': 'Borey Oun',
  'S003': 'Sreyleak Kim',
};

String getStudentNameById(String id) =>
    _studentNameMap[id] ?? 'Student $id';

// ── In-memory attendance session list ───────────────────────────────────────
// A mutable list so screens can update session state locally.

List<AttendanceSession> attendanceSessions = [
  AttendanceSession(
    id: 'AS001',
    teacherId: 'T001',
    facultyId: 'F001',
    majorId: 'M001',
    classId: 'C001',
    yearId: '1',
    shiftId: 'SH001',
    latitude: 11.5689,
    longitude: 104.9210,
    startTime: DateTime.now().subtract(const Duration(hours: 1)),
    isActive: true,
    attendedStudentIds: ['S001'],
  ),
];

/// Placeholder: generate attendance records from a closed session.
/// Replace with a real API call when the backend is ready.
void generateAttendanceFromSession(AttendanceSession session) {
  // TODO: POST to /api/attendance-sessions/{id}/close or similar
}

// ── Dummy staff list ─────────────────────────────────────────────────────────

List<StaffModel> dummyStaffs = [
  StaffModel(
    id: '1',
    staffid: 'STF001',
    fullName: 'Dara Prak',
    specalization: 'Computer Science',
    department: 'IT',
    phone: '012-345-678',
    email: 'dara@sbku.edu',
    userid: 'U001',
  ),
  StaffModel(
    id: '2',
    staffid: 'STF002',
    fullName: 'Sophea Lim',
    specalization: 'Business Administration',
    department: 'Management',
    phone: '017-654-321',
    email: 'sophea@sbku.edu',
    userid: 'U002',
  ),
];

// ── Dummy attendance entity list ─────────────────────────────────────────────
// Represents finalized attendance records (one per student per session).

final List<AttendanceEntity> dummyAttendanceEntities = [
  AttendanceEntity(
    id: 'ATT001',
    studentId: 'S001',
    studentName: 'Sokha Chan',
    facultyId: 'F001',
    majorId: 'M01',
    shiftId: 'SH1',
    classId: 'C001',
    yearId: 'Y1',
    date: DateTime.now().subtract(const Duration(days: 1)),
    status: 'Y',
    verifyStatus: 'approved',
  ),
  AttendanceEntity(
    id: 'ATT002',
    studentId: 'S002',
    studentName: 'Borey Oun',
    facultyId: 'F001',
    majorId: 'M01',
    shiftId: 'SH1',
    classId: 'C001',
    yearId: 'Y1',
    date: DateTime.now().subtract(const Duration(days: 1)),
    status: 'N',
    verifyStatus: 'approved',
  ),
  AttendanceEntity(
    id: 'ATT003',
    studentId: 'S003',
    studentName: 'Sreyleak Kim',
    facultyId: 'F002',
    majorId: 'M02',
    shiftId: 'SH2',
    classId: 'C003',
    yearId: 'Y2',
    date: DateTime.now(),
    status: 'Y',
    verifyStatus: 'approved',
  ),
];

// ── Dummy Semester list ──────────────────────────────────────────────────────

class SemesterDummy {
  final String id;
  final String name;
  const SemesterDummy({required this.id, required this.name});
}

final List<SemesterDummy> dummySemesters = [
  const SemesterDummy(id: 'SEM1', name: 'Semester 1'),
  const SemesterDummy(id: 'SEM2', name: 'Semester 2'),
];

// ── Dummy Subject list ───────────────────────────────────────────────────────

class SubjectDummy {
  final String id;
  final String subjectName;
  const SubjectDummy({required this.id, required this.subjectName});
}

final List<SubjectDummy> dummySubjects = [
  const SubjectDummy(id: 'SUB101', subjectName: 'Introduction to IT'),
  const SubjectDummy(id: 'SUB102', subjectName: 'Programming Fundamentals'),
  const SubjectDummy(id: 'SUB201', subjectName: 'Data Structures'),
  const SubjectDummy(id: 'SUB202', subjectName: 'Database Systems'),
  const SubjectDummy(id: 'SUB301', subjectName: 'Software Engineering'),
  const SubjectDummy(id: 'SUB302', subjectName: 'Network Security'),
  const SubjectDummy(id: 'SUB401', subjectName: 'Artificial Intelligence'),
];

// ── Dummy Syllabus Entity list ──────────────────────────────────────────────

final List<SyllabusEntity> dummySyllabus = [
  // Year 1, Semester 1
  SyllabusEntity(
    id: 'SYL001',
    facultyId: 'F001',
    majorId: 'M01',
    subjectId: 'SUB101',
    teacherId: 'T001',
    shiftId: 'SH1',
    yearId: 'Y1',
    semesterId: 'SEM1',
    creditHours: '3',
    scheduleDescription: 'Mon 07:30 - 10:30',
  ),
  // Year 1, Semester 2
  SyllabusEntity(
    id: 'SYL002',
    facultyId: 'F001',
    majorId: 'M01',
    subjectId: 'SUB102',
    teacherId: 'T002',
    shiftId: 'SH1',
    yearId: 'Y1',
    semesterId: 'SEM2',
    creditHours: '4',
    scheduleDescription: 'Tue 08:00 - 11:30',
  ),
  // Year 2, Semester 1
  SyllabusEntity(
    id: 'SYL003',
    facultyId: 'F001',
    majorId: 'M01',
    subjectId: 'SUB201',
    teacherId: 'T001',
    shiftId: 'SH1',
    yearId: 'Y2',
    semesterId: 'SEM1',
    creditHours: '3',
    scheduleDescription: 'Wed 13:00 - 16:00',
  ),
  // Year 3, Semester 1
  SyllabusEntity(
    id: 'SYL004',
    facultyId: 'F001',
    majorId: 'M01',
    subjectId: 'SUB301',
    teacherId: 'T001',
    shiftId: 'SH2',
    yearId: 'Y3',
    semesterId: 'SEM1',
    creditHours: '3',
    scheduleDescription: 'Fri 07:30 - 10:30',
  ),
  // Year 4, Semester 1
  SyllabusEntity(
    id: 'SYL005',
    facultyId: 'F001',
    majorId: 'M01',
    subjectId: 'SUB401',
    teacherId: 'T002',
    shiftId: 'SH1',
    yearId: 'Y4',
    semesterId: 'SEM1',
    creditHours: '3',
    scheduleDescription: 'Mon 13:00 - 16:00',
  ),
  // Year 5, Semester 1 (Final Thesis)
  SyllabusEntity(
    id: 'SYL006',
    facultyId: 'F001',
    majorId: 'M01',
    subjectId: 'SUB401', // Reusing AI as placeholder
    teacherId: 'T001',
    shiftId: 'SH1',
    yearId: 'Y5',
    semesterId: 'SEM2',
    creditHours: '6',
    scheduleDescription: 'Thesis Project',
  ),
];


