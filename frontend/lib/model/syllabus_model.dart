class SyllabusModel {
  final String id;
  final String facultyName;
  final String majorName;
  final String yearName;
  final String semesterName;
  final String subjectName;
  final String teacherName;
  final String shiftName;
  final String creditHours;
  final String scheduleInfo;

  SyllabusModel({
    required this.id,
    required this.facultyName,
    required this.majorName,
    required this.yearName,
    required this.semesterName,
    required this.subjectName,
    required this.teacherName,
    required this.shiftName,
    this.creditHours = '3',
    this.scheduleInfo = 'TBD',
  });

  /// Builds a [SyllabusModel] from the API response.
  ///
  /// Handles flat JSON keys, Eloquent-accessor keys, and nested `{id, name}`
  /// relation objects — all gracefully without losing data.
  factory SyllabusModel.fromJson(Map<String, dynamic> json) {
    return SyllabusModel(
      id: (json['id'] ?? json['syllabus_id'] ?? '').toString(),
      facultyName: _pick(json, [
        'faculty_name',
        'faculty_name_latin',
        'major_faculty_name',
        'faculty',
        'faculty_id',
      ]) ??
          '—',
      majorName: _pick(json, [
        'major_name',
        'major_name_latin',
        'major',
        'major_id',
      ]) ??
          '—',
      yearName: _pick(json, [
        'year_name',
        'year_name_latin',
        'year',
        'year_id',
        'academic_year',
      ]) ??
          '—',
      semesterName: _pick(json, [
        'semester_name',
        'semester_name_latin',
        'semester',
        'semester_id',
        'term',
      ]) ??
          '—',
      subjectName: _pick(json, [
        'subject_name',
        'subject_name_latin',
        'subject',
        'subject_id',
        'course_name',
      ]) ??
          '—',
      teacherName: _pick(json, [
        'teacher_name',
        'teacher_name_latin',
        'teacher',
        'instructor_name',
        'instructor',
      ]) ??
          '—',
      shiftName: _pick(json, [
        'shift_name',
        'shift_name_latin',
        'shift',
        'shift_id',
        'session_type',
      ]) ??
          '—',
      creditHours: _pickString(
        json,
        ['credit_hours', 'credits', 'credit', 'credit_hour'],
      ) ??
          '3',
      scheduleInfo: _pickString(
        json,
        ['schedule_description', 'schedule', 'class_schedule', 'time_slot'],
      ) ??
          '—',
    );
  }

  /// Returns the first value found for any of the given keys.
  ///
  /// If the value is a Map (Eloquent relation object), extracts `name` /
  /// `title` / `label` from it before returning.
  static String? _pick(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final raw = json[key];
      if (raw == null) continue;
      if (raw is Map) {
        final name = raw['name'] ?? raw['title'] ?? raw['label'];
        if (name != null) return name.toString();
      }
      if (raw is String && raw.isNotEmpty) return raw;
    }
    return null;
  }

  /// Like [_pick] but returns the raw trimmed string value, skipping '0'.
  static String? _pickString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final raw = json[key];
      if (raw == null) continue;
      final s = raw.toString().trim();
      if (s.isNotEmpty && s != '0') return s;
    }
    return null;
  }
}
