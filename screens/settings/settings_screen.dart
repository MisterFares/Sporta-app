import 'package:fit/screens/settings/build_preference_settings.dart';
import 'package:fit/screens/settings/build_text_field.dart';
import 'package:fit/components/Widgets/app_bar.dart';
import 'package:fit/components/Widgets/build_button.dart';
import 'package:fit/components/Widgets/drawer.dart';
import 'package:fit/screens/authentication/login_screen.dart';
import 'package:fit/services/api_service.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 👈 ضفنا مكتبة الـ SharedPreferences

class SettingsScreen extends StatefulWidget {
  final String? role;
  const SettingsScreen({super.key, this.role});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings toggles

  final TextEditingController _passwordController = TextEditingController(
    text: '••••••••',
  );
  final TextEditingController _confirmPasswordController =
      TextEditingController(text: '••••••••');

  // 🚪 دالة تسجيل الخروج ومسح التوكن
  Future<void> _handleLogout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // 1️⃣ مسح الـ Auth Token تماماً من ذاكرة الجهاز
    await prefs.remove('auth_token');

    if (mounted) {
      // 2️⃣ الانتقال لشاشة الـ Login ومسح كل الشاشات السابقة من الـ Stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false, // 👈 دي بتضمن إن الـ Back button ميرجعوش هنا تاني
      );
    }
  }

  Future<void> _handleDeleteAccount() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Delete Account',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone. All your data will be permanently removed.',
          style: TextStyle(color: AppColors.cardTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );

    try {
      final result = await ApiService.deleteAccount();

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading

      if (result['success']) {
        // Navigate to login screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account deleted successfully'),
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
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(drawerIcon: Icons.menu, title: 'Settings'),
      drawer: AppDrawer(selectedIndex: 8, role: 'trainee'),
      body: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: 40,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Account Section
                    Text(
                      'ACCOUNT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cardTextSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildAccountSettings(),

                    SizedBox(height: 20),

                    // Preferences Section
                    Text(
                      'PREFERENCES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cardTextSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 16),
                    BuildPreferenceSettings(),

                    SizedBox(height: 20),

                    // Privacy Section
                    Text(
                      'PRIVACY & SECURITY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cardTextSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),

                    SizedBox(height: 20),
                    // Danger Zone
                    Text(
                      'DANGER ZONE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.red,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed:
                            _handleLogout, // 👈 استدعاء دالة الخروج هنا عند الضغط
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.red,
                          backgroundColor: AppColors.red.withOpacity(0.1),
                          side: BorderSide(color: AppColors.red),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Log out from Sporta', // 👈 تم تعديل النص ليكون معبراً عن الأكشن
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
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
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(height: 20),
          buildTextField('New Password', _passwordController, isPassword: true),
          SizedBox(height: 20),
          buildTextField(
            'Confirm Password',
            _confirmPasswordController,
            isPassword: true,
          ),
          SizedBox(height: 20),
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
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delete Account',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.red,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your Account will be deleted permenantly',
            style: TextStyle(fontSize: 12, color: AppColors.cardTextSecondary),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _handleDeleteAccount, // 👈 استدعاء دالة الخروج هنا عند الضغط
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.red,
                backgroundColor: AppColors.red.withOpacity(0.1),
                side: BorderSide(color: AppColors.red),
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Delete Account', // 👈 تم تعديل النص ليكون معبراً عن الأكشن
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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
