class SubscribedCoachesResponse {
  final bool isSuccess;
  final String message;
  final List<SubscribedCoach> data;
  final dynamic errors;

  SubscribedCoachesResponse({
    required this.isSuccess,
    required this.message,
    required this.data,
    this.errors,
  });

  factory SubscribedCoachesResponse.fromJson(Map<String, dynamic> json) {
    return SubscribedCoachesResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List? ?? [])
          .map((e) => SubscribedCoach.fromJson(e))
          .toList(),
      errors: json['errors'],
    );
  }
}

class SubscribedCoach {
  final String id;
  final CoachInfo coach;
  final String tier;
  final String status;
  final bool isRefundable;
  final SubscriptionInfo subscription;
  final int unreadMessages;

  SubscribedCoach({
    required this.id,
    required this.coach,
    required this.tier,
    required this.status,
    required this.isRefundable,
    required this.subscription,
    required this.unreadMessages,
  });

  factory SubscribedCoach.fromJson(Map<String, dynamic> json) {
    return SubscribedCoach(
      id: json['id']?.toString() ?? '',
      coach: CoachInfo.fromJson(json['coach'] ?? {}),
      tier: json['tier']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      isRefundable: json['isRefundable'] ?? false,
      subscription: SubscriptionInfo.fromJson(json['subscription'] ?? {}),
      unreadMessages: json['unreadMessages'] as int? ?? 0,
    );
  }
}

class CoachInfo {
  final String id;
  final String name;
  final String? image;
  final String specialization;

  CoachInfo({
    required this.id,
    required this.name,
    this.image,
    required this.specialization,
  });

  factory CoachInfo.fromJson(Map<String, dynamic> json) {
    return CoachInfo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString(),
      specialization: json['specialization']?.toString() ?? '',
    );
  }
}

class SubscriptionInfo {
  final DateTime startedAt;
  final DateTime lastUpdated;

  SubscriptionInfo({
    required this.startedAt,
    required this.lastUpdated,
  });

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionInfo(
      startedAt: DateTime.tryParse(json['startedAt']?.toString() ?? '') ?? DateTime.now(),
      lastUpdated: DateTime.tryParse(json['lastUpdated']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}