import 'package:fit/models/coach/program_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ToggleTierResponse {
  final bool isSuccess;
  final String message;
  final dynamic data;
  final dynamic errors;

  ToggleTierResponse({
    required this.isSuccess,
    required this.message,
    this.data,
    this.errors,
  });

  factory ToggleTierResponse.fromJson(Map<String, dynamic> json) {
    return ToggleTierResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
      errors: json['errors'],
    );
  }
}

class UpdateTierRequest {
  final String oneOnOneCallsOption;
  final String emergencyAdjustmentsOption;
  final List<String> customFeatures;

  UpdateTierRequest({
    required this.oneOnOneCallsOption,
    required this.emergencyAdjustmentsOption,
    required this.customFeatures,
  });

  Map<String, dynamic> toJson() {
    return {
      'oneOnOneCallsOption': oneOnOneCallsOption,
      'emergencyAdjustmentsOption': emergencyAdjustmentsOption,
      'customFeatures': customFeatures,
    };
  }
}

class UpdateTierResponse {
  final bool isSuccess;
  final String message;
  final dynamic data;
  final dynamic errors;

  UpdateTierResponse({
    required this.isSuccess,
    required this.message,
    this.data,
    this.errors,
  });

  factory UpdateTierResponse.fromJson(Map<String, dynamic> json) {
    return UpdateTierResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
      errors: json['errors'],
    );
  }
}

// Tier Details Response
class TierDetailsResponse {
  final bool isSuccess;
  final String message;
  final TierDetailsData data;
  final dynamic errors;

  TierDetailsResponse({
    required this.isSuccess,
    required this.message,
    required this.data,
    this.errors,
  });

  factory TierDetailsResponse.fromJson(Map<String, dynamic> json) {
    return TierDetailsResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      data: TierDetailsData.fromJson(json['data'] ?? {}),
      errors: json['errors'],
    );
  }
}

class TierDetailsData {
  final String id;
  final String title;
  bool active;
  String oneOnOneCall;
  String emergencyAdjustments;
  List<String> customFeatures;
  final List<ProgramData> programs;
  final PerformanceStatsData performanceStats;
  final List<ChartDataPoint> chartData;

  // UI-specific properties
  final Color color;
  final IconData icon;
  final String subtitle;
  String chatPriority;
  String replyPriority;
  final String chatDesc;

  TierDetailsData({
    required this.id,
    required this.title,
    required this.active,
    required this.oneOnOneCall,
    required this.emergencyAdjustments,
    required this.customFeatures,
    required this.programs,
    required this.performanceStats,
    required this.chartData,
    required this.color,
    required this.icon,
    required this.subtitle,
    required this.chatPriority,
    required this.replyPriority,
    required this.chatDesc,
  });

  factory TierDetailsData.fromJson(Map<String, dynamic> json) {
    final String id = json['id']?.toString() ?? '';

    return TierDetailsData(
      id: id,
      title: json['title']?.toString() ?? '',
      active: json['active'] ?? false,
      oneOnOneCall: json['oneOnOneCall']?.toString() ?? 'NoCalls',
      emergencyAdjustments: json['emergencyAdjustments']?.toString() ?? 'None',
      customFeatures: List<String>.from(json['customFeatures'] ?? []),
      programs: (json['programs'] as List? ?? [])
          .map((e) => ProgramData.fromJson(e as Map<String, dynamic>))
          .toList(),
      performanceStats: PerformanceStatsData.fromJson(
        json['performanceStats'] ?? {},
      ),
      chartData: (json['chartData'] as List? ?? [])
          .map((e) => ChartDataPoint.fromJson(e))
          .toList(),
      // UI properties with defaults based on tier
      color: id == 'gold'
          ? const Color(0xFFFFD700)
          : id == 'silver'
          ? const Color(0xFFC0C0C0)
          : const Color(0xFFCD7F32),
      icon: id == 'gold'
          ? LucideIcons.crown
          : id == 'silver'
          ? LucideIcons.shield
          : LucideIcons.award,
      subtitle: id == 'gold'
          ? 'Premium coaching'
          : id == 'silver'
          ? 'Priority coaching'
          : 'Essential coaching',
      chatPriority: id == 'gold'
          ? 'High'
          : id == 'silver'
          ? 'Medium'
          : 'Standard',
      replyPriority: 'Standard',
      chatDesc: id == 'gold'
          ? 'Instant priority support'
          : id == 'silver'
          ? 'Priority response within 12 hours'
          : 'Standard response within 24 hours',
    );
  }
}

class PerformanceStatsData {
  final String activeClients;
  final String activeClientsTrend;
  final int growth;
  final String growthTrend;
  final String retention;
  final String retentionTrend;

  PerformanceStatsData({
    required this.activeClients,
    required this.activeClientsTrend,
    required this.growth,
    required this.growthTrend,
    required this.retention,
    required this.retentionTrend,
  });

  factory PerformanceStatsData.fromJson(Map<String, dynamic> json) {
    return PerformanceStatsData(
      activeClients: json['activeClients']?.toString() ?? '0',
      activeClientsTrend: json['activeClientsTrend']?.toString() ?? '0%',
      growth: (json['growth'] as num?)?.toInt() ?? 0,
      growthTrend: json['growthTrend']?.toString() ?? '0%',
      retention: json['retention']?.toString() ?? '0',
      retentionTrend: json['retentionTrend']?.toString() ?? '0%',
    );
  }
}

class ChartDataPoint {
  final String id;
  final String tickLabel;
  final String tooltipTitle;
  final double value;

  ChartDataPoint({
    required this.id,
    required this.tickLabel,
    required this.tooltipTitle,
    required this.value,
  });

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ChartDataPoint(
      id: json['id']?.toString() ?? '',
      tickLabel: json['tickLabel']?.toString() ?? '',
      tooltipTitle: json['tooltipTitle']?.toString() ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
