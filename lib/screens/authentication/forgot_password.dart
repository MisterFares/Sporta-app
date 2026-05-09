import 'package:fit/components/Authentication/another_panel.dart';
import 'package:fit/components/Widgets/input.dart';
import 'package:fit/components/Widgets/build_button.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

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
          buildInput('Email Address', 'user@example.com'),
          const SizedBox(height: 24),
          buildButton('Send Reset Code', null, () {
            Navigator.pushNamed(context, '/verify-email');
          }, true),
          const SizedBox(height: 16),
          buildButton('Back to Login', Icon(Icons.arrow_back), () {
            Navigator.pop(context);
          }, false),
        ],
      ),
    );
  }
}
