import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class Product {
  final String id;
  final String name;
  final String desc; // بقيت كما هي لعدم كسر الـ UI
  final double price;
  final String? image; // بقيت كما هي لعدم كسر الـ UI
  final String category; // بقيت كما هي لعدم كسر الـ UI
  final IconData icon; // أيقونة افتراضية في حال فشل تحميل الصورة
  final String? badgeText;
  final String? badgeType;
  final int stockQuantity; // يمكنك تحديد نوع البادج بناءً على قيمته

  Product({
    required this.id,
    required this.name,
    required this.desc,
    required this.price,
    this.image,
    required this.category,
    this.icon = Icons.shopping_bag, // أيقونة افتراضية للمتجر
    this.badgeText,
    this.badgeType,
    required this.stockQuantity,
  });

  // الـ Factory المحدث لترجمة مفاتيح الـ JSON الجديد إلى حقول الكلاس الحالية
  factory Product.fromJson(Map<String, dynamic> json) {
    // معالجة البادج: نأخذ أول عنصر إذا كانت القائمة تحتوي على عناصر
    String? badge;
    if (json['badges'] != null && (json['badges'] as List).isNotEmpty) {
      badge = json['badges'][0].toString();
    }

    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      desc: json['description'] ?? '', // خريطة: description -> desc
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      image: json['imageUrl'], // خريطة: imageUrl -> image
      category:
          json['categoryName'] ?? 'General', // خريطة: categoryName -> category
      badgeText: badge,
      badgeType: badge == 'NEW'
          ? 'primary'
          : 'danger', // تخصيص نوع البادج تلقائياً
      icon: _getIconByCategory(json['categoryName']),
      stockQuantity: json['stockQuantity'] ?? json['StockQuantity'] ?? 0,
    );
  }

  // دالة مساعدة لتحديد الأيقونة الافتراضية بناءً على القسم القادم من الـ API
  static IconData _getIconByCategory(String? categoryName) {
    switch (categoryName?.toLowerCase()) {
      case 'supplements':
        return LucideIcons.package;
      case 'equipment':
        return Icons.fitness_center;
      case 'apparel':
        return Icons.checkroom;
      default:
        return Icons.shopping_bag;
    }
  }
}
