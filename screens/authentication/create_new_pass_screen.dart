import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fit/components/Authentication/another_panel.dart';
import 'package:fit/components/Widgets/input.dart';
import 'package:fit/components/Widgets/build_button.dart';
import 'package:fit/components/Widgets/snackbar.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

class CreateNewPassScreen extends StatefulWidget {
  final String email;
  final String otpToken;

  const CreateNewPassScreen({
    super.key,
    required this.email,
    required this.otpToken,
  });

  @override
  State<CreateNewPassScreen> createState() => _CreateNewPassScreenState();
}

class _CreateNewPassScreenState extends State<CreateNewPassScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final String _baseUrl = "https://sporta.runasp.net";
  
  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  Future<void> _resetPassword() async {
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        snackBar(Icons.cancel_outlined, 'Please fill in all fields', AppColors.red),
      );
      return;
    }
    
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        snackBar(Icons.error_outline, 'Passwords do not match', AppColors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('$_baseUrl/api/Auth/reset-password');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': widget.email,
          'otp': widget.otpToken,
          'newPassword': password,
        }),
      );

      // Safe extraction handling string vs raw html response errors
      Map<String, dynamic> responseData = {};
      try {
        responseData = jsonDecode(response.body);
      } catch (_) {}

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            snackBar(Icons.check_circle_outline, 'Password reset successfully!', AppColors.greeen),
          );
          
          // ✅ Pop back to Login Screen cleanly by removing history layers 
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      } else {
        String errorMsg = responseData['message'] ?? 'Failed to update password.';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            snackBar(Icons.cancel_outlined, errorMsg, AppColors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          snackBar(Icons.wifi_off_outlined, 'Connection failed. Please try again.', AppColors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Dynamic change listeners on state trees are cleaner when evaluated directly from text controller values
    final bool isMismatched = _confirmPasswordController.text.isNotEmpty && 
                             (_passwordController.text != _confirmPasswordController.text);

    return Scaffold(
      body: anotherPanel(
        context,
        "Create New Password",
        "Your new password must be different from previous used passwords.",
        Icons.lock_outline,
        [
          const SizedBox(height: 32),
          
          // New Password Input with visibility toggle
          buildInput(
            'New Password',
            'Enter your new password',
            obscure: _obscurePassword,
            controller: _passwordController,
            showSuffixIcon: true,
            suffixIcon: _obscurePassword ? Icons.visibility : Icons.visibility_off,
            onSuffixIconPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            onChanged: (_) => setState(() {}), // Force rebuild to update live error warning state
          ),
          
          const SizedBox(height: 16),
          
          // Confirm Password Input with visibility toggle
          buildInput(
            'Confirm Password',
            'Re-enter your new password',
            obscure: _obscureConfirmPassword,
            controller: _confirmPasswordController,
            showSuffixIcon: true,
            suffixIcon: _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
            onSuffixIconPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
            onChanged: (_) => setState(() {}), // Force rebuild to update live error warning state
          ),
          
          // Password mismatch indicator
          if (isMismatched) ...[
            const SizedBox(height: 8),
            Text(
              'Passwords do not match',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          buildButton(
            _isLoading ? 'Updating Password...' : 'Reset Password', 
            null, 
            _isLoading ? () {} : _resetPassword, 
            !_isLoading
          ),
          
          const SizedBox(height: 16),
          
          buildButton('Back to Login', null, () {
            // Remove full sequence view flow stack steps 
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          }, false),
        ],
      ),
    );
  }
}