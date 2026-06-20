class CoachStatsResponse {
  final bool isSuccess;
  final String message;
  final CoachStatsData data;
  final dynamic errors;

  CoachStatsResponse({
    required this.isSuccess,
    required this.message,
    required this.data,
    this.errors,
  });

  factory CoachStatsResponse.fromJson(Map<String, dynamic> json) {
    return CoachStatsResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      data: CoachStatsData.fromJson(json['data'] ?? {}),
      errors: json['errors'],
    );
  }
}

class CoachStatsData {
  final double withdrawableBalance;
  final double escrowPendingBalance;
  final double totalLifetimeRevenue;
  final int totalCustomersCount;
  final int activeClientsCount;
  final int pendingClientsCount;
  final double growthRatePercentage;
  final double retentionRatePercentage;

  CoachStatsData({
    required this.withdrawableBalance,
    required this.escrowPendingBalance,
    required this.totalLifetimeRevenue,
    required this.totalCustomersCount,
    required this.activeClientsCount,
    required this.pendingClientsCount,
    required this.growthRatePercentage,
    required this.retentionRatePercentage,
  });

  factory CoachStatsData.fromJson(Map<String, dynamic> json) {
    return CoachStatsData(
      withdrawableBalance: (json['withdrawableBalance'] as num?)?.toDouble() ?? 0.0,
      escrowPendingBalance: (json['escrowPendingBalance'] as num?)?.toDouble() ?? 0.0,
      totalLifetimeRevenue: (json['totalLifetimeRevenue'] as num?)?.toDouble() ?? 0.0,
      totalCustomersCount: json['totalCustomersCount'] as int? ?? 0,
      activeClientsCount: json['activeClientsCount'] as int? ?? 0,
      pendingClientsCount: json['pendingClientsCount'] as int? ?? 0,
      growthRatePercentage: (json['growthRatePercentage'] as num?)?.toDouble() ?? 0.0,
      retentionRatePercentage: (json['retentionRatePercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}