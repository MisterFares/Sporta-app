class WalletResponse {
  final bool isSuccess;
  final String message;
  final WalletData data;
  final dynamic errors;

  WalletResponse({
    required this.isSuccess,
    required this.message,
    required this.data,
    this.errors,
  });

  factory WalletResponse.fromJson(Map<String, dynamic> json) {
    return WalletResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      data: WalletData.fromJson(json['data'] ?? {}),
      errors: json['errors'],
    );
  }
}

class WalletData {
  final double availableBalance;
  final double pendingClearance;
  final double totalEarnings;

  WalletData({
    required this.availableBalance,
    required this.pendingClearance,
    required this.totalEarnings,
  });

  factory WalletData.fromJson(Map<String, dynamic> json) {
    return WalletData(
      availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0.0,
      pendingClearance: (json['pendingClearance'] as num?)?.toDouble() ?? 0.0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
    );
  }
}