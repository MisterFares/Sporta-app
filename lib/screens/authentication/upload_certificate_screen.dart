import 'package:fit/components/Authentication/build_panel.dart';
import 'package:fit/components/Widgets/build_button.dart';
import 'package:fit/components/Widgets/snackbar.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:fit/components/Widgets/input.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class UploadCertificateScreen extends StatefulWidget {
  final String? selectedRole;

  const UploadCertificateScreen({super.key, this.selectedRole});

  @override
  State<UploadCertificateScreen> createState() =>
      _UploadCertificateScreenState();
}

class _UploadCertificateScreenState extends State<UploadCertificateScreen> {
  DateTime? selectedBirthdate;
  String? selectedGender;
  List<CertificateItem> certificates = [];

  @override
  void initState() {
    super.initState();
    certificates.add(CertificateItem());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          children: [
            Expanded(
              child: buildPanel(
                context,
                'Certificates & Specialization',
                'Show your qualifications and expertise to build trust with athletes and teammates.',
                [
                  buildInput(
                    'Specialization',
                    'e.g. Personal Trainer, Sports Nutritionist',
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Certificates',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...certificates.asMap().entries.map((entry) {
                    int index = entry.key;
                    CertificateItem certificate = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: CertificateUploadCard(
                        index: index,
                        certificate: certificate,
                        onRemove: certificates.length > 1
                            ? () {
                                setState(() {
                                  certificates.removeAt(index);
                                });
                              }
                            : null,
                        onImageSelected:
                            (Uint8List? imageBytes, String? imagePath) {
                              setState(() {
                                certificate.imageBytes = imageBytes;
                                certificate.imagePath = imagePath;
                              });
                            },
                        onUrlChanged: (String? url) {
                          setState(() {
                            certificate.certificateUrl = url;
                          });
                        },
                      ),
                    );
                  }).toList(),

                  buildButton('Add Another Certificate', Icon(Icons.add), () {
                    setState(() {
                      certificates.add(CertificateItem());
                    });
                  }, false),

                  const SizedBox(height: 20),
                  buildButton('Continue', null, () {
                    bool hasAnyCertificate = certificates.any(
                      (cert) =>
                          cert.imageBytes != null ||
                          (cert.certificateUrl != null &&
                              cert.certificateUrl!.isNotEmpty),
                    );
                    if (!hasAnyCertificate) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please upload at least one certificate or provide a URL',
                          ),
                        ),
                      );
                      return;
                    }
                    Navigator.pushNamed(context, '/upload-image');
                  }, true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CertificateItem {
  Uint8List? imageBytes;
  String? imagePath;
  String? certificateUrl;
  String? certificateName;

  CertificateItem({
    this.imageBytes,
    this.imagePath,
    this.certificateUrl,
    this.certificateName,
  });
}

class CertificateUploadCard extends StatefulWidget {
  final int index;
  final CertificateItem certificate;
  final VoidCallback? onRemove;
  final Function(Uint8List?, String?) onImageSelected;
  final Function(String?) onUrlChanged;

  const CertificateUploadCard({
    super.key,
    required this.index,
    required this.certificate,
    this.onRemove,
    required this.onImageSelected,
    required this.onUrlChanged,
  });

  @override
  State<CertificateUploadCard> createState() => _CertificateUploadCardState();
}

class _CertificateUploadCardState extends State<CertificateUploadCard> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.certificate.certificateUrl != null) {
      _urlController.text = widget.certificate.certificateUrl!;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 2000,
        maxHeight: 2000,
      );

      if (image != null) {
        if (Platform.isAndroid || Platform.isIOS) {
          // For mobile, use file path
          widget.onImageSelected(null, image.path);
          ScaffoldMessenger.of(context).showSnackBar(
            snackBar(
              Icons.check_circle_outline_outlined,
              'Certificate Uploaded Successfully!',
              AppColors.greeen,
            ),
          );
        } else {
          // For web, read as bytes
          final bytes = await image.readAsBytes();
          widget.onImageSelected(bytes, image.path);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        snackBar(
          Icons.cancel_outlined,
          'Error picking image: $e',
          AppColors.red,
        ),
      );
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeImage() {
    widget.onImageSelected(null, null);
  }

  @override
  Widget build(BuildContext context) {
    final hasImage =
        widget.certificate.imageBytes != null ||
        widget.certificate.imagePath != null;
    final hasUrl =
        widget.certificate.certificateUrl != null &&
        widget.certificate.certificateUrl!.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Certificate ${widget.index + 1}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (widget.onRemove != null)
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.red,
                  ),
                  onPressed: widget.onRemove,
                  tooltip: 'Remove Certificate',
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Upload Area
          GestureDetector(
            onTap: _showImagePickerOptions,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                border: Border.all(color: AppColors.cardBorder, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: hasImage
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: widget.certificate.imageBytes != null
                              ? Image.memory(
                                  widget.certificate.imageBytes!,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(widget.certificate.imagePath!),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                            ),
                            onPressed: _removeImage,
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Tap to change image',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.upload_file,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Upload Certificate Image',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'JPG or PNG',
                          style: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          // Optional: Show URL indicator if URL is provided and no image
          if (hasUrl && !hasImage)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.link, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'URL provided: ${widget.certificate.certificateUrl}',
                      style: TextStyle(fontSize: 12, color: AppColors.primary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          buildInput(
            'Certificate URL (Optional)',
            'https://example.com/certificate.pdf',
            onChanged: (value) {
              widget.onUrlChanged(value);
            },
          ),
        ],
      ),
    );
  }
}
