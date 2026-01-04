class ScheduleModel {
  final String id;
  final String dayofweek;
  final String startTime;
  final String endTime;
  final String startDate;
  final String classId;
  final String teacherId;
  final String subjectId;
  final String roomId;

  ScheduleModel({
    required this.id,
    required this.dayofweek,
    required this.startTime,
    required this.endTime,
    required this.startDate,
    required this.classId,
    required this.teacherId,
    required this.subjectId,
    required this.roomId,
  });
}
