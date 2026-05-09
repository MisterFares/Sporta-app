import 'dart:io';
import 'package:fit/components/Authentication/another_panel.dart';
import 'package:fit/components/Widgets/snackbar.dart';
import 'package:fit/components/Widgets/textbutton.dart';
import 'package:fit/screens/trainee/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fit/styles/colors.dart';

class UploadImage extends StatefulWidget {
  final String fullname;
  final String email;
  final String password;
  final DateTime birthDate;
  final String gender;
  const UploadImage({
    super.key,
    required this.fullname,
    required this.email,
    required this.password,
    required this.birthDate,
    required this.gender,
  });

  @override
  State<UploadImage> createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isWeb = false;

  @override
  void initState() {
    super.initState();
    // Don't access context or Theme here
    // Just initialize variables if needed
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check platform here instead of initState
    _isWeb =
        Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.android;
    _isWeb = !_isWeb;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          snackBar(
            Icons.cancel_outlined,
            'Error picking image: $e',
            AppColors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose Profile Picture',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildOptionButton(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                    _buildOptionButton(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Icon(icon, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  void _continue() {
    if (_selectedImage != null) {
      // Here you can use _selectedImage to upload to your .NET backend
      print('Selected image path: ${_selectedImage!.path}');
      Navigator.pushReplacementNamed(context, '/next-screen');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        snackBar(
          Icons.warning_amber_outlined,
          'Please select an image first',
          Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: anotherPanel(
        context,
        "Upload Profile Picture",
        "Choose a photo that represents you. This will be visible to your coaches and teammates.",
        Icons.camera_alt_outlined,
        [
          const SizedBox(height: 32),

          // Profile Image Container
          GestureDetector(
            onTap: _showImageSourceDialog,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cardBackground,
                border: Border.all(color: AppColors.primary, width: 3),
                image: _selectedImage != null
                    ? DecorationImage(
                        image: FileImage(_selectedImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _selectedImage == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          color: Colors.grey[600],
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to add',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
          ),

          const SizedBox(height: 16),

          // Change photo button
          if (_selectedImage != null)
            TextButton(
              onPressed: _showImageSourceDialog,
              child: Text(
                'Change Photo',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          const SizedBox(height: 32),

          // Continue button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _continue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 16),
          textButton(14, AppColors.secondaryBtnText, 'Skip for now', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(
                  fullname: widget.fullname,
                  email: widget.email,
                  password: widget.password,
                  gender: widget.gender,
                  birthdate: widget.birthDate,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
