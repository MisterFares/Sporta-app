// fit/models/coach/program_model.dart

import 'package:fit/utils/image_url_helper.dart';

class CreateProgramRequest {
  final String tierId;
  final String title;
  final String description;
  final String serviceType;
  final int durationInWeeks;
  final List<String> features;
  final String status;
  final double basePrice;
  final double discount;
  final String discountType;
  final String? discountEndDate;
  final String? thumbnailImage;

  CreateProgramRequest({
    required this.tierId,
    required this.title,
    required this.description,
    required this.serviceType,
    required this.durationInWeeks,
    required this.features,
    required this.status,
    required this.basePrice,
    required this.discount,
    required this.discountType,
    this.discountEndDate,
    this.thumbnailImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'tierId': tierId,
      'title': title,
      'description': description,
      'serviceType': serviceType,
      'durationInWeeks': durationInWeeks,
      'features': features,
      'status': status,
      'basePrice': basePrice,
      'discount': discount,
      'discountType': discountType,
      if (discountEndDate != null) 'discountEndDate': discountEndDate,
      if (thumbnailImage != null) 'thumbnailImage': thumbnailImage,
    };
  }
}

class UpdateProgramRequest {
  final String title;
  final String description;
  final String serviceType;
  final int durationInWeeks;
  final List<String> features;
  final String status;
  final double basePrice;
  final double discount;
  final String discountType;
  final String? discountEndDate;
  final String? thumbnailImage;

  UpdateProgramRequest({
    required this.title,
    required this.description,
    required this.serviceType,
    required this.durationInWeeks,
    required this.features,
    required this.status,
    required this.basePrice,
    required this.discount,
    required this.discountType,
    this.discountEndDate,
    this.thumbnailImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'serviceType': serviceType,
      'durationInWeeks': durationInWeeks,
      'features': features,
      'status': status,
      'basePrice': basePrice,
      'discount': discount,
      'discountType': discountType,
      if (discountEndDate != null) 'discountEndDate': discountEndDate,
      if (thumbnailImage != null) 'thumbnailImage': thumbnailImage,
    };
  }
}

class ProgramResponse {
  final bool isSuccess;
  final String message;
  final dynamic data;
  final dynamic errors;

  ProgramResponse({
    required this.isSuccess,
    required this.message,
    this.data,
    this.errors,
  });

  factory ProgramResponse.fromJson(Map<String, dynamic> json) {
    return ProgramResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
      errors: json['errors'],
    );
  }
}

class ProgramData {
  final String id;
  final String tierId;
  final String title;
  final String description;
  final String serviceType;
  final int durationInWeeks;
  final List<String> features;
  final String status;
  final double basePrice;
  final double discount;
  final String discountType;
  final String? discountEndDate;
  final String? thumbnailImage;
  final int totalSales;
  final double netRevenue;
  final int activeUsers;

  ProgramData({
    required this.id,
    required this.tierId,
    required this.title,
    required this.description,
    required this.serviceType,
    required this.durationInWeeks,
    required this.features,
    required this.status,
    required this.basePrice,
    required this.discount,
    required this.discountType,
    this.discountEndDate,
    this.thumbnailImage,
    required this.totalSales,
    required this.netRevenue,
    required this.activeUsers,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tierId': tierId,
      'title': title,
      'description': description,
      'serviceType': serviceType,
      'durationInWeeks': durationInWeeks,
      'features': features,
      'status': status,
      'basePrice': basePrice,
      'discount': discount,
      'discountType': discountType,
      'discountEndDate': discountEndDate,
      'thumbnailImage': thumbnailImage,
      'totalSales': totalSales,
      'netRevenue': netRevenue,
      'activeUsers': activeUsers,
    };
  }

  factory ProgramData.fromJson(Map<String, dynamic> json) {
    final String thumbnailPath = json['thumbnail']?.toString() ?? '';

    // Parse duration from string like "4 Weeks" to int
    int parseDuration(dynamic durationValue) {
      if (durationValue == null) return 0;
      if (durationValue is int) return durationValue;
      if (durationValue is String) {
        // Extract number from "4 Weeks"
        final match = RegExp(r'(\d+)').firstMatch(durationValue);
        if (match != null) {
          return int.parse(match.group(1)!);
        }
      }
      return 0;
    }

    return ProgramData(
      id: json['id']?.toString() ?? '',
      tierId: json['tierId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      serviceType: json['serviceType']?.toString() ?? '',
      durationInWeeks: parseDuration(
        json['duration'],
      ), // 👈 Use 'duration' not 'durationInWeeks'
      features: List<String>.from(json['features'] ?? []),
      status: json['status']?.toString() ?? '',
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      discountType: json['discountType']?.toString() ?? 'None',
      discountEndDate: json['discountEndDate']?.toString(),
      thumbnailImage: ImageUrlHelper.getFullImageUrl(thumbnailPath),
      totalSales: json['totalSales'] as int? ?? 0,
      netRevenue: (json['netRevenue'] as num?)?.toDouble() ?? 0.0,
      activeUsers: json['activeUsers'] as int? ?? 0,
    );
  }
}
