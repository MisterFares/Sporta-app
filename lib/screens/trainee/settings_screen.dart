import 'package:fit/components/Settings/build_preference_settings.dart';
import 'package:fit/components/Settings/build_text_field.dart';
import 'package:fit/components/Widgets/build_button.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings toggles

  final TextEditingController _nameController = TextEditingController(
    text: 'John Doe',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'john@sporta.com',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: '••••••••',
  );
  final TextEditingController _confirmPasswordController =
      TextEditingController(text: '••••••••');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).size.width <= 1024 ? 100 : 48,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Settings Header
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.cardBorder),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.arrow_back_outlined,
                              size: 20,
                              color: Colors.white,
                            ),
                            style: IconButton.styleFrom(
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Account Section
                    const Text(
                      'ACCOUNT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cardTextSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAccountSettings(),

                    const SizedBox(height: 40),

                    // Preferences Section
                    const Text(
                      'PREFERENCES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cardTextSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    BuildPreferenceSettings(),

                    const SizedBox(height: 40),

                    // Privacy Section
                    const Text(
                      'PRIVACY & SECURITY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cardTextSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 40),
                    // Danger Zone
                    const Text(
                      'DANGER ZONE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.red,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDangerZone(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          buildTextField('Full Name', _nameController),
          const SizedBox(height: 20),
          buildTextField('Email Address', _emailController),
          const SizedBox(height: 20),
          Container(height: 1, color: AppColors.cardBorder),
          const SizedBox(height: 20),
          buildTextField('New Password', _passwordController, isPassword: true),
          const SizedBox(height: 20),
          buildTextField(
            'Confirm Password',
            _confirmPasswordController,
            isPassword: true,
          ),
          const SizedBox(height: 20),
          buildButton('Update', null, () {}, true),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.red.withOpacity(0.05),
        border: Border.all(color: AppColors.red.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delete Account',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.red,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Once you delete your account, there is no going back. Please be certain.',
            style: TextStyle(fontSize: 12, color: AppColors.cardTextSecondary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.red,
                backgroundColor: AppColors.red.withOpacity(0.1),
                side: const BorderSide(color: AppColors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Delete Account',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
