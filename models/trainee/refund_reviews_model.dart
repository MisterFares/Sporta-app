// Refund Request
class RefundRequest {
  final String subscriptionId;
  final String disputeReason;

  RefundRequest({
    required this.subscriptionId,
    required this.disputeReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'subscriptionId': subscriptionId,
      'disputeReason': disputeReason,
    };
  }
}

class RefundResponse {
  final bool isSuccess;
  final String message;
  final dynamic data;
  final dynamic errors;

  RefundResponse({
    required this.isSuccess,
    required this.message,
    this.data,
    this.errors,
  });

  factory RefundResponse.fromJson(Map<String, dynamic> json) {
    return RefundResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
      errors: json['errors'],
    );
  }
}

// Review Submit
class ReviewRequest {
  final String subscriptionId;
  final int rating; // 1-5
  final String comment;

  ReviewRequest({
    required this.subscriptionId,
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'subscriptionId': subscriptionId,
      'rating': rating,
      'comment': comment,
    };
  }
}

class ReviewResponse {
  final bool isSuccess;
  final String message;
  final dynamic data;
  final dynamic errors;

  ReviewResponse({
    required this.isSuccess,
    required this.message,
    this.data,
    this.errors,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
      errors: json['errors'],
    );
  }
}