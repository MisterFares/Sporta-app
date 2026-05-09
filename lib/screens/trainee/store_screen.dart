// Updated StoreScreen with cart functionality
import 'package:fit/classes/store/cart_item.dart';
import 'package:fit/classes/store/store.dart';
import 'package:fit/components/Widgets/app_bar.dart';
import 'package:fit/components/Widgets/build_filters.dart';
import 'package:fit/components/Widgets/build_search_input.dart';
import 'package:fit/components/Widgets/drawer.dart';
import 'package:fit/components/Widgets/header.dart';
import 'package:fit/components/Widgets/build_button.dart';
import 'package:fit/lists/filters/store_filter.dart';
import 'package:fit/lists/data/items.dart';
import 'package:fit/screens/trainee/cart_screen.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  String _selectedFilter = storeFilters[0].id;
  final TextEditingController _searchController = TextEditingController();
  List<CartItem> _cartItems = []; // Store cart items here

  List<StoreItem>? get _filteredItems {
    if (_selectedFilter == 'all_items') {
      return storeItems;
    }
    return storeItems
        .where((item) => item.category == _selectedFilter)
        .toList();
  }

  int get _totalCartItems {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  void _addToCart(StoreItem product, int quantity) {
    setState(() {
      final existingItem = _cartItems.firstWhere(
        (item) => item.product.id == product.id,
        orElse: () => CartItem(product: product),
      );

      if (_cartItems.contains(existingItem)) {
        existingItem.quantity += quantity;
      } else {
        _cartItems.add(CartItem(product: product, quantity: quantity));
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${product.name} to cart'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "Store"),
      drawer: AppDrawer(selectedIndex: 2, role: 'trainee'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            pageHeader(
              'Gear, supplements, and exclusive rewards to fuel your journey.',
            ),
            const SizedBox(height: 24),

            buildSearchInput(_searchController, (value) {
              setState(() {});
            }, 'Search for items...'),
            const SizedBox(height: 16),

            buildFilters(storeFilters, _selectedFilter, (filterId) {
              setState(() {
                _selectedFilter = filterId;
              });
            }),
            const SizedBox(height: 24),

            Container(
              constraints: BoxConstraints(maxHeight: 420),
              child: GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 700 ? 3 : 2,
                shrinkWrap: true,
                clipBehavior: Clip.none,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.45,
                physics: const NeverScrollableScrollPhysics(),
                children: (_filteredItems ?? []).map((item) {
                  return _productCard(item, context);
                }).toList(),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: [
          FloatingActionButton(
            onPressed: () async {
              // Navigate to cart screen and wait for result
              final updatedCart = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(
                    cartItems: _cartItems,
                    onCartUpdate: (updatedItems) {},
                  ),
                ),
              );

              // Update cart when coming back
              if (updatedCart != null) {
                setState(() {
                  _cartItems = updatedCart;
                });
              }
            },
            backgroundColor: AppColors.primary.withOpacity(0.75),
            foregroundColor: AppColors.textPrimary,
            shape: const CircleBorder(),
            child: const Icon(Icons.shopping_cart),
          ),
          if (_totalCartItems >= 1)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$_totalCartItems',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _productCard(StoreItem item, BuildContext context) {
    int quantity = 1;
    double currentPrice = item.price;

    return GestureDetector(
      onTap: () {
        quantity = 1;
        currentPrice = item.price;

        showDialog(
          context: context,
          builder: (_) => StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
              backgroundColor: AppColors.cardBackground,
              title: Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: AppColors.notActive,
                    child: const Center(
                      child: Icon(Icons.image, size: 50, color: Colors.white54),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.category.toUpperCase(),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.name.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Premium quality product for your fitness journey.",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.cardBorder.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Premium Quality',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.cardBorder.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Fast Shipping',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setDialogState(() {
                            if (quantity > 1) {
                              quantity--;
                              currentPrice = item.price * quantity;
                            }
                          });
                        },
                        icon: Icon(
                          Icons.remove_outlined,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardBorder.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$quantity',
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setDialogState(() {
                            if (quantity < 10) {
                              quantity++;
                              currentPrice = item.price * quantity;
                            }
                          });
                        },
                        icon: Icon(
                          Icons.add_outlined,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(height: 1, color: AppColors.cardBorder),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${currentPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 120,
                        child: buildButton('Add to Cart', null, () {
                          _addToCart(item, quantity);
                          Navigator.pop(context);
                        }, true),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.notActive,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: const Icon(Icons.image, color: Colors.white54),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.category.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'PRICE',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40,
                    child: buildButton('Add to Cart', null, () {
                      _addToCart(item, 1);
                    }, false),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
