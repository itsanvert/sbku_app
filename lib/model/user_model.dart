class UserModel {
  final String id;
  final String userName;
  final String email;
  final String passwordhash;
  final String phone;
  final String usertype;

  UserModel(
      {required this.id,
      required this.userName,
      required this.email,
      required this.passwordhash,
      required this.phone,
      required this.usertype});
}
