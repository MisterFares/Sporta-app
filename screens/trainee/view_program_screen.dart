import 'package:fit/styles/colors.dart';
import 'package:fit/utils/image_url_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ViewProgramScreen extends StatefulWidget {
  final String fileUrl;
  final String fileType;

  const ViewProgramScreen({
    super.key,
    required this.fileUrl,
    required this.fileType,
  });

  @override
  State<ViewProgramScreen> createState() => _ViewProgramScreenState();
}

class _ViewProgramScreenState extends State<ViewProgramScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  String? _localFilePath;
  int _totalPages = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    try {
      final fullUrl = ImageUrlHelper.getFullImageUrl(widget.fileUrl);
      if (fullUrl == null || fullUrl.isEmpty) {
        throw Exception('Invalid file URL');
      }

      // Download the file to local storage
      final response = await http.get(Uri.parse(fullUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download file');
      }

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        _localFilePath = filePath;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ── HEADER ──
          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0x80232B28),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.cardBorder,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.cardTextSecondary,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.description_outlined,
                    color: Colors.yellow,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Document Viewer',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  if (_totalPages > 0)
                    Text(
                      'Page ${_currentPage + 1} of $_totalPages',
                      style: TextStyle(
                        color: AppColors.cardTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── VIEWER CONTAINER ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.cardBorder, width: 1),
                ),
                child: _isLoading
                    ? _buildLoadingState()
                    : _errorMessage != null
                    ? _buildErrorState()
                    : _buildFileViewer(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading document...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ErrorIcon(),
          const SizedBox(height: 16),
          Text(
            'Failed to Load Document',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _errorMessage ?? 'An error occurred while loading the document.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.cardTextSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadFile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildFileViewer() {
    if (_localFilePath == null) {
      return _buildErrorState();
    }

    return PDFView(
      filePath: _localFilePath!,
      enableSwipe: true,
      swipeHorizontal: true,
      autoSpacing: true,
      pageFling: true,
      onError: (error) {
        print('PDF Error: $error');
      },
      onPageChanged: (page, total) {
        setState(() {
          _currentPage = page ?? 0;
          _totalPages = total ?? 0;
        });
      },
      onViewCreated: (controller) {
        // You can use the controller for additional functionality
      },
    );
  }
}

class _ErrorIcon extends StatelessWidget {
  const _ErrorIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0x11FF453A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x33FF453A), width: 1),
      ),
      child: Icon(
        Icons.help_outline_rounded,
        color: AppColors.red,
        size: 26,
      ),
    );
  }
}