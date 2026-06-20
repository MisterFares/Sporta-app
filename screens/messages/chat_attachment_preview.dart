import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';
import 'dart:io' show File;
import 'dart:typed_data';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cross_file/cross_file.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ChatAttachmentPreview extends StatelessWidget {
  final List<XFile> attachments;
  final Function(int) onRemove;

  const ChatAttachmentPreview({
    super.key,
    required this.attachments,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: attachments.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final file = attachments[index];
          final fileName = file.name;
          final mimeType = _getMimeType(fileName);
          final isImage = mimeType.startsWith('image/');
          final isVideo = mimeType.startsWith('video/');
          final filePath = file.path;

          return Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  border: Border.all(color: AppColors.cardBorder),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: isImage
                      ? Image.file(
                          File(filePath),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 32,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : isVideo
                          ? _buildVideoThumbnail(filePath)
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    LucideIcons.fileText,
                                    size: 28,
                                    color: const Color(0xFF8b5cf6),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    fileName.split('.').last.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.cardTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => onRemove(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVideoThumbnail(String videoPath) {
    return FutureBuilder<Uint8List?>(
      future: VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 80,
        quality: 50,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Image.memory(
            snapshot.data!,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          );
        }
        return Container(
          color: Colors.black,
          child: const Center(
            child: Icon(
              LucideIcons.playCircle,
              size: 32,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  String _getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      case 'mkv':
        return 'video/x-matroska';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }
}