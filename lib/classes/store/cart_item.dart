// classes/cart_item.dart
import 'package:fit/classes/store/store.dart';

class CartItem {
  final StoreItem product;
  int quantity;
  
  CartItem({
    required this.product,
    this.quantity = 1,
  });
  
  double get totalPrice => product.price * quantity;
}