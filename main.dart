import 'dart:io';

import 'package:fit/providers/theme_provider.dart';
import 'package:fit/screens/authentication/forgot_password.dart';
import 'package:fit/screens/authentication/login_screen.dart';
import 'package:fit/screens/authentication/password_updated.dart';
import 'package:fit/screens/authentication/signup_screen.dart';
import 'package:fit/screens/coach_programs/my_programs_screen2.dart';
import 'package:fit/screens/coach/subscriptions_screen.dart';
import 'package:fit/screens/profile/profile_screen.dart';
import 'package:fit/screens/trainee/coaches_screen.dart';
import 'package:fit/screens/community/community_screen.dart';
import 'package:fit/screens/settings/settings_screen.dart';
import 'package:fit/screens/trainee/my_programs_screen.dart';
import 'package:fit/screens/messages/messages_screen.dart';
import 'package:fit/screens/trainee/programs_screen.dart';
import 'package:fit/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  HttpOverrides.global = MyHttpOverrides();

  // تأمين تهيئة الحزم
  WidgetsFlutterBinding.ensureInitialized();

  String? savedToken;
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    savedToken = prefs.getString('auth_token');

    // 🕵️‍♂️ سطر ذهبي للـ Debugging: هيطبع لك في الـ Console التوكن المخرون كام بالضبط أول ما الأبلكيشن يفتح
    debugPrint("📱 DETECTED TOKEN ON LAUNCH: $savedToken");
  } catch (e) {
    debugPrint("Shared Preferences launch error: $e");
  }

  // تحديد الشاشة بناءً على التوكن
  final Widget initialScreen =
      (savedToken != null && savedToken.trim().isNotEmpty)
      ? ProfileScreen(isOwner: true)
      : const LoginScreen();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(initialScreen: initialScreen),
    ),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          theme: themeProvider.theme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          debugShowCheckedModeBanner: false,
          title: 'Sporta',
          home: initialScreen,
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => SignupScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/password-updated': (context) => const PasswordUpdatedScreen(),
            '/my-programs': (context) => const MyProgramsScreen(),
            '/my-programs2': (context) => const MyProgramsScreen2(),
            '/community': (context) => const CommunityScreen(),
            '/coaches': (context) => const CoachesScreen(),
            '/messages': (context) => const MessagesScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/my-subs': (context) => const SubscriptionsScreen(),
            '/program-details': (context) => const ProgramsScreen(),
          },
        );
      },
    );
  }
}