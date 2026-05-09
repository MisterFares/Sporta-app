import 'package:fit/components/Authentication/another_panel.dart';
import 'package:fit/components/Widgets/input.dart';
import 'package:fit/components/Widgets/build_button.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

class CreateNewPassScreen extends StatefulWidget {
  const CreateNewPassScreen({super.key});

  @override
  State<CreateNewPassScreen> createState() => _CreateNewPassScreenState();
}

class _CreateNewPassScreenState extends State<CreateNewPassScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  String _password = '';
  String _confirmPassword = '';
  
  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  void _resetPassword() {
    if (_password.isEmpty || _confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    
    if (_password != _confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          shape: RoundedRectangleBorder(),
          content: Text('Passwords do not match', style: TextStyle(color: Colors.black),),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password reset successfully!'),
        backgroundColor: AppColors.greeen,
      ),
    );
    Navigator.pushNamed(context, '/login');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: anotherPanel(
        context,
        "Create New Password",
        "Your new password must be different from the previous used passwords.",
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
            onChanged: (value) {
              setState(() {
                _password = value;
              });
            },
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
            onChanged: (value) {
              setState(() {
                _confirmPassword = value;
              });
            },
          ),
          
          // Password mismatch indicator
          if (_confirmPassword.isNotEmpty && _password != _confirmPassword) ...[
            const SizedBox(height: 8),
            const Text(
              'Passwords do not match',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.red,
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          buildButton('Reset Password', null, _resetPassword, true),
          
          const SizedBox(height: 16),
          
          buildButton('Back to Login', null, () {
            Navigator.pop(context);
          }, false),
        ],
      ),
    );
  }
}