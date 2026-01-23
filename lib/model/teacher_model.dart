class TeacherModel {
  final String id;
  final String teacherid;
  final String fullName;
  final String gender;
  final String specialization;
  final String year;
  final String schedule;
  final String phone;
  final String email;
  final String userid;
  final String facultyid;
  final String? imagePath;

  TeacherModel({
    required this.id,
    required this.teacherid,
    required this.fullName,
    required this.gender,
    required this.specialization,
    required this.year,
    required this.schedule,
    required this.phone,
    required this.email,
    required this.userid,
    required this.facultyid,
    this.imagePath,
  });

  TeacherModel copyWith({
    String? id,
    String? teacherid,
    String? fullName,
    String? nickname,
    String? gender,
    String? specalization,
    String? year,
    String? schedule,
    String? phone,
    String? email,
    String? userid,
    String? facultyid,
    String? imagePath,
  }) {
    return TeacherModel(
      id: id ?? this.id,
      teacherid: teacherid ?? this.teacherid,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      specialization: specalization ?? this.specialization,
      year: year ?? this.year,
      schedule: schedule ?? this.schedule,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      userid: userid ?? this.userid,
      facultyid: facultyid ?? this.facultyid,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacherid': teacherid,
      'fullName': fullName,
      'gender': gender,
      'specalization': specialization,
      'year': year,
      'schedule': schedule,
      'phone': phone,
      'email': email,
      'userid': userid,
      'facultyid': facultyid,
      'imagePath': imagePath,
    };
  }

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'],
      teacherid: json['teacherid'],
      fullName: json['fullName'],
      gender: json['gender'],
      specialization: json['specialization'],
      year: json['year'],
      schedule: json['schedule'],
      phone: json['phone'],
      email: json['email'],
      userid: json['userid'],
      facultyid: json['facultyid'],
      imagePath: json['imagePath'],
    );
  }
}
