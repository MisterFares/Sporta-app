import 'package:flutter/material.dart';

class FilterOption {
  final String id;
  final String label;
  final IconData ?icon;
  
  FilterOption({
    required this.id,
    required this.label,
    this.icon,
  });
}