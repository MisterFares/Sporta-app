class User {
  String name;
  String email;
  String password;
  String role;
  DateTime birthDate;
  String gender;
  int? height;
  double? weight;
  User({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.birthDate,
    required this.gender,
    this.height,
    this.weight,
  });
}
