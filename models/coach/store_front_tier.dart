import 'package:fit/models/coach/program.dart';

class StorefrontTier {
  final String id;
  final bool isActive;
  final List<String> benefits;
  final List<Program> programs;

  StorefrontTier({
    required this.id,
    required this.isActive,
    required this.benefits,
    required this.programs,
  });

  factory StorefrontTier.fromJson(Map<String, dynamic> json) {
    return StorefrontTier(
      id: json['id']?.toString() ?? '',
      isActive: json['isActive'] ?? false,
      benefits: List<String>.from(json['benefits'] ?? []),
      programs: (json['programs'] as List? ?? [])
          .map((e) => Program.fromJson(e))
          .toList(),
    );
  }
}