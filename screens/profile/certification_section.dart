import 'package:cached_network_image/cached_network_image.dart';
import 'package:fit/components/Widgets/textbutton.dart';
import 'package:fit/models/profile/certificate.dart';
import 'package:fit/screens/profile/base_sheet.dart';
import 'package:fit/screens/profile/default_sert_icon.dart';
import 'package:fit/screens/profile/outline_button.dart';
import 'package:fit/services/api_service.dart';
import 'package:fit/styles/colors.dart';
import 'package:fit/utils/image_url_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CertificationsSection extends StatefulWidget {
  final String coachId;
  final bool isOwner;

  const CertificationsSection({
    super.key,
    required this.coachId,
    required this.isOwner,
  });

  @override
  State<CertificationsSection> createState() => _CertificationsSectionState();
}

class _CertificationsSectionState extends State<CertificationsSection> {
  List<CoachCertificate> _certs = [];
  bool _isLoading = true;
  String? _errorMessage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final certificates = await ApiService.getCoachCertificates(
        coachId: widget.coachId,
      );
      setState(() {
        _certs = certificates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const visibleCount = 3;
    final visible = _certs.take(visibleCount).toList();
    final hasMore = _certs.length > visibleCount;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.cardBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Certifications',
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Professional qualifications & achievements',
                      style: GoogleFonts.inter(
                        color: AppColors.cardTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isOwner)
                outlineButton(
                  Icons.add,
                  'Add',
                  () => _showAddCertModal(context),
                ),
            ],
          ),
          SizedBox(height: 20),

