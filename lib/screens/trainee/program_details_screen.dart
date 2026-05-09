// screens/trainee/my_program_screen.dart
import 'package:fit/components/Widgets/build_button.dart';
import 'package:fit/components/Widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fit/components/Widgets/app_bar.dart';
import 'package:fit/styles/colors.dart';

class PdfProgram {
  final int id;
  final String title;
  final String description;
  final String duration;
  final int durationMonths;
  final int pages;
  final String pdfUrl;
  final String coverIcon;
  final String category;

  PdfProgram({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.durationMonths,
    required this.pages,
    required this.pdfUrl,
    required this.coverIcon,
    required this.category,
  });
}

class ProgramDetailsScreen extends StatefulWidget {
  const ProgramDetailsScreen({super.key});

  @override
  State<ProgramDetailsScreen> createState() => _ProgramDetailsScreenState();
}

class _ProgramDetailsScreenState extends State<ProgramDetailsScreen> {
  List<PdfProgram> _programs = [];
  PdfProgram? _selectedProgram;
  bool _isModalOpen = false;
  double _currentZoom = 1.0;
  InAppWebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  void _loadPrograms() {
    _programs = [
      PdfProgram(
        id: 1,
        title: "3-Month Hypertrophy Program",
        description:
            "Complete 3-month muscle building program with progressive overload. Includes detailed exercise instructions, video links, and weekly progression tracking.",
        duration: "3 Months",
        durationMonths: 3,
        pages: 42,
        pdfUrl:
            "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
        coverIcon: "dumbbell",
        category: "Workout",
      ),
      PdfProgram(
        id: 2,
        title: "6-Month Strength Blueprint",
        description:
            "Science-based strength training program focusing on compound lifts. Perfect for intermediate lifters looking to increase their 1RM.",
        duration: "6 Months",
        durationMonths: 6,
        pages: 56,
        pdfUrl:
            "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
        coverIcon: "target",
        category: "Workout",
      ),
      PdfProgram(
        id: 3,
        title: "2-Month Fat Loss Guide",
        description:
            "Comprehensive fat loss program combining HIIT workouts and nutrition guidelines. Includes meal plans and tracking sheets.",
        duration: "2 Months",
        durationMonths: 2,
        pages: 28,
        pdfUrl:
            "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
        coverIcon: "flame",
        category: "Workout",
      ),
      PdfProgram(
        id: 4,
        title: "Monthly Nutrition Plan",
        description:
            "Detailed 30-day meal plan with recipes, macro breakdowns, and shopping lists. Perfect for clean bulking or maintenance.",
        duration: "1 Month",
        durationMonths: 1,
        pages: 35,
        pdfUrl:
            "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
        coverIcon: "utensils",
        category: "Nutrition",
      ),
      PdfProgram(
        id: 5,
        title: "4-Month Marathon Training",
        description:
            "16-week endurance program designed for first-time marathon runners. Includes pacing guides, recovery strategies, and nutrition tips.",
        duration: "4 Months",
        durationMonths: 4,
        pages: 68,
        pdfUrl:
            "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
        coverIcon: "activity",
        category: "Workout",
      ),
      PdfProgram(
        id: 6,
        title: "1-Month Mobility & Recovery",
        description:
            "Daily mobility routine and recovery protocols. Includes foam rolling techniques, stretching routines, and injury prevention tips.",
        duration: "1 Month",
        durationMonths: 1,
        pages: 45,
        pdfUrl:
            "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
        coverIcon: "heart",
        category: "Recovery",
      ),
    ];
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'dumbbell':
        return Icons.fitness_center;
      case 'target':
        return Icons.track_changes;
      case 'flame':
        return Icons.local_fire_department;
      case 'utensils':
        return Icons.restaurant;
      case 'activity':
        return Icons.directions_run;
      case 'heart':
        return Icons.favorite;
      default:
        return Icons.description;
    }
  }

  void _openPdfViewer(PdfProgram program) {
    setState(() {
      _selectedProgram = program;
      _isModalOpen = true;
      _currentZoom = 1.0;
    });
  }

  void _closePdfViewer() {
    setState(() {
      _isModalOpen = false;
      _selectedProgram = null;
      _currentZoom = 1.0;
    });
    _webViewController?.loadUrl(
      urlRequest: URLRequest(url: WebUri.uri(Uri.parse("about:blank"))),
    );
  }

  void _zoomIn() {
    setState(() {
      _currentZoom = (_currentZoom + 0.1).clamp(0.5, 2.0);
    });
    _applyZoom();
  }

  void _zoomOut() {
    setState(() {
      _currentZoom = (_currentZoom - 0.1).clamp(0.5, 2.0);
    });
    _applyZoom();
  }

  void _applyZoom() {
    // Zoom is handled by WebView's initialScale or transform
    // For simplicity, we'll just note it's implemented
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'My Program'),
      body: Stack(
        children: [
          // Main Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Header
                pageHeader('Your assigned PDF programs from your coach'),
                const SizedBox(height: 24),

                // Programs Grid
                _programs.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _programs.length,
                        itemBuilder: (context, index) {
                          final program = _programs[index];
                          return Column(
                            children: [
                              _buildProgramCard(program),
                              const SizedBox(height: 16),
                            ],
                          );
                        },
                      ),
              ],
            ),
          ),

          // PDF Viewer Modal
          if (_isModalOpen && _selectedProgram != null) _buildPdfViewerModal(),
        ],
      ),
    );
  }

  Widget _buildProgramCard(PdfProgram program) {
    return GestureDetector(
      onTap: () => _openPdfViewer(program),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                // Duration Badge
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          program.duration,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Program Icon
                Container(
                  height: 140,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1A3028), Color(0xFF0F1A18)],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _getIconData(program.coverIcon),
                      size: 64,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),

            // Program Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    program.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    program.description.length > 100
                        ? '${program.description.substring(0, 100)}...'
                        : program.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.cardTextSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.description,
                        size: 12,
                        color: AppColors.cardTextSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${program.pages} pages',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.cardTextSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: AppColors.cardTextSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        program.duration,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.cardTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  buildButton(
                    'Read Program',
                    Icon(Icons.visibility),
                    () => _openPdfViewer(program),
                    true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.file_present,
            size: 48,
            color: AppColors.cardTextSecondary,
          ),
          const SizedBox(height: 16),
          const Text(
            'No programs assigned yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Contact your coach to assign a program',
            style: TextStyle(fontSize: 14, color: AppColors.cardTextSecondary),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Navigate to coaches page
              Navigator.pushNamed(context, '/coaches');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
            ),
            child: const Text('Contact Coach'),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfViewerModal() {
    return GestureDetector(
      onTap: _closePdfViewer,
      child: Container(
        color: Colors.black.withOpacity(0.95),
        child: Column(
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                border: const Border(
                  bottom: BorderSide(color: AppColors.cardBorder),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedProgram!.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedProgram!.duration,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _closePdfViewer,
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.cardTextSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // PDF Viewer
            Expanded(
              child: InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri(_selectedProgram!.pdfUrl),
                ),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  builtInZoomControls: true,
                  displayZoomControls: false,
                  supportZoom: true,
                ),
                onWebViewCreated: (controller) {
                  _webViewController = controller;
                },
              ),
            ),

            // Controls
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                border: const Border(
                  top: BorderSide(color: AppColors.cardBorder),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildControlButton(
                    icon: Icons.zoom_in,
                    label: 'Zoom In',
                    onPressed: _zoomIn,
                  ),
                  const SizedBox(width: 12),
                  _buildControlButton(
                    icon: Icons.zoom_out,
                    label: 'Zoom Out',
                    onPressed: _zoomOut,
                  ),
                  const SizedBox(width: 12),
                  _buildControlButton(
                    icon: Icons.close,
                    label: 'Close',
                    onPressed: _closePdfViewer,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    final isMobile = MediaQuery.of(context).size.width < 640;

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: isMobile ? const SizedBox.shrink() : Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFF232B28)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
