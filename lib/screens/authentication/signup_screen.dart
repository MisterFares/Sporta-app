import 'package:fit/components/Authentication/build_panel.dart';
import 'package:fit/components/Widgets/build_button.dart';
import 'package:fit/components/Widgets/snackbar.dart';
import 'package:fit/components/Widgets/textbutton.dart';
import 'package:fit/screens/authentication/select_plan_screen.dart';
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
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    String fullName = _fullNameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        snackBar(
          Icons.cancel_outlined,
          'Please fill in all fields',
          AppColors.red,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        snackBar(
          Icons.cancel_outlined,
          'Passwords do not match',
          AppColors.red,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        snackBar(
          Icons.cancel_outlined,
          'Password must be at least 6 characters',
          AppColors.red,
        ),
      );
      return;
    }

    // TODO: Implement actual signup logic
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectPlanScreen(
          fullname: fullName,
          email: email,
          password: password,
        ),
      ),
    );
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
                  buildInput(
                    "Full Name",
                    "John Doe",
                    controller: _fullNameController,
                  ),

                  const SizedBox(height: 25),

                  buildInput(
                    "Email Address",
                    "you@elite-athlete.com",
                    controller: _emailController,
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width:
                            (width * 0.9 > 900 ? 900 : width * 0.9) * 0.5 - 35,
                        child: buildInput(
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
                      ),
                      SizedBox(
                        width:
                            (width * 0.9 > 900 ? 900 : width * 0.9) * 0.5 - 35,
                        child: buildInput(
                          "Confirm Password",
                          "••••••••",
                          obscure: _obscureConfirmPassword,
                          controller: _confirmPasswordController,
                          showSuffixIcon: true,
                          suffixIcon: _obscureConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          onSuffixIconPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Text(
                        'By creating an account, you agree to our',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      textButton(
                        10,
                        AppColors.textPrimary,
                        'Terms of Services.',
                        () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  buildButton('Create Account', null, _handleSignup, true),

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
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
