import 'dart:ui';

import 'package:flutter/material.dart';

SnackBar snackBar(IconData icon, String text, Color color) {
  return SnackBar(
    duration: Duration(seconds: 1),
    behavior: SnackBarBehavior.floating,
    content: Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: color)),
      ],
    ),
    backgroundColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: color),
      borderRadius: BorderRadius.circular(50),
    ),
  );
}