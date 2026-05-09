import 'package:fit/components/Authentication/build_panel.dart';
import 'package:fit/components/Widgets/build_button.dart';
import 'package:fit/screens/authentication/birthdate_picker.dart';
import 'package:fit/screens/authentication/upload_image.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:fit/components/Widgets/input.dart';

class SignupScreen2 extends StatefulWidget {
  final String selectedRole;
  final String fullname;
  final String email;
  final String password;

  const SignupScreen2({
    super.key,
    required this.selectedRole,
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
                  BirthdatePicker(
                    onDateSelected: (date) {
                      setState(() {
                        selectedBirthdate = date;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Gender',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.1,
                    children: [
                      _buildGenderSelection(Icons.male, 'Male'),
                      _buildGenderSelection(Icons.female, 'Female'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: AppColors.cardBorder, height: 24),
                  const Text(
                    'Optional Information',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  buildInput(null, 'Height (cm)'),
                  const SizedBox(height: 10),
                  buildInput(null, 'Weight (kg)'),
                  const SizedBox(height: 20),
                  buildButton('Continue', null, () {
                    if (selectedBirthdate != null && selectedGender != null) {
                      if (widget.selectedRole == 'trainee') {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => UploadImage(fullname: widget.fullname, email: widget.email, password: widget.password, birthDate: selectedBirthdate!, gender: selectedGender!,)));
                      } else {
                        Navigator.pushNamed(context, '/upload-certificate');
                      }
                    }
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
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
