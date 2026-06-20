class ToggleTierRequest {
  final bool isActive;

  ToggleTierRequest({
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'isActive': isActive,
    };
  }
}