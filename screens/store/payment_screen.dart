// ignore_for_file: deprecated_member_use
import 'package:fit/screens/store/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fit/models/store/cart_item.dart';
import 'package:fit/styles/colors.dart';
import 'package:fit/services/api_service.dart';

class PaymentScreen extends StatefulWidget {
  final String paymentType;
  final double amount;
  final String? programId ,programName, coachName, duration, level;
  final List<CartItem>? cartItems;

  const PaymentScreen({
    super.key,
    required this.paymentType,
    required this.amount,
    this.programName,
    this.coachName,
    this.duration,
    this.level,
    this.cartItems, this.programId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

// 1. Add WidgetsBindingObserver to listen for app background/foreground state
class _PaymentScreenState extends State<PaymentScreen>
    with WidgetsBindingObserver {
  bool _isProcessing = false;
  bool _waitingForPaymentReturn =
      false; // Tracks if they are currently in the browser

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 2. This detects when the user comes back to the app from the browser
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _waitingForPaymentReturn) {
      setState(() => _waitingForPaymentReturn = false);

      // DON'T show success immediately
      // Instead, poll the backend to check if the subscription is now active
      _checkPaymentStatus();
    }
  }

  Future<void> _checkPaymentStatus() async {
    try {
      // Check if the subscription status is now 'active'
      // You need to call GET /api/CoachWorkspace/trainees or similar
      // to check if the subscription status changed

      // For now, wait a few seconds then check subscription status
      await Future.delayed(Duration(seconds: 3));

      // If subscription is active, show success
      _showSuccessModal();
    } catch (e) {
      print("Error checking payment: $e");
    }
  }

  Future<void> _handlePayment() async {
    setState(() => _isProcessing = true);

    try {
      String? paymentUrl;

      // Handle program subscription
      if (widget.paymentType == 'program') {
        final response = await ApiService.createProgramSubscription(
          programId: widget.programId!, // programName holds the ID
          successUrl: "fitapp://programs/payment-success",
          cancelUrl: "fitapp://programs/payment-cancel",
        );
        print("📦 Full API Response: $response"); // Add this debug line
        paymentUrl =
            response['data']?['checkoutUrl'] ??
            response['checkoutUrl'] ??
            response['url'];
      }
      // Handle store checkout
      else if (widget.paymentType == 'store') {
        List<Map<String, dynamic>>? itemsList;
        if (widget.cartItems != null) {
          itemsList = widget.cartItems!.map((item) {
            return {'productId': item.product.id, 'quantity': item.quantity};
          }).toList();
        }

        final response = await ApiService.createOrderCheckout(
          paymentType: widget.paymentType,
          items: itemsList,
          successUrl: "fitapp://store/payment-success",
          cancelUrl: "fitapp://store/payment-cancel",
        );
        paymentUrl =
            response['paymentUrl'] ??
            response['url'] ??
            (response['data'] != null
                ? response['data']['paymentUrl'] ?? response['data']['url']
                : null);

        // Clear cart only for store purchases
        bool cleared = await ApiService.clearCart();
        if (cleared) {
          print("✅ Cart cleared successfully.");
        }
      }

      if (paymentUrl == null || paymentUrl.isEmpty) {
        throw 'Payment URL missing from server response.';
      }

      final Uri uri = Uri.parse(paymentUrl);

      // Launch external browser
      if (await canLaunchUrl(uri)) {
        _waitingForPaymentReturn = true;
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not open payment page.';
      }
    } catch (e) {
      print("❌ Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Payment Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  // 5. The Success Modal Logic
  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppColors.cardBackground,
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 80),
                SizedBox(height: 20),
                Text(
                  'Payment Successful!',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  widget.paymentType == 'program'
                      ? 'You are now subscribed to this program!'
                      : 'Your order has been placed and is being processed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.cardTextSecondary,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (widget.paymentType == 'program') {
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.of(context).pop(); // Close PaymentScreen
                      } else {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => StoreScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    child: Text(
                      widget.paymentType == 'program'
                          ? 'Back to Programs'
                          : 'Continue to Store',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              _buildOrderSummary(),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _handlePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: _isProcessing
                      ? CircularProgressIndicator(color: AppColors.textPrimary)
                      : Text(
                          'Complete Payment',
                          style: TextStyle(color: Colors.black),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'ORDER SUMMARY',
              style: TextStyle(
                color: AppColors.cardTextSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16),

          // 👇 ADD THIS FOR PROGRAM SUBSCRIPTION
          if (widget.paymentType == 'program') ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.programName ?? 'Program Subscription',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  Text(
                    '\$${widget.amount.toStringAsFixed(2)}',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            if (widget.duration != null) ...[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Duration: ${widget.duration}',
                      style: TextStyle(
                        color: AppColors.cardTextSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],

          // 👇 EXISTING STORE ITEMS
          if (widget.cartItems != null) ...[
            ...?widget.cartItems?.map(
              (item) => Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.product.name} x${item.quantity}',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    Text(
                      '\$${item.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ],

          Divider(height: 24, color: AppColors.cardBorder),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
              ),
              Text(
                '\$${widget.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
