import 'package:fit/components/Authentication/build_panel.dart';
import 'package:fit/components/Widgets/build_button.dart';
import 'package:fit/components/Widgets/snackbar.dart';
import 'package:fit/components/Widgets/textbutton.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
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

    // TODO: Implement actual login logic
    Navigator.pushNamed(context, '/my-programs');
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
                            onChanged: (value) {
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
                        Navigator.pushNamed(context, '/forgot-password');
                      }),
                    ],
                  ),

                  const SizedBox(height: 10),

                  buildButton('Log In', null, _handleLogin, true),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      textButton(12, AppColors.primary, 'Join the Team', () {
                        Navigator.pushNamed(context, '/signup');
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
