import 'package:fit/screens/store/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:fit/models/store/cart_item.dart';
import 'package:fit/components/Widgets/app_bar.dart';
import 'package:fit/components/Widgets/build_button.dart';
import 'package:fit/styles/colors.dart';
import 'package:fit/services/api_service.dart';
import 'package:flutter/services.dart';

class CartScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final Function(List<CartItem>) onCartUpdate;

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.onCartUpdate,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<CartItem> _cartItems;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cartItems = List.from(widget.cartItems);
  }

  double get _subtotal {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  double get _total => _subtotal;

  void _updateCartState() {
    setState(() {});
    widget.onCartUpdate(_cartItems);
  }

  // 1. تفريغ السلة بالكامل وتنظيف الواجهة فوراً
  Future<void> _clearCart() async {
    setState(() => _isLoading = true);
    try {
      await ApiService.clearCart();
      setState(() {
        _cartItems.clear();
      });
      _updateCartState();
    } catch (e) {
      _showErrorSnackBar('Failed to clear cart');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 2. تحديث الكمية في السيرفر وتعديلها محلياً بالشاشة
  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    // Calculate the difference:
    // Going from 2 to 3 = 1
    // Going from 2 to 1 = -1
    int delta = newQuantity - item.quantity;

    try {
      await ApiService.updateCartQuantity(
        productId: item.product.id,
        quantity: delta, // Send ONLY the difference (+1 or -1) to the server
      );

      setState(() {
        item.quantity = newQuantity; // Update the UI to the actual new total
      });
      _updateCartState();
    } catch (e) {
      _showErrorSnackBar('Failed to update quantity');
    }
  }

  // 3. حذف المنتج نهائياً عند السحب وإزالته من الـ UI
  Future<void> _removeItem(CartItem item, int index) async {
    try {
      await ApiService.removeFromCart(productId: item.product.id);
      setState(() {
        _cartItems.removeAt(index);
      });
      _updateCartState();
    } catch (e) {
      _showErrorSnackBar('Failed to remove item');
      // تراجع محلي في حالة فشل الاتصال بالسيرفر لإبقاء البيانات متطابقة
      setState(() {
        _cartItems.insert(index, item);
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'My Cart',
        actions: [
          if (_cartItems.isNotEmpty)
            TextButton(
              onPressed: _isLoading ? null : _clearCart,
              child: Text(
                'Clear All',
                style: TextStyle(color: AppColors.red),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      // استخدام ValueKey فريد ومستقر لكل عنصر لمنع الـ UI من تكرار العناصر المحذوفة بشكل خاطئ
                      return _buildCartItemCard(item, index);
                    },
                  ),
                ),
                // لن يظهر شريط حساب المجموع والدفع إلا إذا كانت السلة تحتوي على منتجات فعلاً
                if (_cartItems.isNotEmpty) _buildCheckoutSection(),
                SizedBox(height: 30),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add items from the store to get started',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
            ),
            child: Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(CartItem item, int index) {
    return Dismissible(
      key: ValueKey(
        item.product.id,
      ), // تعديل الـ Key ليكون معرف مستقر للـ Item نفسه
      direction: DismissDirection.endToStart,
      background: Container(),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete, color: AppColors.red),
      ),
      onDismissed: (direction) => _removeItem(item, index),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.notActive,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(Icons.shopping_bag, color: AppColors.textPrimary),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    item.product.category,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '\$${item.product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (item.quantity > 1) {
                          _updateQuantity(item, item.quantity - 1);
                        }
                      },
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      width:
                          50, // Added a fixed width so the TextField doesn't expand infinitely
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        controller: TextEditingController(
                          text: '${item.quantity}',
                        ),

                        // THIS IS WHERE THE FORMATTER GOES:
                        inputFormatters: [
                          FilteringTextInputFormatter
                              .digitsOnly, // Forces the keyboard to only accept numbers
                        ],

                        // Triggers your existing update logic when the user hits 'done' on the keyboard
                        onSubmitted: (value) {
                          int? typedQuantity = int.tryParse(value);
                          if (typedQuantity != null && typedQuantity > 0) {
                            _updateQuantity(item, typedQuantity);
                          } else {
                            // If they type 0 or leave it empty, reset it back to the original quantity visually
                            setState(() {});
                          }
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _updateQuantity(item, item.quantity + 1);
                      },
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '\$${item.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '\$${_total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Inside _buildCheckoutSection in CartScreen
          buildButton('Proceed to Checkout', null, () async {
            // Use async/await to wait until the user returns from PaymentScreen
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentScreen(
                  paymentType: 'store',
                  amount: _total,
                  cartItems: _cartItems,
                ),
              ),
            );

            // If the payment was successful (you can pass 'true' back from PaymentScreen)
            // or simply refresh the cart contents to check if it's empty now
            if (result == true) {
              setState(() {
                _cartItems.clear();
              });
              _updateCartState();
            }
          }, true),
        ],
      ),
    );
  }
}
