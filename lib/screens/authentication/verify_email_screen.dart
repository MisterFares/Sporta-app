import 'package:fit/components/Authentication/another_panel.dart';
import 'package:fit/components/Widgets/build_button.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final TextEditingController _otpController = TextEditingController();
  String _otpCode = '';

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: anotherPanel(
        context,
        'Verify Your Email',
        'We\'ve sent a verification code to athlete@sporta.com.',
        Icons.mark_email_read_outlined,
        [
          const SizedBox(height: 24),
          
          // OTP Input Field
          _buildOtpInput(),
          
          const SizedBox(height: 24),
          
          buildButton('Verify & Continue', null, () {
            if (_otpCode.length == 6) {
              // TODO: Verify OTP code
              Navigator.pushNamed(context, '/create-new-password');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter the 6-digit verification code'),
                  backgroundColor: Color(0xFFFF453A),
                ),
              );
            }
          }, true),
          
          const SizedBox(height: 16),
          
          buildButton('Resend Email', null, () {
            // TODO: Implement resend email functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Verification code resent!'),
                backgroundColor: Color(0xFF32D74B),
              ),
            );
          }, false),
          
          const SizedBox(height: 16),
          
          buildButton('Back to Login', null, () {
            Navigator.pop(context);
          }, false),
        ],
      ),
    );
  }

  Widget _buildOtpInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter Verification Code',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Pinput(
          controller: _otpController,
          length: 6,
          defaultPinTheme: PinTheme(
            width: 50,
            height: 55,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
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
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              border: Border.all(color: AppColors.primary, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          submittedPinTheme: PinTheme(
            width: 50,
            height: 55,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              border: Border.all(color: AppColors.greeen),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          errorPinTheme: PinTheme(
            width: 50,
            height: 55,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              border: Border.all(color: AppColors.red),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onCompleted: (pin) {
            setState(() {
              _otpCode = pin;
            });
          },
          onChanged: (pin) {
            setState(() {
              _otpCode = pin;
            });
          },
          autofocus: true,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        Center(
          child: GestureDetector(
            onTap: () {
              // Auto-fill for demo (optional)
              _otpController.text = '123456';
              setState(() {
                _otpCode = '123456';
              });
            },
            child: Text(
              'Didn\'t receive code?',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}