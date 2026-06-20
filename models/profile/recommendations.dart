// recommendations_model.dart
class Recommendation {
  final String id;
  final String targetUserId;
  final String targetName;
  final String targetImageUrl;
  final String targetSpecialization;
  final String content;
  final DateTime createdAt;

  Recommendation({
    required this.id,
    required this.targetUserId,
    required this.targetName,
    required this.targetImageUrl,
    required this.targetSpecialization,
    required this.content,
    required this.createdAt,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id']?.toString() ?? '',
      targetUserId: json['targetUserId']?.toString() ?? '',
      targetName: json['targetName']?.toString() ?? '',
      targetImageUrl: json['targetImageUrl']?.toString() ?? '',
      targetSpecialization: json['targetSpecialization']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString()) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'targetUserId': targetUserId,
      'targetName': targetName,
      'targetImageUrl': targetImageUrl,
      'targetSpecialization': targetSpecialization,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class RecommendationsResponse {
  final bool isSuccess;
  final String message;
  final List<Recommendation> received;
  final List<Recommendation> given;
  final String userId;
  final String role;

  RecommendationsResponse({
    required this.isSuccess,
    required this.message,
    required this.received,
    required this.given,
    required this.userId,
    required this.role,
  });

  factory RecommendationsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final receivedList = data['received'] as List<dynamic>? ?? [];
    final givenList = data['given'] as List<dynamic>? ?? [];
    
    return RecommendationsResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      received: receivedList.map((item) => Recommendation.fromJson(item)).toList(),
      given: givenList.map((item) => Recommendation.fromJson(item)).toList(),
      userId: data['userId']?.toString() ?? '',
      role: data['role']?.toString() ?? '',
    );
  }
}