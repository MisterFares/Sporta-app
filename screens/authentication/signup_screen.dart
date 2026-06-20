import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fit/components/Authentication/build_panel.dart';
import 'package:fit/components/Widgets/build_button.dart';
import 'package:fit/components/Widgets/snackbar.dart';
import 'package:fit/components/Widgets/textbutton.dart';
import 'package:fit/screens/authentication/verify_email_screen.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:fit/components/Widgets/input.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_isLoading) return;

    String fullName = _fullNameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // فحص المدخلات محلياً
    if (fullName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar(Icons.cancel_outlined, 'Please fill in all fields', AppColors.red));
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar(Icons.cancel_outlined, 'Please enter a valid email address', AppColors.red));
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar(Icons.cancel_outlined, 'Password must be at least 6 characters', AppColors.red));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar(Icons.cancel_outlined, 'Passwords do not match', AppColors.red));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      const String baseUrl = "https://sporta.runasp.net";
      // 🚀 الخطوة 1: الـ Endpoint الجديد لطلب الـ OTP
      final url = Uri.parse('$baseUrl/api/Auth/request-register-otp'); 

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        // 📝 الـ Body المطلوب في التوثيق
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final bool isSuccess = responseData['isSuccess'] ?? false;
      final String message = responseData['message'] ?? 'An error occurred';

      if (response.statusCode == 200 && isSuccess) {
        // 💾 حفظ البيانات مؤقتاً في الـ Local Storage لحين التسجيل النهائي في خطوة 3
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('temp_fullname', fullName);
        await prefs.setString('temp_email', email);
        await prefs.setString('temp_password', password);

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          // الانتقال لشاشة الـ OTP وتمرير البيانات للـ State الخاصة بها أيضاً
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VerifyEmailScreen(
                fullname: fullName,
                email: email,
                password: password,
                isForgotPassword: false,
              ),
            ),
          );
        }
      } else {
        // 🛑 لو رجع 400 أو أي إيرور (الإيميل متسجل مسبقاً) طلع Alert
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(snackBar(Icons.error_outline, message, AppColors.red));
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          snackBar(Icons.wifi_off_outlined, 'Connection failed. Ensure backend is running.', AppColors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: Row(
          children: [
            Expanded(
              child: buildPanel(
                context,
                'Create Your Account',
                'Join Our Team to proceed',
                [
                  buildInput("Full Name", "John Doe", controller: _fullNameController),
                  const SizedBox(height: 25),
                  buildInput("Email Address", "you@elite-athlete.com", controller: _emailController),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: (width * 0.9 > 900 ? 900 : width * 0.9) * 0.5 - 35,
                        child: buildInput(
                          "Password", "••••••••",
                          obscure: _obscurePassword,
                          controller: _passwordController,
                          showSuffixIcon: true,
                          suffixIcon: _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          onSuffixIconPressed: () {
                            setState(() { _obscurePassword = !_obscurePassword; });
                          },
                        ),
                      ),
                      SizedBox(
                        width: (width * 0.9 > 900 ? 900 : width * 0.9) * 0.5 - 35,
                        child: buildInput(
                          "Confirm Password", "••••••••",
                          obscure: _obscureConfirmPassword,
                          controller: _confirmPasswordController,
                          showSuffixIcon: true,
                          suffixIcon: _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                          onSuffixIconPressed: () {
                            setState(() { _obscureConfirmPassword = !_obscureConfirmPassword; });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('By creating an account, you agree to our ', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      textButton(12, AppColors.textPrimary, 'Terms of Services.', () {}),
                    ],
                  ),
                  const SizedBox(height: 10),
                  buildButton(
                    _isLoading ? 'Sending OTP...' : 'Create Account',
                    null,
                    () { _handleSignup(); },
                    !_isLoading,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                      textButton(14, AppColors.textPrimary, 'Log In', () {
                        Navigator.pushNamed(context, '/login');
                      }),
                    ],
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