          // loading state
          if (_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          // error state
          else if (_errorMessage != null)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red),
                    SizedBox(height: 8),
                    Text(
                      'Failed to load certifications',
                      style: GoogleFonts.inter(
                        color: AppColors.cardTextSecondary,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: _loadCertificates,
                      child: Text(
                        'Retry',
                        style: GoogleFonts.inter(
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          // empty state
          else if (_certs.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Text(
                      'No certifications yet',
                      style: GoogleFonts.inter(
                        color: AppColors.cardTextSecondary.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                    if (widget.isOwner) ...[
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _showAddCertModal(context),
                        child: Text(
                          'Add your first certification',
                          style: GoogleFonts.inter(
                            color: AppColors.primary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else ...[
            // grid 1 col (mobile)
            ...visible.map(
              (cert) => Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: _certificationCard(
                  cert: cert,
                  onTap: () => _showCertModal(context, cert),
                  isOwner: widget.isOwner,
                  onEdit: () => _showEditCertModal(context, cert),
                  onDelete: () => _showDeleteConfirmDialog(cert),
                ),
              ),
            ),

            if (hasMore) ...[
              SizedBox(height: 8),
              Center(
                child: GestureDetector(
                  onTap: () => _showAllCerts(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      border: Border.all(color: AppColors.cardBorder),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'Show all certifications',
                      style: GoogleFonts.inter(
                        color: AppColors.primary.withOpacity(0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _certificationCard({
    required CoachCertificate cert,
    required VoidCallback onTap,
    required bool isOwner,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    bool _imgError = false;
    final imageUrl = ImageUrlHelper.getFullImageUrl(cert.image);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    !_imgError && cert.image != null && cert.image!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.contain,
                        errorWidget: (_, __, ___) {
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => setState(() => _imgError = true),
                          );
                          return DefaultCertIcon();
                        },
                      )
                    : DefaultCertIcon(),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cert.title.isNotEmpty
                        ? cert.title
                        : 'Untitled Certification',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${cert.issuer.isNotEmpty ? cert.issuer : 'Unknown'}'
                    '${cert.date.isNotEmpty && cert.date != 'N/A' ? ' • ${cert.date}' : ''}',
                    style: GoogleFonts.inter(
                      color: AppColors.cardTextSecondary.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isOwner)
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: AppColors.cardTextSecondary,
                  size: 20,
                ),
                color: Color(0xFF0F1412),
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: AppColors.cardTextSecondary,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Edit',
                          style: TextStyle(color: AppColors.cardTextSecondary),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                          color: Colors.red,
                        ),
                        SizedBox(width: 10),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.cardTextSecondary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Future<File?> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  void _showAddCertModal(BuildContext ctx) {
    final titleController = TextEditingController();
    final issuerController = TextEditingController();
    final dateController = TextEditingController();
    final descriptionController = TextEditingController();
    final skillsController = TextEditingController();
    File? selectedImageFile;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SheetBase(
              draggable: true,
              maxHeight: 0.75,
              title: 'Add Certification',
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image picker button
                    GestureDetector(
                      onTap: () async {
                        final file = await _pickImage();
                        if (file != null) {
                          setModalState(() {
                            selectedImageFile = file;
                          });
                        }
                      },
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          border: Border.all(color: AppColors.cardBorder),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: selectedImageFile != null
                            ? Image.file(selectedImageFile!, fit: BoxFit.cover)
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.upload,
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Tap to upload image',
                                      style: TextStyle(
                                        color: AppColors.cardTextSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildTextField('Title', titleController),
                    SizedBox(height: 12),
                    _buildTextField('Issuer', issuerController),
                    SizedBox(height: 12),
                    _buildTextField('Date (Year)', dateController),
                    SizedBox(height: 12),
                    _buildTextField(
                      'Description',
                      descriptionController,
                      maxLines: 3,
                    ),
                    SizedBox(height: 12),
                    _buildTextField(
                      'Skills (comma separated)',
                      skillsController,
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: BorderSide(color: AppColors.cardBorder),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: Text('Cancel'),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              // Show loading
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) =>
                                    Center(child: CircularProgressIndicator()),
                              );

                              final skills = skillsController.text
                                  .split(',')
                                  .map((s) => s.trim())
                                  .where((s) => s.isNotEmpty)
                                  .toList();

                              Map<String, dynamic> result;
                              if (selectedImageFile != null) {
                                result = await ApiService.addCoachCertificate(
                                  title: titleController.text,
                                  issuer: issuerController.text,
                                  date: int.tryParse(dateController.text) ?? 0,
                                  imageFile: selectedImageFile,
                                  credentialUrl: '',
                                  skills: skills,
                                  description: descriptionController.text,
                                );
                              } else {
                                result = await ApiService.addCoachCertificate(
                                  title: titleController.text,
                                  issuer: issuerController.text,
                                  date: int.tryParse(dateController.text) ?? 0,
                                  credentialUrl: '',
                                  skills: skills,
                                  description: descriptionController.text,
                                );
                              }

                              if (!context.mounted) return;
                              Navigator.pop(context); // Close loading

                              if (result['success']) {
                                await _loadCertificates();
                                Navigator.pop(context); // Close modal
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Certification added!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result['message']),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: Text('Add'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditCertModal(BuildContext ctx, CoachCertificate cert) {
    final titleController = TextEditingController(text: cert.title);
    final issuerController = TextEditingController(text: cert.issuer);
    final dateController = TextEditingController(text: cert.date);
    final descriptionController = TextEditingController(text: cert.description);
    final skillsController = TextEditingController(
      text: cert.skills.join(', '),
    );
    File? selectedImageFile;
    String? imageUrl = cert.image;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SheetBase(
              draggable: true,
              maxHeight: 0.75,
              title: 'Edit Certification',
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image picker button
                    GestureDetector(
                      onTap: () async {
                        final file = await _pickImage();
                        if (file != null) {
                          setModalState(() {
                            selectedImageFile = file;
                            imageUrl = null;
                          });
                        }
                      },
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          border: Border.all(color: AppColors.cardBorder),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: selectedImageFile != null
                            ? Image.file(selectedImageFile!, fit: BoxFit.cover)
                            : imageUrl != null && imageUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: ImageUrlHelper.getFullImageUrl(
                                  imageUrl,
                                )!,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) =>
                                    Center(child: Icon(Icons.broken_image)),
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.upload,
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Tap to change image',
                                      style: TextStyle(
                                        color: AppColors.cardTextSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildTextField('Title', titleController),
                    SizedBox(height: 12),
                    _buildTextField('Issuer', issuerController),
                    SizedBox(height: 12),
                    _buildTextField('Date (Year)', dateController),
                    SizedBox(height: 12),
                    _buildTextField(
                      'Description',
                      descriptionController,
                      maxLines: 3,
                    ),
                    SizedBox(height: 12),
                    _buildTextField(
                      'Skills (comma separated)',
                      skillsController,
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: BorderSide(color: AppColors.cardBorder),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: Text('Cancel'),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) =>
                                    Center(child: CircularProgressIndicator()),
                              );

                              final skills = skillsController.text
                                  .split(',')
                                  .map((s) => s.trim())
                                  .where((s) => s.isNotEmpty)
                                  .toList();

                              Map<String, dynamic> result;
                              if (selectedImageFile != null) {
                                result =
                                    await ApiService.updateCoachCertificate(
                                      certificateId: cert.id,
                                      title: titleController.text,
                                      issuer: issuerController.text,
                                      date:
                                          int.tryParse(dateController.text) ??
                                          0,
                                      imageFile: selectedImageFile,
                                      credentialUrl: cert.credentialUrl,
                                      skills: skills,
                                      description: descriptionController.text,
                                    );
                              } else {
                                result =
                                    await ApiService.updateCoachCertificate(
                                      certificateId: cert.id,
                                      title: titleController.text,
                                      issuer: issuerController.text,
                                      date:
                                          int.tryParse(dateController.text) ??
                                          0,
                                      existingImageUrl: imageUrl,
                                      credentialUrl: cert.credentialUrl,
                                      skills: skills,
                                      description: descriptionController.text,
                                    );
                              }

                              if (!context.mounted) return;
                              Navigator.pop(context); // Close loading

                              if (result['success']) {
                                print(
                                  "🔍 CERTIFICATE ADDED: ${result['data']}",
                                );
                                print(
                                  "🔍 IMAGE URL FROM SERVER: ${result['data']['image']}",
                                );
                                await _loadCertificates();
                                Navigator.pop(context); // Close modal
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Certification updated!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result['message']),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(CoachCertificate cert) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Delete Certification',
          style: TextStyle(color: AppColors.red),
        ),
        content: Text(
          'Are you sure you want to delete "${cert.title}"?',
          style: TextStyle(color: AppColors.cardTextSecondary),
        ),
        actions: [
          textButton(
            14,
            AppColors.cardTextSecondary,
            'Cancel',
            () => Navigator.pop(ctx),
          ),
          textButton(14, AppColors.red, 'Delete', () async {
            Navigator.pop(ctx); // Close dialog

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Center(child: CircularProgressIndicator()),
            );

            final result = await ApiService.deleteCoachCertificate(
              certificateId: cert.id,
            );

            if (!context.mounted) return;
            Navigator.pop(context); // Close loading

            if (result['success']) {
              await _loadCertificates();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Certification deleted!'),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message']),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.cardTextSecondary,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _certDetailSheet({
    required CoachCertificate cert,
    required bool isOwner,
  }) {
    final imageUrl = ImageUrlHelper.getFullImageUrl(cert.image);

    return SheetBase(
      maxHeight: 0.65,
      draggable: true,
      title: cert.title.isNotEmpty ? cert.title : 'Certification',
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (cert.image != null && cert.image!.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl!,
                    height: 100,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) => DefaultCertIcon(),
                  ),
                ),
              ),
            SizedBox(height: 16),
            _info('Issuer', cert.issuer),
            SizedBox(height: 8),
            _info('Year', cert.date),
            SizedBox(height: 8),
            if (cert.description.isNotEmpty)
              _info('Description', cert.description),
            SizedBox(height: 12),
            if (cert.skills.isNotEmpty) ...[
              Text(
                'Skills',
                style: GoogleFonts.inter(
                  color: AppColors.cardTextSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: cert.skills
                    .map(
                      (s) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          s.toString(),
                          style: GoogleFonts.inter(
                            color: AppColors.primary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _allCertsSheet({required List<CoachCertificate> certs}) {
    return SheetBase(
      draggable: true,
      maxHeight: 0.65,
      title: 'All Certifications',
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: certs.length,
        shrinkWrap: true,
        itemBuilder: (ctx, i) => Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: _certificationCard(
            cert: certs[i],
            onTap: () => showModalBottomSheet(
              context: ctx,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (_) =>
                  _certDetailSheet(cert: certs[i], isOwner: widget.isOwner),
            ),
            isOwner: widget.isOwner,
            onEdit: () {
              Navigator.pop(ctx);
              _showEditCertModal(ctx, certs[i]);
            },
            onDelete: () {
              Navigator.pop(ctx);
              _showDeleteConfirmDialog(certs[i]);
            },
          ),
        ),
      ),
    );
  }

  Widget _info(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.inter(
          color: AppColors.cardTextSecondary,
          fontSize: 11,
        ),
      ),
      SizedBox(height: 2),
      Text(
        value,
        style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
      ),
    ],
  );

  void _showCertModal(BuildContext ctx, CoachCertificate cert) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _certDetailSheet(cert: cert, isOwner: widget.isOwner),
    );
  }

  void _showAllCerts(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _allCertsSheet(certs: _certs),
    );
  }
}
