import 'package:fit/components/Logo/role_card.dart';
import 'package:fit/components/Logo/sporta.dart';
import 'package:fit/screens/authentication/signup_screen2.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

class SelectPlanScreen extends StatefulWidget {
  final String fullname;
  final String email;
  final String password;
  const SelectPlanScreen({
    super.key,
    required this.fullname,
    required this.email,
    required this.password,
  });

  @override
  State<SelectPlanScreen> createState() => _SelectPlanScreenState();
}

class _SelectPlanScreenState extends State<SelectPlanScreen> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  sportaLogo(),
                  const SizedBox(height: 30),
                  const Text(
                    "Define Your Performance Path",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    "Your role selection sets up your dashboard, tools, and access privileges.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 🔥 STACKED VERTICALLY
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedRole = "trainee";
                      });
                    },
                    child: buildRoleCard(
                      role: "trainee",
                      icon: Icons.track_changes,
                      title: "Trainee",
                      description:
                          "Maximize individual performance through data-driven training and analysis.",
                      benefits: [
                        "Advanced Metric Tracking (VO2 Max, RPE)",
                        "AI-Driven Workout Planning & Recovery Scores",
                        "Secure Long-Term Progress",
                      ],
                      selectedRole: selectedRole,
                    ),
                  ),

                  const SizedBox(height: 24),

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedRole = "coach";
                      });
                    },
                    child: buildRoleCard(
                      role: "coach",
                      icon: Icons.group,
                      title: "Coach",
                      description:
                          "Manage trainees, build programs, and deliver high-performance training at scale.",
                      benefits: [
                        'Bulk Program Deployment & Template Library Access',
                        'Real-Time Multi-Client Progress Dashboard',
                        'Integrated Billing & Client Monetization Tools',
                      ],
                      selectedRole: selectedRole,
                    ),
                  ),

                  const SizedBox(height: 50),

                  ElevatedButton(
                    onPressed: selectedRole == null
                        ? null
                        : () {
                            // Make sure the context is valid
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignupScreen2(
                                  selectedRole: selectedRole!,
                                  fullname: widget.fullname,
                                  email: widget.email,
                                  password: widget.password,
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Text(
                      selectedRole == null
                          ? "Continue to setup"
                          : "PROCEED AS ${selectedRole!.toUpperCase()}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
