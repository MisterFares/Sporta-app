import 'dart:convert';
import 'package:fit/components/Authentication/build_panel.dart';
import 'package:fit/components/Widgets/build_button.dart';
import 'package:fit/components/Widgets/snackbar.dart';
import 'package:fit/screens/profile/profile_screen.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:fit/components/Widgets/input.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart' as dio_pack;

class UploadCertificateScreen extends StatefulWidget {
  final String fullname;
  final String email;
  final String password;
  final DateTime birthDate;
  final String gender;
  final String role;
  final double? height;
  final double? weight;
  final File? selectedImage;

  const UploadCertificateScreen({
    super.key,
    required this.fullname,
    required this.email,
    required this.password,
    required this.birthDate,
    required this.gender,
    required this.role,
    this.height,
    this.weight,
    this.selectedImage,
  });

  @override
  State<UploadCertificateScreen> createState() =>
      _UploadCertificateScreenState();
}

class _UploadCertificateScreenState extends State<UploadCertificateScreen> {
  final TextEditingController _specializationController =
      TextEditingController();
  List<CertificateItem> certificates = [];
  bool _isLoading = false;
  final String _baseUrl = "https://sporta.runasp.net";

  @override
  void initState() {
    super.initState();
    certificates.add(CertificateItem());
  }

  @override
  void dispose() {
    _specializationController.dispose();
    super.dispose();
  }

