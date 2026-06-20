// classes/cart_item.dart
import 'package:fit/models/store/product.dart';

class CartItem {
  final Product product;
  int quantity;
  
  CartItem({
    required this.product,
    this.quantity = 1,
  });
  
  // حساب السعر الإجمالي محلياً
  double get totalPrice => product.price * quantity;

  // 🛠️ الإضافة المهمة: دالة لتحويل الـ JSON القادم من السيرفر إلى كائن CartItem
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      // نقوم بتمرير الـ JSON الخاص بالمنتج إلى موديل Product نفسه ليقوم بتحليله
      product: Product.fromJson(json['product'] ?? json['Product']),
      quantity: json['quantity'] ?? json['Quantity'] ?? 1,
    );
  }
}