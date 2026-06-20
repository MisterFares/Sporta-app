import 'package:fit/utils/image_url_helper.dart';

class TraineesResponse {
  final bool isSuccess;
  final String message;
  final TraineesData data;
  final dynamic errors;

  TraineesResponse({
    required this.isSuccess,
    required this.message,
    required this.data,
    this.errors,
  });

  factory TraineesResponse.fromJson(Map<String, dynamic> json) {
    return TraineesResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      data: TraineesData.fromJson(json['data'] ?? {}),
      errors: json['errors'],
    );
  }
}

class TraineesData {
  final List<TraineeSubscription> items;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final int totalCount;
  final bool hasPreviousPage;
  final bool hasNextPage;

  TraineesData({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.totalCount,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory TraineesData.fromJson(Map<String, dynamic> json) {
    return TraineesData(
      items: (json['items'] as List? ?? [])
          .map((e) => TraineeSubscription.fromJson(e))
          .toList(),
      currentPage: json['currentPage'] as int? ?? 1,
      totalPages: json['totalPages'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 10,
      totalCount: json['totalCount'] as int? ?? 0,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
      hasNextPage: json['hasNextPage'] ?? false,
    );
  }
}

class TraineeSubscription {
  final String id;
  final String traineeId;
  final String traineeName;
  final String traineeEmail;
  final String traineeAvatar;
  final String tier;
  final String programTitle;
  final String duration;
  final String subscriptionStatus;
  final int daysRemaining;
  final bool hasWorkoutPlan;
  final bool hasNutritionPlan;
  final bool workoutUploaded;
  final bool nutritionUploaded;
  final int unreadMessages;
  final int reviewTimer;
  final bool refundLocked;
  final DateTime createdAt;
  final double amount;
  final DateTime? startDate;
  final DateTime? endDate;

  TraineeSubscription({
    required this.id,
    required this.traineeId,
    required this.traineeName,
    required this.traineeEmail,
    required this.traineeAvatar,
    required this.tier,
    required this.programTitle,
    required this.duration,
    required this.subscriptionStatus,
    required this.daysRemaining,
    required this.hasWorkoutPlan,
    required this.hasNutritionPlan,
    required this.workoutUploaded,
    required this.nutritionUploaded,
    required this.unreadMessages,
    required this.reviewTimer,
    required this.refundLocked,
    required this.createdAt,
    required this.amount,
    this.startDate,
    this.endDate,
  });

  factory TraineeSubscription.fromJson(Map<String, dynamic> json) {
    final String avatarPath = json['traineeAvatar']?.toString() ?? '';
    return TraineeSubscription(
      id: json['id']?.toString() ?? '',
      traineeId: json['traineeId']?.toString() ?? '',
      traineeName: json['traineeName']?.toString() ?? '',
      traineeEmail: json['traineeEmail']?.toString() ?? '',
      traineeAvatar: ImageUrlHelper.getFullImageUrl(avatarPath) ?? '',
      tier: json['tier']?.toString() ?? '',
      programTitle: json['programTitle']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      subscriptionStatus: json['subscriptionStatus']?.toString() ?? '',
      daysRemaining: json['daysRemaining'] as int? ?? 0,
      hasWorkoutPlan: json['hasWorkoutPlan'] ?? false,
      hasNutritionPlan: json['hasNutritionPlan'] ?? false,
      workoutUploaded: json['workoutUploaded'] ?? false,
      nutritionUploaded: json['nutritionUploaded'] ?? false,
      unreadMessages: json['unreadMessages'] as int? ?? 0,
      reviewTimer: json['reviewTimer'] as int? ?? 0,
      refundLocked: json['refundLocked'] ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
    );
  }
}
