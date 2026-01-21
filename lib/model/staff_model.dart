class StaffModel {
  final String id;
  final String staffid;
  final String fullName;
  final String specalization;
  final String department;
  final String phone;
  final String email;

  final String userid;

  StaffModel(
      {required this.id,
      required this.staffid,
      required this.fullName,
      required this.specalization,
      required this.department,
      required this.phone,
      required this.email,
      required this.userid});
}
