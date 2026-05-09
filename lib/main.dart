import 'package:fit/screens/authentication/create_new_pass_screen.dart';
import 'package:fit/screens/authentication/forgot_password.dart';
import 'package:fit/screens/authentication/login_screen.dart';
import 'package:fit/screens/authentication/password_updated.dart';
import 'package:fit/screens/authentication/select_plan_screen.dart';
import 'package:fit/screens/authentication/signup_screen.dart';
import 'package:fit/screens/authentication/signup_screen2.dart';
import 'package:fit/screens/authentication/upload_certificate_screen.dart';
import 'package:fit/screens/authentication/upload_image.dart';
import 'package:fit/screens/authentication/verify_email_screen.dart';
import 'package:fit/screens/coach/coach_profile_screen.dart';
import 'package:fit/screens/coach/my_trainees_screen.dart';
import 'package:fit/screens/trainee/coaches_screen.dart';
import 'package:fit/screens/trainee/community_screen.dart';
import 'package:fit/screens/trainee/empty_states_screen.dart';
import 'package:fit/screens/trainee/profile_screen.dart';
import 'package:fit/screens/trainee/program_details_screen.dart';
import 'package:fit/screens/trainee/settings_screen.dart';
import 'package:fit/screens/trainee/my_programs_screen.dart';
import 'package:fit/screens/trainee/messages_screen.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Inter',
        popupMenuTheme: PopupMenuThemeData(
          color: AppColors.cardBackground,
          textStyle: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
      debugShowCheckedModeBanner: false,
      title: 'Sporta',
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/upload-certificate': (context) => UploadCertificateScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/create-new-password': (context) => const CreateNewPassScreen(),
        '/verify-email': (context) => const VerifyEmailScreen(),
        '/password-updated': (context) => const PasswordUpdatedScreen(),
        '/empty-states': (context) => const EmptyStatesScreen(),
        '/my-programs': (context) => const MyProgramsScreen(),
        '/community': (context) => const CommunityScreen(),
        '/coaches': (context) => const CoachesScreen(),
        '/messages': (context) => const MessagesScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/coach-profile': (context) => const CoachProfileScreen(),
        '/my-trainees': (context) => const MyTraineesScreen(),
        '/program-details': (context) => const ProgramDetailsScreen(),
      },
    );
  }
}
