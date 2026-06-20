import 'dart:convert';
import 'dart:io';
import 'package:fit/screens/authentication/login_screen.dart';
import 'package:fit/screens/authentication/upload_certificate_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fit/styles/colors.dart';
import 'package:fit/components/Authentication/another_panel.dart';
import 'package:fit/components/Widgets/snackbar.dart';

class SelectPlanScreen extends StatefulWidget {
  final String fullname;
  final String email;
  final String password;
  final DateTime birthDate;
  final String gender;
  final double? height;
  final double? weight;
  final File? selectedImage; 

  const SelectPlanScreen({
    super.key,
    required this.fullname,
    required this.email,
    required this.password,
    required this.birthDate,
    required this.gender,
    this.height,
    this.weight,
    this.selectedImage,
  });

  @override
  State<SelectPlanScreen> createState() => _SelectPlanScreenState();
}

class _SelectPlanScreenState extends State<SelectPlanScreen> {
  String _selectedRole = 'Trainee'; 
  bool _isLoading = false;
  final String _baseUrl = "https://sporta.runasp.net";

  // 🚀 معالجة الضغط على الزرار الرئيسي والتفريع بناءً على الـ Role
  Future<void> _handleNextStep() async {
    if (_isLoading) return;

    if (_selectedRole == 'Trainer') {
      // 🔀 إذا كان كوتش: نقله فوراً لشاشة رفع الشهادات مع تمرير كل الداتا السابقة والصورة الشخصية
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UploadCertificateScreen(
            fullname: widget.fullname,
            email: widget.email,
            password: widget.password,
            birthDate: widget.birthDate,
            gender: widget.gender,
            role: _selectedRole,
            height: widget.height,
            weight: widget.weight,
            selectedImage: widget.selectedImage,
          ),
        ),
      );
    } else {
      // 🔐 إذا كان متدرب (Trainee): تنفيذ عملية التسجيل المباشرة هنا
      await _registerAsTrainee();
    }
  }

  // 📥 دالة خاصة لتسجيل الـ Trainee مباشرة من الشاشة دي
  Future<void> _registerAsTrainee() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final registerUrl = Uri.parse('$_baseUrl/api/Auth/register');
      final request = http.MultipartRequest('POST', registerUrl);

      request.fields['FullName'] = widget.fullname;
      request.fields['Email'] = widget.email;
      request.fields['Password'] = widget.password;
      request.fields['ConfirmPassword'] = widget.password;
      request.fields['BirthDate'] = widget.birthDate.toIso8601String().split('T')[0];
      request.fields['Gender'] = widget.gender;
      request.fields['Role'] = _selectedRole; 

      if (widget.height != null) request.fields['Height'] = widget.height.toString();
      if (widget.weight != null) request.fields['Weight'] = widget.weight.toString();

      if (widget.selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('ProfileImage', widget.selectedImage!.path),
        );
      }

      print('📡 Submitting Trainee request to: $registerUrl');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        await _executeAutoLogin();
      } else {
        String errorMessage = 'Registration failed';
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (_) {}

        if (mounted) {
          setState(() { _isLoading = false; });
          ScaffoldMessenger.of(context).showSnackBar(snackBar(Icons.error_outline, errorMessage, AppColors.red));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          snackBar(Icons.wifi_off_outlined, 'Connection failed during registration.', AppColors.red),
        );
      }
    }
  }

  Future<void> _executeAutoLogin() async {
    try {
      final loginUrl = Uri.parse('$_baseUrl/api/Auth/login');
      final response = await http.post(
        loginUrl,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': widget.email, 'password': widget.password}),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final bool isSuccess = responseData['isSuccess'] ?? false;

      if (response.statusCode == 200 && isSuccess) {
        final String token = responseData['token'] ?? '';
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        if (mounted) {
          setState(() { _isLoading = false; });
          ScaffoldMessenger.of(context).showSnackBar(
            snackBar(Icons.check_circle_outline, 'Registration successful!', AppColors.greeen),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => LoginScreen(

              ),
            ),
            (route) => false,
          );
        }
      } else {
        _fallbackToLoginScreen('Account created. Please log in manually.');
      }
    } catch (e) {
      _fallbackToLoginScreen('Account created successfully! Proceed to login.');
    }
  }

  void _fallbackToLoginScreen(String message) {
    if (mounted) {
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(snackBar(Icons.warning_amber_outlined, message, Colors.orange));
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: anotherPanel(
        context,
        "Select Your Plan",
        "Choose whether you want to join SPORTA as an athlete looking for guidance or a professional coach.",
        Icons.person_pin_outlined,
        [
          const SizedBox(height: 32),
          _buildRoleCard(
            title: "Join as Trainee",
            description: "Access customized workouts, track your fitness matrix, and communicate with top coaches.",
            roleValue: "Trainee",
            icon: Icons.fitness_center,
          ),
          const SizedBox(height: 16),
          _buildRoleCard(
            title: "Join as Trainer",
            description: "Create premium programs, manage clients, and expand your professional fitness business.",
            roleValue: "Trainer",
            icon: Icons.sports,
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleNextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _isLoading
                    ? 'Processing Registration...'
                    : (_selectedRole == 'Trainer' ? 'Continue as Trainer' : 'Continue as Trainee'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String description,
    required String roleValue,
    required IconData icon,
  }) {
    final bool isSelected = _selectedRole == roleValue;
    return GestureDetector(
      onTap: _isLoading ? null : () => setState(() => _selectedRole = roleValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 2.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : Colors.grey, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(description, style: TextStyle(color: Colors.grey[400], fontSize: 13, height: 1.4)),
                ],
              ),
            ),
            Radio<String>(
              value: roleValue,
              groupValue: _selectedRole,
              activeColor: AppColors.primary,
              onChanged: _isLoading ? null : (value) { if (value != null) setState(() => _selectedRole = value); },
            ),
          ],
        ),
      ),
    );
  }
}