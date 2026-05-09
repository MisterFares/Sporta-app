// ignore_for_file: deprecated_member_use
import 'package:fit/classes/store/cart_item.dart';
import 'package:fit/styles/colors.dart';
import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  final String paymentType; // 'program' or 'store'
  final double amount;
  final String? programName;
  final String? coachName;
  final String? duration;
  final String? level;
  final List<CartItem>? cartItems; // For store items

  const PaymentScreen({
    super.key,
    required this.paymentType,
    required this.amount,
    this.programName,
    this.coachName,
    this.duration,
    this.level,
    this.cartItems,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'card';
  String _selectedWalletProvider = 'Vodafone';

  // For Cash on Delivery (Store items only)
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  // Form controllers for card/wallet
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardExpiryController = TextEditingController();
  final TextEditingController _cardCvvController = TextEditingController();
  final TextEditingController _walletNumberController = TextEditingController();

  // Validation states
  bool _cardNameValid = true;
  bool _cardNumberValid = true;
  bool _cardExpiryValid = true;
  bool _cardCvvValid = true;
  bool _walletNumberValid = true;

  // COD validation states
  bool _fullNameValid = true;
  bool _phoneValid = true;
  bool _addressValid = true;
  bool _cityValid = true;

  bool _isProcessing = false;

  @override
  void dispose() {
    _cardNameController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _walletNumberController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Column(
                  children: [
                    _buildOrderSummary(),
                    const SizedBox(height: 32),
                    _buildPaymentSection(),
                  ],
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ORDER SUMMARY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.cardTextSecondary,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 16),

          if (widget.paymentType == 'program') ...[
            // Program Preview
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    border: Border.all(color: AppColors.cardBorder),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    size: 24,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.programName ?? 'Program',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Color(0xFF444444),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.coachName ?? 'Coach',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSummaryRow('Duration', widget.duration ?? 'N/A'),
            const SizedBox(height: 12),
            _buildSummaryRow('Level', widget.level ?? 'N/A'),
          ] else ...[
            // Store Items Preview
            ...?widget.cartItems?.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.product.name} x${item.quantity}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      '\$${item.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.cartItems != null && widget.cartItems!.isNotEmpty)
              const SizedBox(height: 12),
          ],

          _buildSummaryRow('Subtotal', '\$${widget.amount.toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          Container(height: 1, color: AppColors.cardBackground),
          const SizedBox(height: 16),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                '\$${widget.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          if (widget.paymentType == 'program') ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: '100% Satisfaction Guarantee.\n',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            text: 'Full refund available within 7 days.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.cardTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.cardTextSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    // Determine payment methods based on type
    final List<Map<String, dynamic>> paymentMethods = [
      {'icon': Icons.credit_card, 'name': 'Credit Card', 'method': 'card'},
      {'icon': Icons.smartphone, 'name': 'Mobile Wallet', 'method': 'wallet'},
    ];

    if (widget.paymentType == 'store') {
      paymentMethods.add({
        'icon': Icons.local_shipping,
        'name': 'Cash on Delivery',
        'method': 'cod',
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Payment Method',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.paymentType == 'program'
              ? 'Choose how you\'d like to pay for your subscription.'
              : 'Choose how you\'d like to pay for your items.',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.cardTextSecondary,
          ),
        ),
        const SizedBox(height: 32),

        // Payment Methods Grid - Responsive
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            // Calculate if we should use column or row
            final useColumn = width < 400 && paymentMethods.length > 2;

            if (useColumn) {
              return Column(
                children: paymentMethods
                    .map(
                      (method) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildMethodCard(
                          icon: method['icon'] as IconData,
                          name: method['name'] as String,
                          method: method['method'] as String,
                        ),
                      ),
                    )
                    .toList(),
              );
            }

            return Row(
              children: paymentMethods.asMap().entries.map((entry) {
                final index = entry.key;
                final method = entry.value;
                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildMethodCard(
                          icon: method['icon'] as IconData,
                          name: method['name'] as String,
                          method: method['method'] as String,
                        ),
                      ),
                      if (index < paymentMethods.length - 1)
                        const SizedBox(width: 12),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),

        const SizedBox(height: 32),

        // Dynamic Form
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _selectedMethod == 'card'
              ? _buildCardForm()
              : _selectedMethod == 'wallet'
              ? _buildWalletForm()
              : _buildCashOnDeliveryForm(),
        ),

        const SizedBox(height: 32),

        // Action Buttons
        _buildActionButtons(),

        const SizedBox(height: 24),

        // Terms
        Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'By confirming, you agree to Sporta\'s ',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.cardTextSecondary,
                  ),
                ),
                TextSpan(
                  text: 'Terms of Service',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodCard({
    required IconData icon,
    required String name,
    required String method,
  }) {
    final isActive = _selectedMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.cardBorder,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? AppColors.primary : AppColors.cardTextSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.cardTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashOnDeliveryForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          _buildCODTextField(
            controller: _fullNameController,
            label: 'Full Name',
            icon: Icons.person_outline,
            isValid: _fullNameValid,
            errorText: 'Please enter your full name',
            onChanged: (value) {
              setState(() {
                _fullNameValid = value.trim().isNotEmpty;
              });
            },
          ),
          const SizedBox(height: 16),

          _buildCODTextField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            isValid: _phoneValid,
            errorText: 'Please enter a valid phone number',
            keyboardType: TextInputType.phone,
            onChanged: (value) {
              setState(() {
                _phoneValid = value.trim().length >= 10;
              });
            },
          ),
          
          const SizedBox(height: 16),

          _buildCODTextField(
            controller: _addressController,
            label: 'Street Address',
            icon: Icons.location_on_outlined,
            isValid: _addressValid,
            errorText: 'Please enter your address',
            onChanged: (value) {
              setState(() {
                _addressValid = value.trim().isNotEmpty;
              });
            },
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildCODTextField(
                  controller: _cityController,
                  label: 'City',
                  icon: Icons.location_city,
                  isValid: _cityValid,
                  errorText: 'Required',
                  onChanged: (value) {
                    setState(() {
                      _cityValid = value.trim().isNotEmpty;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCODTextField(
                  controller: _postalCodeController,
                  label: 'Postal Code',
                  icon: Icons.mail_outline,
                  isValid: true,
                  errorText: '',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {},
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pay when your order arrives. No additional fees.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.cardTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCODTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isValid,
    required String errorText,
    TextInputType keyboardType = TextInputType.text,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.cardTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              size: 18,
              color: AppColors.cardTextSecondary,
            ),
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.red),
            ),
            errorText: isValid ? null : errorText,
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildCardForm() {
    // Keep your existing card form code
    return Column(
      children: [
        _buildFormField(
          label: 'Cardholder Name',
          icon: Icons.person_outline,
          controller: _cardNameController,
          isValid: _cardNameValid,
          errorText: 'Name is required',
          onChanged: (value) {
            setState(() {
              _cardNameValid = value.length > 2;
            });
          },
        ),
        const SizedBox(height: 20),
        _buildFormField(
          label: 'Card Number',
          icon: Icons.credit_card,
          controller: _cardNumberController,
          isValid: _cardNumberValid,
          errorText: 'Please enter a valid 16-digit card number',
          keyboardType: TextInputType.number,
          maxLength: 19,
          onChanged: (value) {
            String formatted = value.replaceAll(RegExp(r'\s'), '');
            formatted = formatted.replaceAll(RegExp(r'\D'), '');
            if (formatted.length > 16) {
              formatted = formatted.substring(0, 16);
            }
            final buffer = StringBuffer();
            for (int i = 0; i < formatted.length; i++) {
              if (i > 0 && i % 4 == 0) {
                buffer.write(' ');
              }
              buffer.write(formatted[i]);
            }
            _cardNumberController.value = TextEditingValue(
              text: buffer.toString(),
              selection: TextSelection.collapsed(offset: buffer.length),
            );
            setState(() {
              _cardNumberValid = formatted.length == 16;
            });
          },
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildFormField(
                label: 'Expiry Date',
                icon: Icons.calendar_today,
                controller: _cardExpiryController,
                isValid: _cardExpiryValid,
                errorText: 'Invalid date',
                placeholder: 'MM/YY',
                maxLength: 5,
                onChanged: (value) {
                  String formatted = value.replaceAll(RegExp(r'[^0-9]'), '');
                  if (formatted.length >= 2) {
                    formatted =
                        '${formatted.substring(0, 2)}/${formatted.substring(2, formatted.length > 4 ? 4 : formatted.length)}';
                  }
                  if (formatted != value && formatted.length <= 5) {
                    _cardExpiryController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(
                        offset: formatted.length,
                      ),
                    );
                  }
                  setState(() {
                    _cardExpiryValid = RegExp(
                      r'^(0[1-9]|1[0-2])\/\d{2}$',
                    ).hasMatch(_cardExpiryController.text);
                  });
                },
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildFormField(
                label: 'CVV',
                icon: Icons.lock_outline,
                controller: _cardCvvController,
                isValid: _cardCvvValid,
                errorText: 'Required (3-4 digits)',
                keyboardType: TextInputType.number,
                maxLength: 4,
                onChanged: (value) {
                  setState(() {
                    _cardCvvValid = RegExp(r'^\d{3,4}$').hasMatch(value);
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWalletForm() {
    // Keep your existing wallet form code
    return Column(
      children: [
        const Text(
          'Select Provider',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.cardTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildWalletProviderCard('Vodafone', AppColors.vodafone),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildWalletProviderCard('Orange', AppColors.orange),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Please enter your ',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.cardTextSecondary,
                  ),
                ),
                TextSpan(
                  text: '$_selectedWalletProvider Cash',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const TextSpan(
                  text:
                      ' number below.\nYou will be redirected to complete the payment securely.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.cardTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildFormField(
          label: 'Wallet Number',
          icon: Icons.smartphone,
          controller: _walletNumberController,
          isValid: _walletNumberValid,
          errorText: 'Must be a valid 11-digit number starting with 01',
          keyboardType: TextInputType.phone,
          maxLength: 11,
          onChanged: (value) {
            String cleaned = value.replaceAll(RegExp(r'\D'), '');
            if (cleaned.length > 11) {
              cleaned = cleaned.substring(0, 11);
            }
            if (cleaned != value) {
              _walletNumberController.value = TextEditingValue(
                text: cleaned,
                selection: TextSelection.collapsed(offset: cleaned.length),
              );
            }
            setState(() {
              _walletNumberValid = RegExp(r'^01\d{9}$').hasMatch(cleaned);
            });
          },
        ),
      ],
    );
  }

  Widget _buildWalletProviderCard(String provider, Color dotColor) {
    final isSelected = _selectedWalletProvider == provider;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedWalletProvider = provider;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              provider,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.cardTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required bool isValid,
    required String errorText,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    String? placeholder,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.cardTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          obscureText: label == 'CVV',
          style: const TextStyle(fontSize: 15, color: Colors.white),
          decoration: InputDecoration(
            counterText: '',
            prefixIcon: Icon(
              icon,
              size: 18,
              color: AppColors.cardTextSecondary,
            ),
            hintText: placeholder ?? '',
            hintStyle: const TextStyle(
              fontSize: 15,
              color: AppColors.cardTextSecondary,
            ),
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.red),
            ),
            errorText: isValid ? null : errorText,
            errorStyle: const TextStyle(fontSize: 12, color: AppColors.red),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              elevation: 0,
            ),
            child: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 18,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.paymentType == 'program'
                            ? 'Confirm & Subscribe \$${widget.amount.toStringAsFixed(2)}'
                            : _selectedMethod == 'cod'
                            ? 'Place Order \$${widget.amount.toStringAsFixed(2)}'
                            : 'Pay \$${widget.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.cardTextSecondary,
              side: const BorderSide(color: AppColors.cardBorder),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_back, size: 18),
                SizedBox(width: 8),
                Text(
                  'Go Back',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _processPayment() async {
    // Validate based on payment method
    if (_selectedMethod == 'card') {
      if (!_cardNameValid ||
          !_cardNumberValid ||
          !_cardExpiryValid ||
          !_cardCvvValid) {
        _showErrorDialog('Please fill all card fields correctly');
        return;
      }
    } else if (_selectedMethod == 'wallet') {
      if (!_walletNumberValid) {
        _showErrorDialog('Please enter a valid wallet number');
        return;
      }
    } else if (_selectedMethod == 'cod') {
      if (!_fullNameValid ||
          !_phoneValid ||
          !_addressValid ||
          !_cityValid) {
        _showErrorDialog('Please fill all delivery information correctly');
        return;
      }
    }

    setState(() {
      _isProcessing = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isProcessing = false;
    });

    _showSuccessDialog();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Error', style: TextStyle(color: AppColors.red)),
        content: Text(message, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    final successMessage = widget.paymentType == 'program'
        ? 'Payment successful! You are now subscribed to the program.'
        : _selectedMethod == 'cod'
        ? 'Order placed successfully! You will pay upon delivery.'
        : 'Payment successful! Your order has been confirmed.';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.greeen, size: 20),
            SizedBox(width: 8),
            Text('Success!', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          successMessage,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back
              if (widget.paymentType == 'store') {
                // Navigate to orders screen or clear cart
              }
            },
            child: const Text(
              'Continue',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
