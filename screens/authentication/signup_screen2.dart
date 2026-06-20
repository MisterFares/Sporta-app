import 'package:fit/components/Authentication/build_panel.dart';
import 'package:fit/components/Widgets/build_button.dart';
import 'package:fit/components/Widgets/snackbar.dart';
import 'package:fit/screens/authentication/birthdate_picker.dart';
import 'package:fit/screens/authentication/upload_image.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:fit/components/Widgets/input.dart';

class SignupScreen2 extends StatefulWidget {
  final String fullname;
  final String email;
  final String password;

  const SignupScreen2({
    super.key,
    required this.fullname,
    required this.email,
    required this.password,
  });

  @override
  State<SignupScreen2> createState() => _SignupScreen2State();
}

class _SignupScreen2State extends State<SignupScreen2> {
  DateTime? selectedBirthdate;
  String? selectedGender;
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    // 1. التحقق من تاريخ الميلاد
    if (selectedBirthdate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        snackBar(
          Icons.cancel_outlined,
          'Please select your birthdate',
          AppColors.red,
        ),
      );
      return;
    }

    // 2. التحقق من اختيار الجنس
    if (selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        snackBar(
          Icons.cancel_outlined,
          'Please select your gender',
          AppColors.red,
        ),
      );
      return;
    }

    // 3. معالجة الطول والوزن بدقة تحويلية آمنة
    double? height;
    double? weight;

    if (_heightController.text.isNotEmpty) {
      height = double.tryParse(_heightController.text);
      if (height == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          snackBar(
            Icons.cancel_outlined,
            'Please enter a valid height number',
            AppColors.red,
          ),
        );
        return;
      }
    }

    if (_weightController.text.isNotEmpty) {
      weight = double.tryParse(_weightController.text);
      if (weight == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          snackBar(
            Icons.cancel_outlined,
            'Please enter a valid weight number',
            AppColors.red,
          ),
        );
        return;
      }
    }

    // 4. الانتقال وتمرير كافة البيانات المستقاة من الخطوة 1 والخطوة 2 إلى شاشة الخطة والتسجيل النهائي
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UploadImage(
          fullname: widget.fullname,
          email: widget.email,
          password: widget.password,
          birthDate: selectedBirthdate!,
          gender: selectedGender!,
          height: height,
          weight: weight,
        ),
      ),
    );
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
                null,
                'Tell us more about yourself to personalize your experience.',
                [
                  // دالة اختيار تاريخ الميلاد
                  BirthdatePicker(
                    onDateSelected: (date) {
                      setState(() {
                        selectedBirthdate = date;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Gender',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // شبكة اختيار الجنس (Male / Female)
                  Row(
                    children: [
                      Expanded(
                        child: _buildGenderSelection(Icons.male, 'Male'),
                      ),
                      const SizedBox(width: 8,),
                      Expanded(
                        child: _buildGenderSelection(Icons.female, 'Female'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(color: AppColors.cardBorder, height: 24),

                  Text(
                    'Optional Information',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  buildInput(
                    null,
                    'Height (cm)',
                    controller: _heightController,
                  ),
                  const SizedBox(height: 10),
                  buildInput(
                    null,
                    'Weight (kg)',
                    controller: _weightController,
                  ),
                  const SizedBox(height: 20),

                  // ✅ التعديل الأمني هنا: تغليف الدالة بأقواس صريحة {} لضمان الـ VoidCallback 100%
                  buildButton('Continue', null, () {
                    _handleContinue();
                  }, true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelection(IconData icon, String text) {
    final isSelected = selectedGender == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.05)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 2.0 : 1.0,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.cardTextSecondary,
              ),
              Text(
                text,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
