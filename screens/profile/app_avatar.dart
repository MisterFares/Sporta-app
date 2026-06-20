import 'dart:typed_data';

import 'package:fit/screens/profile/default_avatar.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class AppAvatar extends StatelessWidget {
  final String? src;
  final double size;
  final double borderWidth;
  final Color? borderColor;

  const AppAvatar({
    super.key,
    this.src,
    this.size = 48,
    this.borderWidth = 0,
    this.borderColor,
  });

  String? _getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return null;
    
    if (imagePath.startsWith('http://') ||
        imagePath.startsWith('https://') ||
        imagePath.startsWith('/storage/') ||
        imagePath.startsWith('file://') ||
        imagePath.startsWith('/data/')) {
      return imagePath;
    }
    
    // Use base URL without /api
    const String baseUrl = 'https://sporta.runasp.net';
    final cleanPath = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    return '$baseUrl/$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    final fullSrc = _getFullImageUrl(src);
    final invalid = fullSrc == null || fullSrc.isEmpty;
    
    final isLocalFile = fullSrc != null &&
        (fullSrc.startsWith('/') ||
            fullSrc.startsWith('file://') ||
            fullSrc.contains('/storage/'));

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderWidth > 0
            ? Border.all(color: borderColor ?? AppColors.cardBorder, width: borderWidth)
            : null,
      ),
      child: ClipOval(
        child: invalid
            ? DefaultAvatar(size: size)
            : isLocalFile
                ? Image.file(
                    File(fullSrc),
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => DefaultAvatar(size: size),
                  )
                : _buildImageWithAuth(fullSrc),
      ),
    );
  }

  Widget _buildImageWithAuth(String url) {
    return FutureBuilder<Uint8List?>(
      future: _loadImageWithAuth(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return DefaultAvatar(size: size);
        }
        if (snapshot.hasData && snapshot.data != null) {
          return Image.memory(
            snapshot.data!,
            width: size,
            height: size,
            fit: BoxFit.cover,
          );
        }
        return DefaultAvatar(size: size);
      },
    );
  }

  Future<Uint8List?> _loadImageWithAuth(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'X-Tunnel-Skip-AntiPhishing-Page': 'true',
        },
      );
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      print('❌ Error loading image: $e');
    }
    return null;
  }
}