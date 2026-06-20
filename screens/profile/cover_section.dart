import 'package:cached_network_image/cached_network_image.dart';
import 'package:fit/components/Widgets/textbutton.dart';
import 'package:fit/screens/profile/default_cover.dart';
import 'package:fit/services/api_service.dart'; // Add this import
import 'package:fit/styles/colors.dart';
import 'package:fit/utils/image_url_helper.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CoverSection extends StatefulWidget {
  final String? cover;
  final bool isOwner;
  final Function(String?) onCoverChanged; // Callback when cover changes

  const CoverSection({
    super.key,
    this.cover,
    required this.isOwner,
    required this.onCoverChanged,
  });

  @override
  State<CoverSection> createState() => _CoverSectionState();
}

class _CoverSectionState extends State<CoverSection> {
  bool _error = false;
  final ImagePicker _picker = ImagePicker();

  // Get the current cover to display (use ImageUrlHelper to get full URL)
  String? get _displayCover {
    final coverUrl = widget.cover;
    if (coverUrl == null || coverUrl.isEmpty) return null;
    return ImageUrlHelper.getFullImageUrl(coverUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 160,
          width: double.infinity,
          child: _displayCover != null && _displayCover!.isNotEmpty && !_error
              ? _buildCoverImage(_displayCover!)
              : const DefaultCover(),
        ),
        // gradient overlay bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.cardBackground.withOpacity(0.8),
                ],
              ),
            ),
          ),
        ),
        // Edit button (only for owner)
        if (widget.isOwner)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: PopupMenuButton<String>(
                icon:  Icon(
                  Icons.edit_outlined,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
                color: const Color(0xFF0F1412),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side:  BorderSide(color: AppColors.cardBorder),
                ),
                onSelected: (value) {
                  if (value == 'upload') {
                    _pickCoverImage();
                  } else if (value == 'delete') {
                    _deleteCover();
                  }
                },
                itemBuilder: (context) => [
                   PopupMenuItem(
                    value: 'upload',
                    child: Row(
                      children: [
                        Icon(
                          Icons.upload_rounded,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Upload Cover',
                          style: TextStyle(color: AppColors.cardTextSecondary),
                        ),
                      ],
                    ),
                  ),
                  // Only show delete option if there is a cover
                  if (widget.cover != null && widget.cover!.isNotEmpty)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 20,
                            color: Colors.red,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Delete Cover',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCoverImage(String path) {
    // Check if it's a network image (http/https) or local file
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        width: double.infinity,
        httpHeaders: const {
          'X-Tunnel-Skip-AntiPhishing-Page': 'true', // Add tunnel header
        },
        errorWidget: (_, __, ___) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => setState(() => _error = true),
          );
          return const DefaultCover();
        },
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => setState(() => _error = true),
          );
          return const DefaultCover();
        },
      );
    }
  }

  Future<void> _pickCoverImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) return;
      
      final File imageFile = File(image.path);
      
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      // Upload to server
      final result = await ApiService.uploadCoverImage(imageFile);
      
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading
      
      if (result['success']) {
        // Notify parent with the new cover URL from server
        widget.onCoverChanged(result['imageUrl']);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cover image updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error picking cover image: $e');
      if (context.mounted) {
        Navigator.pop(context); // Close loading if still showing
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error uploading cover image'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteCover() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title:  Text(
          'Delete Cover',
          style: TextStyle(color: AppColors.red),
        ),
        content:  Text(
          'Are you sure you want to remove your cover image?',
          style: TextStyle(color: AppColors.cardTextSecondary),
        ),
        actions: [
          textButton(14, AppColors.textPrimary, 'Cancel', () => Navigator.pop(ctx)),
          textButton(14, AppColors.red, 'Delete', () async {
            Navigator.pop(ctx); // Close dialog
            
            // Show loading indicator
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(
                child: CircularProgressIndicator(),
              ),
            );
            
            try {
              // Call API to delete cover image
              final result = await ApiService.deleteCoverImage();
              
              if (!context.mounted) return;
              Navigator.pop(context); // Close loading
              
              if (result['success']) {
                // Notify parent that cover is deleted (pass null to use default)
                widget.onCoverChanged(null);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cover image deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message']),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            } catch (e) {
              if (context.mounted) {
                Navigator.pop(context); // Close loading
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }),
        ],
      ),
    );
  }
}