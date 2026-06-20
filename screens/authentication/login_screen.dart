import 'dart:convert';
import 'package:fit/screens/authentication/forgot_password.dart';
import 'package:fit/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // 💡 1. The official package import
import 'package:fit/components/Authentication/build_panel.dart';
import 'package:fit/components/Widgets/build_button.dart';
import 'package:fit/components/Widgets/snackbar.dart';
import 'package:fit/components/Widgets/textbutton.dart';
import 'package:fit/styles/colors.dart';
import 'package:fit/components/Widgets/input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  // Your Dev Tunnel Base URL

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        snackBar(
          Icons.cancel_outlined,
          'Please fill in all fields',
          AppColors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('https://sporta.runasp.net/api/Auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print("--- [DEBUG] Status: ${response.statusCode} ---");
      print("--- [DEBUG] Body: ${response.body} ---");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // التوكن مستخبي جوه الـ 'data'
        final dynamic data = responseData['data'];

        // استخراج التوكن بأي اسم محتمل
        final String? token = (data is Map)
            ? (data['token'] ??
                  data['Token'] ??
                  data['accessToken'] ??
                  data['access_token'])
            : null;

        if (token != null) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          print("--- [SUCCESS] Token saved successfully ---");

          print("=========================================================");
          print("🔑 STEP 1: DECODING WITH OFFICIAL JWT_DECODER PACKAGE");

          final Map<String, dynamic> tokenData = JwtDecoder.decode(token);

          print("📦 STEP 2: RAW DECODED TOKEN DATA:");
          print(const JsonEncoder.withIndent('  ').convert(tokenData));

          // 💡 FIXED: Target the exact .NET NameIdentifier URL schema string from your log
          final String userId =
              (tokenData['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ??
                      tokenData['userId'] ??
                      tokenData['sub'] ??
                      '')
                  .toString();

          print("🆔 STEP 3: EXTRACTED ID CANDIDATE -> '$userId'");
          print("=========================================================");

          if (userId.isNotEmpty) {
            await prefs.setString('userId', userId);
            print("--- [SUCCESS] Saved userId directly into storage ---");
          } else {
            print(
              "--- [WARNING] userId extraction failed. Value is empty. ---",
            );
          }

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => ProfileScreen()),
            );
          }
        } else {
          print("--- [ERROR] Data content: $data ---");
          throw Exception("Token not found inside the 'data' field.");
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            snackBar(Icons.error_outline, 'Login failed', AppColors.red),
          );
        }
      }
    } catch (e) {
      print("--- [CRITICAL ERROR]: $e ---");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          snackBar(Icons.error_outline, 'Connection failed', AppColors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                'Welcome Back',
                'Log in to your account.',
                [
                  buildInput(
                    "Email Address",
                    "name@example.com",
                    controller: _emailController,
                  ),
                  const SizedBox(height: 20),
                  buildInput(
                    "Password",
                    "••••••••",
                    obscure: _obscurePassword,
                    controller: _passwordController,
                    showSuffixIcon: true,
                    suffixIcon: _obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    onSuffixIconPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: _isLoading
                                ? null
                                : (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                            activeColor: AppColors.primary,
                            checkColor: Colors.black,
                          ),
                          Text(
                            'Remember Me',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      textButton(12, AppColors.primary, 'Forgot Password?', () {
                        if (!_isLoading) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ForgotPasswordScreen(),
                            ),
                          );
                        }
                      }),
                    ],
                  ),
                  const SizedBox(height: 10),
                  buildButton(
                    _isLoading ? 'Authenticating...' : 'Log In',
                    null,
                    _isLoading ? () {} : _handleLogin,
                    true,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      textButton(12, AppColors.primary, 'Join the Team', () {
                        if (!_isLoading) {
                          Navigator.pushNamed(context, '/signup');
                        }
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