  // 🚀 الدالة الأسطورية بإستخدام Dio لحل مشكلة الـ Array مع الـ .NET
  Future<void> _handleTrainerRegister() async {
    if (_isLoading) return;

    List<CertificateItem> validCertificates = certificates
        .where((cert) => cert.imagePath != null)
        .toList();

    if (validCertificates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        snackBar(
          Icons.warning_amber_outlined,
          'Please upload at least one certificate image.',
          Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. تجهيز الـ Map الأساسية للـ FormData
      final Map<String, dynamic> formDataMap = {
        'FullName': widget.fullname,
        'Email': widget.email,
        'Password': widget.password,
        'ConfirmPassword': widget.password,
        'BirthDate': widget.birthDate.toIso8601String().split('T')[0],
        'Gender': (widget.gender.trim().toLowerCase() == 'male') ? '1' : '2',
        'Role': '2', // مدرب
        'Specialization': _specializationController.text.trim(),
      };

      if (widget.height != null) {
        formDataMap['Height'] = widget.height!.toInt().toString();
      }
      if (widget.weight != null) {
        formDataMap['Weight'] = widget.weight!.toInt().toString();
      }
      // 2. إضافة صورة البروفايل عبر Dio
      if (widget.selectedImage != null) {
        formDataMap['ProfileImage'] = await dio_pack.MultipartFile.fromFile(
          widget.selectedImage!.path,
          filename: widget.selectedImage!.path.split('/').last,
        );
      }

      // 3. 🚨 فرد لستة الشهادات بالصيغة اللي الـ .NET Model Binder بيعشقها تلقائياً جوه Dio
      for (int i = 0; i < validCertificates.length; i++) {
        final cert = validCertificates[i];

        // رفع ملف صورة الشهادة (مفاتيح مطابقة للـ Swagger)
        formDataMap['certificates[$i].file'] =
            await dio_pack.MultipartFile.fromFile(
              cert.imagePath!,
              filename: cert.imagePath!.split('/').last,
            );

        // رفع الرابط الاختياري للشهادة
        if (cert.certificateUrl != null &&
            cert.certificateUrl!.trim().isNotEmpty) {
          formDataMap['certificates[$i].verificationUrl'] = cert.certificateUrl!
              .trim();
        } else {
          formDataMap['certificates[$i].verificationUrl'] = '';
        }
      }

      // 4. إرسال الريكويست بـ Dio
      final dio = dio_pack.Dio();
      final response = await dio.post(
        '$_baseUrl/api/Auth/register',
        data: dio_pack.FormData.fromMap(formDataMap),
        options: dio_pack.Options(
          validateStatus: (status) =>
              true, // عشان نقفش الـ Error لو حصل من غير كراش للـ Try
        ),
      );

      if (response.statusCode == 200) {
        await _executeAutoLogin();
      } else {
        // طباعة المشكلة لو السيرفر لسه زعلان
        print("❌❌❌ DIO SERVER ERROR STATUS CODE: ${response.statusCode}");
        print("❌❌❌ DIO SERVER ERROR BODY: ${response.data}");

        String errorMessage = 'Registration failed';
        if (response.data is Map) {
          errorMessage =
              response.data['message'] ??
              response.data['errors']?.toString() ??
              response.data.toString();
        } else {
          errorMessage = response.data.toString();
        }

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            snackBar(Icons.error_outline, errorMessage, AppColors.red),
          );
        }
      }
    } catch (e) {
      print("🚨 DIO CATCH ERROR: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          snackBar(
            Icons.wifi_off_outlined,
            'Connection failed during processing.',
            AppColors.red,
          ),
        );
      }
    }
  }

  // دالة الـ Auto Login الأساسية (شغالة تمام بـ http ومفيش حاجة لتغييرها)
  Future<void> _executeAutoLogin() async {
    try {
      final loginUrl = Uri.parse('$_baseUrl/api/Auth/login');
      final response = await PlatformHttp().post(
        loginUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': widget.email, 'password': widget.password}),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final bool isSuccess = responseData['isSuccess'] ?? false;

      if (response.statusCode == 200 && isSuccess) {
        final String token = responseData['token'] ?? '';
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            snackBar(
              Icons.check_circle_outline,
              'Trainer account created successfully!',
              AppColors.greeen,
            ),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => ProfileScreen()),
            (route) => false,
          );
        }
      } else {
        _fallbackToLoginScreen(
          'Registration complete. Wait for Admin approval.',
        );
      }
    } catch (e) {
      _fallbackToLoginScreen(
        'Account created successfully! Proceeding to login.',
      );
    }
  }

  void _fallbackToLoginScreen(String message) {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        snackBar(Icons.warning_amber_outlined, message, Colors.orange),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
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
                'Show your qualifications and expertise to build trust with athletes.',
                [
                  buildInput(
                    'Specialization',
                    'e.g. Personal Trainer, Sports Nutritionist',
                    controller: _specializationController,
                  ),
                  const SizedBox(height: 20),
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
                        onImageSelected: (String? imagePath) {
                          setState(() {
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

                  buildButton(
                    'Add Another Certificate',
                    const Icon(Icons.add),
                    () {
                      setState(() {
                        certificates.add(CertificateItem());
                      });
                    },
                    false,
                  ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleTrainerRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _isLoading
                            ? 'Submitting Application...'
                            : 'Complete Signup & Create Account',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
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
  String? imagePath;
  String? certificateUrl;
  String? certificateName;

  CertificateItem({this.imagePath, this.certificateUrl, this.certificateName});
}

class CertificateUploadCard extends StatefulWidget {
  final int index;
  final CertificateItem certificate;
  final VoidCallback? onRemove;
  final Function(String?) onImageSelected;
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

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (image != null) {
        final File file = File(image.path);
        final int fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              snackBar(
                Icons.cancel_outlined,
                'Certificate image size exceeds 5MB limit.',
                AppColors.red,
              ),
            );
          }
          return;
        }

        widget.onImageSelected(image.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            snackBar(
              Icons.check_circle_outline,
              'Certificate Added Successfully!',
              AppColors.greeen,
            ),
          );
        }
      }
    } catch (e) {
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

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.textPrimary),
              title: Text(
                'Choose from Gallery',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.textPrimary),
              title: Text(
                'Take a Photo',
                style: TextStyle(color: AppColors.textPrimary),
              ),
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

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.certificate.imagePath != null;

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
                style: TextStyle(
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
          GestureDetector(
            onTap: _showImagePickerOptions,
            child: Container(
              height: 180,
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
                          child: Image.file(
                            File(widget.certificate.imagePath!),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.black.withOpacity(0.6),
                            child: IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: AppColors.textPrimary,
                              ),
                              onPressed: () => widget.onImageSelected(null),
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
                          size: 42,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Upload Certificate Image',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'JPG or PNG (Max 5MB)',
                          style: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          buildInput(
            'Certificate URL (Optional)',
            'https://example.com/certificate.pdf',
            controller: _urlController,
            onChanged: (value) {
              widget.onUrlChanged(value);
            },
          ),
        ],
      ),
    );
  }
}

// كلاس مساعد لتشغيل الـ Auto login القديم بدون تعارض أسامي ومكتبات
class PlatformHttp {
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return await http.post(url, headers: headers, body: body);
  }
}
