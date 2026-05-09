class Trainee {
  final int id;
  final String name;
  final String email;
  final String level;
  final String weight;
  final String subscription;
  final String status;
  final String avatar;
  final String? joinedDate;
  final String? startDate;
  final String? assignedProgram;
  final String? paymentStatus;

  Trainee({
    required this.id,
    required this.name,
    required this.email,
    required this.level,
    required this.weight,
    required this.subscription,
    required this.status,
    required this.avatar,
    this.joinedDate,
    this.startDate,
    this.assignedProgram,
    this.paymentStatus,
  });
}