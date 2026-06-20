import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:fit/components/Authentication/another_panel.dart';
import 'package:fit/components/Widgets/input.dart';
import 'package:fit/components/Widgets/build_button.dart';
import 'package:fit/components/Widgets/snackbar.dart';
import 'package:fit/screens/authentication/verify_email_screen.dart'; 
import 'package:fit/styles/colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();

  // Backend Dev Tunnel Configuration
  final String _baseUrl = "https://sporta.runasp.net";

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // --- Request Recovery OTP Link ---
  Future<void> _sendOtpCode() async {
    print("--- [DEBUG] _sendOtpCode function was triggered successfully! ---");
    
    final String email = _emailController.text.trim();
    print("--- [DEBUG] Captured Email Input text: '$email' ---");

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        snackBar(Icons.cancel_outlined, 'Please enter your email address', AppColors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('$_baseUrl/api/Auth/forgot-password');
      print("--- [DEBUG] Target Request URL parsed to: $url ---");

      print("--- [DEBUG] Executing HTTP POST network operation... ---");
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 10)); // Force timeout guard if server hangs

      print("--- [DEBUG] HTTP Server response received! Status Code: ${response.statusCode} ---");
      print("--- [DEBUG] Raw HTTP response text payload: ${response.body} ---");

      Map<String, dynamic> responseData = {};
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        print("--- [DEBUG WARNING] Response was not valid JSON string text: $e ---");
      }

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            snackBar(Icons.check_circle_outline, 'Verification code sent to your email!', AppColors.greeen),
          );

          print("--- [DEBUG] Moving forward to VerifyEmailScreen... ---");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VerifyEmailScreen(
                fullname: '', 
                password: '', 
                email: email, 
                isForgotPassword: true, 
              ),
            ),
          );
        }
      } else {
        String message = responseData['message'] ?? 'Failed to send verification code.';
        print("--- [DEBUG] Server rejected parameter values. Error Message: $message ---");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            snackBar(Icons.error_outline, message, AppColors.red)
          );
        }
      }
    } catch (error, stacktrace) {
      // ✅ This will catch and print ANY crash preventing your app from functioning
      print("--- [CRITICAL CODE CRASH EXCEPTION DETECTED] ---");
      print("Exception details: $error");
      print("Stacktrace tracking: $stacktrace");
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          snackBar(Icons.wifi_off_outlined, 'An unexpected processing fault occurred: $error', AppColors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        print("--- [DEBUG] Loading UI processing states reset to idle ---");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: anotherPanel(
        context,
        "Reset your password",
        "Enter your email address and we'll send you a verification code to reset your password.",
        Icons.mark_email_read_outlined,
        [
          const SizedBox(height: 32),
          buildInput(
            'Email Address',
            'user@example.com',
            controller: _emailController,
          ),
          const SizedBox(height: 24),
          buildButton(
            _isLoading ? 'Sending...' : 'Send Reset Code',
            null,
            _isLoading ? () {} : _sendOtpCode, // Safe execution assignment reference
            !_isLoading,
          ),
          const SizedBox(height: 16),
          buildButton(
            'Back to Login', 
            const Icon(Icons.arrow_back), 
            () { Navigator.pop(context); }, 
            !_isLoading
          ),
        ],
      ),
    );
  }
}