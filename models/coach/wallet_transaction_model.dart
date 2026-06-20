// Transactions Response
class WalletTransactionsResponse {
  final bool isSuccess;
  final String message;
  final WalletTransactionsData data;
  final dynamic errors;

  WalletTransactionsResponse({
    required this.isSuccess,
    required this.message,
    required this.data,
    this.errors,
  });

  factory WalletTransactionsResponse.fromJson(Map<String, dynamic> json) {
    return WalletTransactionsResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      data: WalletTransactionsData.fromJson(json['data'] ?? {}),
      errors: json['errors'],
    );
  }
}

class WalletTransactionsData {
  final List<WalletTransaction> items;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final int totalCount;
  final bool hasPreviousPage;
  final bool hasNextPage;

  WalletTransactionsData({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.totalCount,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory WalletTransactionsData.fromJson(Map<String, dynamic> json) {
    return WalletTransactionsData(
      items: (json['items'] as List? ?? [])
          .map((e) => WalletTransaction.fromJson(e))
          .toList(),
      currentPage: json['currentPage'] as int? ?? 1,
      totalPages: json['totalPages'] as int? ?? 0,
      pageSize: json['pageSize'] as int? ?? 10,
      totalCount: json['totalCount'] as int? ?? 0,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
      hasNextPage: json['hasNextPage'] ?? false,
    );
  }
}

class WalletTransaction {
  final String id;
  final String type; // Income, Fee, Withdrawal, Refund
  final double amount;
  final String status;
  final String description;
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    required this.description,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id']?.toString() ?? '',
      type: json['transactionType']?.toString() ?? '', // 👈 Changed from 'type'
      amount:
          (json['netAmount'] as num?)?.toDouble() ??
          0.0, // 👈 Changed from 'amount'
      status:
          json['transactionStatus']?.toString() ??
          '', // 👈 Changed from 'status'
      description: json['description']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

// Withdrawal Request
class WithdrawalRequest {
  final double withdrawalAmount;
  final String payoutMethod; // "Bank", "PayPal", etc.
  final String payoutMethodDetails; // Account number, email, etc.

  WithdrawalRequest({
    required this.withdrawalAmount,
    required this.payoutMethod,
    required this.payoutMethodDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      'withdrawalAmount': withdrawalAmount,
      'payoutMethod': payoutMethod,
      'payoutMethodDetails': payoutMethodDetails,
    };
  }
}

class WithdrawalResponse {
  final bool isSuccess;
  final String message;
  final dynamic data;
  final dynamic errors;

  WithdrawalResponse({
    required this.isSuccess,
    required this.message,
    this.data,
    this.errors,
  });

  factory WithdrawalResponse.fromJson(Map<String, dynamic> json) {
    return WithdrawalResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
      errors: json['errors'],
    );
  }
}
