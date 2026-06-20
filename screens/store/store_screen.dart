import 'package:fit/components/Widgets/textbutton.dart';
import 'package:fit/models/store/cart_item.dart';
import 'package:fit/models/store/product.dart';
import 'package:fit/components/Widgets/app_bar.dart';
import 'package:fit/components/Widgets/build_dropdown_filter.dart';
import 'package:fit/components/Widgets/build_search_input.dart';
import 'package:fit/components/Widgets/drawer.dart';
import 'package:fit/components/Widgets/header.dart';
import 'package:fit/components/Widgets/build_button.dart';
import 'package:fit/screens/store/cart_screen.dart';
import 'package:fit/screens/store/product_reviews_section.dart';
import 'package:fit/styles/colors.dart';
import 'package:fit/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StoreScreen extends StatefulWidget {
  final String? role;
  const StoreScreen({super.key, this.role});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  String _selectedCategory = 'Categories: All';
  String _selectedPrice = 'Price: Any';
  final TextEditingController _searchController = TextEditingController();
  List<CartItem> _cartItems = [];

  // متغيرات الـ Pagination لإدارة الصفحات حياً
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  List<Product> _currentProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts(); // جلب الصفحة الأولى عند فتح الشاشة
  }

  // دالة جلب البيانات المحدثة لتصبح ديناميكية بالكامل
  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // نطلب البيانات ونستقبل الـ Map المشترك
      final result = await ApiService.getProducts(
        pageNumber: _currentPage,
        pageSize: 10,
      );

      setState(() {
        // نأخذ قائمة المنتجات من المفتاح الخاص بها
        _currentProducts = result['products'];

        // نحدث عدد الصفحات ديناميكياً من السيرفر مباشرة بدلاً من الرقم 33
        _totalPages = result['totalPages'];

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint("API Error: $e");
    }
  }

  List<Product> _applyFilters(List<Product> items) {
    List<Product> filtered = items;

    if (_selectedCategory != 'Categories: All') {
      filtered = filtered
          .where((item) => item.category == _selectedCategory)
          .toList();
    }

    if (_selectedPrice == 'Under \$30') {
      filtered = filtered.where((item) => item.price < 30).toList();
    } else if (_selectedPrice == '\$30 - \$50') {
      filtered = filtered
          .where((item) => item.price >= 30 && item.price <= 50)
          .toList();
    } else if (_selectedPrice == '\$50+') {
      filtered = filtered.where((item) => item.price > 50).toList();
    }

    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where(
            (item) =>
                item.name.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ) ||
                item.category.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ),
          )
          .toList();
    }

    return filtered;
  }

  int get _totalCartItems {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  // دالة التعامل مع الـ API الخارجي والتحديث المحلي للسلة بدون تغيير الهيكل
  Future<void> _addToCart(Product product, int quantity) async {
    try {
      // استدعاء الـ endpoint لإضافة المنتج في الخلفية
      await ApiService.addToCart(productId: product.id, quantity: quantity);

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

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${product.name} to cart'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      debugPrint("Add to Cart Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add item to cart. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _applyFilters(_currentProducts);

    return Scaffold(
      appBar: MyAppBar(title: "Store"),
      drawer: AppDrawer(
        selectedIndex: widget.role == 'trainer' ? 3 : 2,
        role: widget.role,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 15.0, top: 10),
                    child: pageHeader(
                      'Gear, supplements, and exclusive rewards to fuel your journey.',
                    ),
                  ),
                  SizedBox(height: 8),

                  _buildSearchAndFilters(),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      '${filteredItems.length} products found on this page',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  filteredItems.isEmpty
                      ? _buildEmptyState()
                      : Padding(
                          padding: EdgeInsets.all(20),
                          child: Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: filteredItems.map((item) {
                              return SizedBox(
                                width: double.infinity,
                                height: 400,
                                child: _productCard(item, context),
                              );
                            }).toList(),
                          ),
                        ),

                  // 1. إضافة أزرار الـ Pagination في أسفل القائمة
                  if (_currentProducts.isNotEmpty) _buildPaginationControls(),

                  SizedBox(height: 40),
                ],
              ),
            ),
      floatingActionButton: Stack(
        children: [
          FloatingActionButton(
            onPressed: () async {
              // Navigate to CartScreen and wait
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(
                    cartItems: _cartItems,
                    // This triggers instantly whenever an item is deleted or the cart is cleared inside CartScreen
                    onCartUpdate: (updatedItems) {
                      setState(() {
                        _cartItems = updatedItems;
                      });
                    },
                  ),
                ),
              );
            },
            backgroundColor: AppColors.primary.withOpacity(0.75),
            foregroundColor: AppColors.textPrimary,
            shape: CircleBorder(),
            child: Icon(Icons.shopping_cart),
          ),
          if (_totalCartItems >= 1)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${_cartItems.length}',
                  style: TextStyle(
                    color: AppColors.textPrimary,
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

  // ويدجت التحكم في الصفحات (Pagination UI)
  Widget _buildPaginationControls() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
              size: 18,
            ),
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _currentPage--;
                      _fetchProducts();
                    });
                  }
                : null,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Text(
              'Page $_currentPage of $_totalPages',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textPrimary,
              size: 18,
            ),
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() {
                      _currentPage++;
                      _fetchProducts();
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 48, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search query',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.cardBackground,
            AppColors.cardBackground.withOpacity(0.5),
          ],
        ),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: buildSearchInput(_searchController, (value) {
                  setState(() {});
                }, 'Search store...'),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.history,
                  color: AppColors.textPrimary,
                  size: 28,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => DraggableScrollableSheet(
                      initialChildSize: 0.8,
                      minChildSize: 0.5,
                      maxChildSize: 0.9,
                      expand: false,
                      builder: (context, scrollController) => Container(
                        color: AppColors.cardBackground,
                        child: FutureBuilder<List<dynamic>>(
                          future: ApiService.getOrderHistory(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text("Error: ${snapshot.error}"),
                              );
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Center(child: Text("No orders found."));
                            }

                            final orders = snapshot.data!;

                            return Expanded(
                              child: ListView.builder(
                                itemCount: orders.length,
                                itemBuilder: (context, index) {
                                  final order = orders[index];
                                  print(
                                    "Building row for: ${order['orderNumber']}",
                                  );
                                  return Card(
                                    child: ListTile(
                                      title: Text(
                                        "Order: ${order['orderNumber']}",
                                      ),
                                      subtitle: Text(
                                        "Status: ${order['status']} - Total: ${order['total']}",
                                      ),
                                      trailing: Text(order['date']),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: buildFilterDropdown(
                  _selectedCategory,
                  ['Categories: All', 'Supplements', 'Equipment', 'Apparel'],
                  (v) => setState(() {
                    _selectedCategory = v;
                  }),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: buildFilterDropdown(
                  _selectedPrice,
                  ['Price: Any', 'Under \$30', '\$30 - \$50', '\$50+'],
                  (v) => setState(() {
                    _selectedPrice = v;
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _productCard(Product item, BuildContext context) {
    int quantity = 1;
    double currentPrice = item.price;
    int stockAvailable = item.stockQuantity;

    return GestureDetector(
      onTap: () {
        quantity = 1;
        currentPrice = item.price;

        // تعريف التحكم بالنص هنا ليتم إعادته للحالة الافتراضية عند فتح الـ Dialog كل مرة
        final TextEditingController quantityController = TextEditingController(
          text: "1",
        );

        showDialog(
          context: context,
          builder: (_) => StatefulBuilder(
            builder: (context, setDialogState) => Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(16),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          item.image != null && item.image!.isNotEmpty
                              ? Image.network(
                                  item.image!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 200,
                                    width: double.infinity,
                                    color: AppColors.notActive,
                                    child: Center(
                                      child: Icon(
                                        item.icon,
                                        size: 60,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 200,
                                  width: double.infinity,
                                  color: AppColors.cardBackground,
                                  child: Center(
                                    child: Icon(
                                      item.icon,
                                      size: 60,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.cardBackground.withOpacity(
                                    0.5,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: AppColors.textPrimary,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.category.toUpperCase(),
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              item.name,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              item.desc,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 16),

                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: stockAvailable > 0
                                    ? Colors.green.withOpacity(0.15)
                                    : Colors.red.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    stockAvailable > 0
                                        ? Icons.check_circle_outline
                                        : Icons.gpp_bad,
                                    color: stockAvailable > 0
                                        ? Colors.green
                                        : Colors.red,
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    stockAvailable > 0
                                        ? 'In Stock: $stockAvailable units'
                                        : 'Out of Stock',
                                    style: TextStyle(
                                      color: stockAvailable > 0
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),

                            // should open a modal with the reviews
                            textButton(15, AppColors.primary, 'Reviews', () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled:
                                    true, // Crucial: lifts the modal when the keyboard appears
                                backgroundColor: Colors
                                    .transparent, // Ensures our custom top border curves show correctly
                                builder: (context) => Padding(
                                  padding: EdgeInsets.only(
                                    // Pushes the input field above the on-screen keyboard
                                    bottom: MediaQuery.of(
                                      context,
                                    ).viewInsets.bottom,
                                  ),
                                  child: ProductReviewsSection(
                                    productId: item.id.toString(),
                                  ), // Passes your product's unique UUID string
                                ),
                              );
                            }),
                            SizedBox(height: 20),

                            // قسم تغيير الكمية المحدث بدعم الـ Input النصي
                            Row(
                              children: [
                                Text(
                                  'Quantity:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () {
                                    setDialogState(() {
                                      if (quantity > 1) {
                                        quantity--;
                                        quantityController.text = quantity
                                            .toString(); // تحديث النص في الحقل
                                        currentPrice = item.price * quantity;
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.cardBorder,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.remove,
                                      size: 18,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),

                                // حقل إدخال الكمية النصي الصغير بدلاً من الـ Container القديم
                                SizedBox(
                                  width: 60,
                                  height: 38,
                                  child: TextField(
                                    controller: quantityController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    cursorColor: AppColors.primary,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter
                                          .digitsOnly, // يقبل أرقام فقط ويمنع الفواصل والنقاط
                                    ],
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.zero,
                                      filled: true,
                                      fillColor: AppColors.cardBorder
                                          .withOpacity(0.5),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      if (value.isEmpty) {
                                        setDialogState(() {
                                          quantity =
                                              1; // قيمة افتراضية مؤقتة عند المسح بالكامل لتجنب أخطاء الحساب
                                          currentPrice = item.price * quantity;
                                        });
                                        return;
                                      }

                                      int? parsed = int.tryParse(value);
                                      if (parsed != null) {
                                        setDialogState(() {
                                          if (parsed > stockAvailable) {
                                            quantity = stockAvailable;
                                            quantityController.text =
                                                stockAvailable.toString();
                                            // الاحتفاظ بمؤشر الكتابة في نهاية النص المقصوص
                                            quantityController.selection =
                                                TextSelection.fromPosition(
                                                  TextPosition(
                                                    offset: quantityController
                                                        .text
                                                        .length,
                                                  ),
                                                );

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Cannot exceed available stock limit!',
                                                ),
                                                backgroundColor:
                                                    Colors.redAccent,
                                                duration: Duration(seconds: 1),
                                              ),
                                            );
                                          } else if (parsed < 1) {
                                            quantity = 1;
                                          } else {
                                            quantity = parsed;
                                          }
                                          currentPrice = item.price * quantity;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () {
                                    setDialogState(() {
                                      if (quantity < stockAvailable) {
                                        quantity++;
                                        quantityController.text = quantity
                                            .toString(); // تحديث النص في الحقل
                                        currentPrice = item.price * quantity;
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Cannot exceed available stock limit!',
                                            ),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.cardBorder,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      size: 18,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                            Divider(color: AppColors.cardBorder),
                            SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'TOTAL',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      '\$${currentPrice.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 50,
                                  width: 120,
                                  child: buildButton('Add To Cart', null, () {
                                    _addToCart(item, quantity);
                                    Navigator.pop(context);
                                  }, stockAvailable > 0),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: item.image != null && item.image!.isNotEmpty
                      ? Image.network(
                          item.image!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: double.infinity,
                            height: 180,
                            color: AppColors.notActive,
                            child: Center(
                              child: Icon(
                                item.icon,
                                size: 60,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          height: 180,
                          width: double.infinity,
                          color: AppColors.notActive,
                          child: Center(
                            child: Icon(
                              item.icon,
                              size: 60,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 20),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: buildButton('Add to Cart', null, () {
                      _addToCart(item, 1);
                    }, stockAvailable > 0),
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
