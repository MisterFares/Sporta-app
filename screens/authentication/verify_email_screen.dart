import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fit/components/Authentication/another_panel.dart';
import 'package:fit/components/Widgets/build_button.dart';
import 'package:fit/components/Widgets/snackbar.dart';
import 'package:fit/screens/authentication/signup_screen2.dart'; 
import 'package:fit/screens/authentication/create_new_pass_screen.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String fullname;
  final String email;
  final String password;
  final bool isForgotPassword; 

  const VerifyEmailScreen({
    super.key,
    required this.fullname,
    required this.email,
    required this.password,
    required this.isForgotPassword, 
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  final String _baseUrl = "https://sporta.runasp.net";

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtpCode() async {
    if (_isLoading) return;

    final String enteredOtp = _otpController.text.trim();

    if (enteredOtp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        snackBar(Icons.error_outline, 'Please enter the 6-digit verification code', AppColors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ✅ FIXED: Using your exact backend route paths now
      final String endpoint = widget.isForgotPassword 
          ? '/api/Auth/verify-otp' 
          : '/api/Auth/validate-register-otp'; // Double-check if registration also needs to be /api/Auth/verify-otp

      final url = Uri.parse('$_baseUrl$endpoint');

      final Map<String, dynamic> requestBody = widget.isForgotPassword
          ? {
              'email': widget.email.trim(),
              'otp': enteredOtp,
            }
          : {
              'fullname': widget.fullname.trim(),
              'email': widget.email.trim(),
              'password': widget.password.trim(),
              'otp': enteredOtp,
            };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      Map<String, dynamic> responseData = {};
      try {
        responseData = jsonDecode(response.body);
      } catch (_) {}

      final bool isSuccess = responseData['isSuccess'] ?? false;

      if (response.statusCode == 200 && isSuccess) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (widget.isForgotPassword) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreateNewPassScreen(
                  email: widget.email,
                  otpToken: enteredOtp,
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SignupScreen2(
                  fullname: widget.fullname,
                  email: widget.email,
                  password: widget.password,
                ),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          final String diagnosticMessage = responseData['message'] ?? "Status: ${response.statusCode} | Body: ${response.body}";
          
          ScaffoldMessenger.of(context).showSnackBar(
            snackBar(Icons.cancel_outlined, diagnosticMessage, AppColors.red)
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          snackBar(Icons.wifi_off_outlined, 'Connection failed. Please try again.', AppColors.red),
        );
      }
    }
  }

  Future<void> _resendOtpCode() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final String endpoint = widget.isForgotPassword 
          ? '/api/Auth/forgot-password' 
          : '/api/Auth/request-register-otp';

      final url = Uri.parse('$_baseUrl$endpoint');
      
      final Map<String, dynamic> requestBody = widget.isForgotPassword
          ? {'email': widget.email}
          : {'fullName': widget.fullname, 'email': widget.email};

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      Map<String, dynamic> responseData = {};
      try {
        responseData = jsonDecode(response.body);
      } catch (_) {}

      final bool isSuccess = responseData['isSuccess'] ?? false;

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 200 && isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            snackBar(Icons.check_circle_outline, 'Verification code resent!', AppColors.greeen),
          );
        } else {
          String message = responseData['message'] ?? 'Failed to resend authentication email';
          ScaffoldMessenger.of(context).showSnackBar(snackBar(Icons.error_outline, message, AppColors.red));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          snackBar(Icons.wifi_off_outlined, 'Failed to resend. Check network.', AppColors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: anotherPanel(
        context,
        'Verify Your Email',
        "We've sent a verification code to ${widget.email}.",
        Icons.mark_email_read_outlined,
        [
          const SizedBox(height: 24),
          _buildOtpInput(),
          const SizedBox(height: 24),
          buildButton(
            _isLoading ? 'Verifying...' : 'Verify & Continue',
            null,
            _verifyOtpCode,
            !_isLoading,
          ),
          const SizedBox(height: 16),
          buildButton(
            _isLoading ? 'Please wait...' : 'Resend Code',
            null,
            _resendOtpCode,
            !_isLoading,
          ),
          const SizedBox(height: 16),
          buildButton(
            'Back to Login',
            null,
            () { Navigator.pop(context); },
            !_isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildOtpInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Verification Code',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        Pinput(
          controller: _otpController,
          length: 6,
          defaultPinTheme: PinTheme(
            width: 50, 
            height: 55,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          focusedPinTheme: PinTheme(
            width: 50, 
            height: 55,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              border: Border.all(color: AppColors.primary, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          autofocus: true,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}