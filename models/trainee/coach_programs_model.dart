// coach_programs_model.dart
import 'package:fit/utils/image_url_helper.dart';

class CoachProgramsResponse {
  final bool isSuccess;
  final String message;
  final CoachProgramsData data;
  final dynamic errors;

  CoachProgramsResponse({
    required this.isSuccess,
    required this.message,
    required this.data,
    this.errors,
  });

  factory CoachProgramsResponse.fromJson(Map<String, dynamic> json) {
    return CoachProgramsResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      data: CoachProgramsData.fromJson(json['data'] ?? {}),
      errors: json['errors'],
    );
  }
}

class CoachProgramsData {
  final List<AvailablePeriod> availablePeriods;
  final List<ProgramFile> files;

  CoachProgramsData({required this.availablePeriods, required this.files});

  factory CoachProgramsData.fromJson(Map<String, dynamic> json) {
    final availablePeriods = (json['availablePeriods'] as List? ?? [])
        .map((e) => AvailablePeriod.fromJson(e))
        .toList();

    // Build the map
    final labelToSubscriptionId = <String, String>{};
    for (var period in availablePeriods) {
      labelToSubscriptionId[period.label] = period.subscriptionId;
    }

    print("🔍 DEBUG - labelToSubscriptionId: $labelToSubscriptionId");

    return CoachProgramsData(
      availablePeriods: availablePeriods,
      files: (json['files'] as List? ?? [])
          .map(
            (e) => ProgramFile.fromJson(
              e,
              labelToSubscriptionId: labelToSubscriptionId,
            ),
          )
          .toList(),
    );
  }
}

class AvailablePeriod {
  final String subscriptionId;
  final String label;

  AvailablePeriod({required this.subscriptionId, required this.label});

  factory AvailablePeriod.fromJson(Map<String, dynamic> json) {
    return AvailablePeriod(
      subscriptionId: json['subscriptionId']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }
}

class ProgramFile {
  final int id;
  final String fileId;
  final String subscriptionId;
  final String title;
  final String trainerName;
  final String routeType;
  final String duration;
  final String uploadType;
  final String uploadDate;
  final String startDate;
  final String endDate;
  final String thumbnail;
  final String fileUrl;
  final bool completed;
  final bool hasNutritionAccess;
  final bool canDownload;
  final String coachNote;
  final String dropdownLabel;

  ProgramFile({
    required this.id,
    required this.fileId,
    required this.subscriptionId,
    required this.title,
    required this.trainerName,
    required this.routeType,
    required this.duration,
    required this.uploadType,
    required this.uploadDate,
    required this.startDate,
    required this.endDate,
    required this.thumbnail,
    required this.fileUrl,
    required this.completed,
    required this.hasNutritionAccess,
    required this.canDownload,
    required this.coachNote,
    required this.dropdownLabel,
  });

  factory ProgramFile.fromJson(
    Map<String, dynamic> json, {
    Map<String, String>? labelToSubscriptionId,
  }) {
    final dropdownLabel = json['dropdownLabel']?.toString() ?? '';
    String subscriptionId = '';

    // Try to find subscriptionId from the map
    if (labelToSubscriptionId != null) {
      // Try exact match
      if (labelToSubscriptionId.containsKey(dropdownLabel)) {
        subscriptionId = labelToSubscriptionId[dropdownLabel]!;
      } else {
        // Try to find by partial match (if dropdownLabel contains the label)
        for (var entry in labelToSubscriptionId.entries) {
          if (dropdownLabel.contains(entry.key) ||
              entry.key.contains(dropdownLabel)) {
            subscriptionId = entry.value;
            break;
          }
        }
      }
    }

    print("🔍 DEBUG - dropdownLabel: $dropdownLabel");
    print("🔍 DEBUG - subscriptionId found: $subscriptionId");

    return ProgramFile(
      id: json['id'] as int? ?? 0,
      fileId: json['fileId']?.toString() ?? '',
      subscriptionId: subscriptionId,
      title: json['title']?.toString() ?? '',
      trainerName: json['trainerName']?.toString() ?? '',
      routeType: json['routeType']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      uploadType: json['uploadType']?.toString() ?? '',
      uploadDate: json['uploadDate']?.toString() ?? '',
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
      thumbnail:
          ImageUrlHelper.getFullImageUrl(json['thumbnail']?.toString()) ?? '',
      fileUrl: json['fileUrl']?.toString() ?? '',
      completed: json['completed'] ?? false,
      hasNutritionAccess: json['hasNutritionAccess'] ?? false,
      canDownload: json['canDownload'] ?? false,
      coachNote: json['coachNote']?.toString() ?? '',
      dropdownLabel: dropdownLabel,
    );
  }
}
