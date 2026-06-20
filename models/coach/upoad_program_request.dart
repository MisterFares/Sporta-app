import 'dart:io';

class UploadProgramRequest {
  final String subscriptionId;
  final String programName;
  final String programCategory;
  final DateTime startDate;
  final DateTime endDate;
  final File file;
  final File coverImage;
  final String? coachPrivateNote;

  UploadProgramRequest({
    required this.subscriptionId,
    required this.programName,
    required this.programCategory,
    required this.startDate,
    required this.endDate,
    required this.file,
    required this.coverImage,
    this.coachPrivateNote,
  });
}