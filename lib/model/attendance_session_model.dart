class AttendanceSession {
  final String id;
  final String teacherId;
  final String facultyId;
  final String majorId;
  final String classId;
  final String yearId;
  final String shiftId;
  final double latitude;
  final double longitude;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isActive;

  AttendanceSession({
    required this.id,
    required this.teacherId,
    required this.facultyId,
    required this.majorId,
    required this.classId,
    required this.yearId,
    required this.shiftId,
    required this.latitude,
    required this.longitude,
    required this.startTime,
    this.endTime,
    this.isActive = true,
  });

  AttendanceSession copyWith({
    String? id,
    String? teacherId,
    String? facultyId,
    String? majorId,
    String? classId,
    String? yearId,
    String? shiftId,
    double? latitude,
    double? longitude,
    DateTime? startTime,
    DateTime? endTime,
    bool? isActive,
  }) {
    return AttendanceSession(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      facultyId: facultyId ?? this.facultyId,
      majorId: majorId ?? this.majorId,
      classId: classId ?? this.classId,
      yearId: yearId ?? this.yearId,
      shiftId: shiftId ?? this.shiftId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
    );
  }
}
