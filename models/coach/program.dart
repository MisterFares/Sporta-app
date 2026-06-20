import 'dart:convert';

import 'package:fit/utils/image_url_helper.dart';

class Program {
  final String id;
  final String title;
  final String thumbnail;
  final String duration;
  final String serviceType;
  final String description;
  final List<String> features;
  final double? basePrice; // matches API: "basePrice": null
  final double finalPrice; // matches API: "finalPrice": 120
  final double discount; // matches API: "discount": 0
  bool isSubscribed; // matches API: "isSubscribed": false
  bool isAllowedToSubscribe; // matches API: "isAllowedToSubscribe": false
  final String tier; // matches API: "tier": "gold"

  Program({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.duration,
    required this.serviceType,
    required this.description,
    required this.features,
    this.basePrice,
    required this.finalPrice,
    required this.discount,
    required this.isSubscribed,
    required this.isAllowedToSubscribe,
    required this.tier,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    // Parse features (handle JSON string if needed)
    List<String> parseFeatures(dynamic featuresData) {
      if (featuresData == null) return [];
      List<String> result = [];
      for (var item in featuresData) {
        if (item is String) {
          try {
            final decoded = jsonDecode(item);
            if (decoded is List) {
              result.addAll(decoded.map((e) => e.toString()));
            } else {
              result.add(item);
            }
          } catch (e) {
            result.add(item);
          }
        } else {
          result.add(item.toString());
        }
      }
      return result;
    }

    final String thumbnailPath = json['thumbnail']?.toString() ?? '';

    return Program(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      thumbnail:
          ImageUrlHelper.getFullImageUrl(thumbnailPath) ?? '', // FIXED HERE
      duration: json['duration']?.toString() ?? '',
      serviceType: json['serviceType']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      features: parseFeatures(json['features']),
      basePrice: (json['basePrice'] as num?)?.toDouble(),
      finalPrice: (json['finalPrice'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      isSubscribed: json['isSubscribed'] ?? false,
      isAllowedToSubscribe: json['isAllowedToSubscribe'] ?? false,
      tier: json['tier']?.toString() ?? '',
    );
  }
}
