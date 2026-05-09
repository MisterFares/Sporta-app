import 'package:fit/components/Widgets/build_icon.dart';
import 'package:fit/components/Widgets/build_button.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

class PasswordUpdatedScreen extends StatelessWidget {
  const PasswordUpdatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -1),
            radius: 1.2,
            colors: [Color(0xFF1A201E), Color(0xFF0B0F0E)],
          ),
        ),
        child: Center(
          child: Container(
            width: 360,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 40,
                  offset: Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildIcon(Icons.check_circle_outlined),
                const SizedBox(height: 32),
                const Text(
                  "Password Updated!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Your password has been successfully updated.\n"
                  "Your account is secure and ready for action.\n",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.cardTextSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                buildButton('Go to Login', null, () {
                  Navigator.pushNamed(context, '/login');
                }, false),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
