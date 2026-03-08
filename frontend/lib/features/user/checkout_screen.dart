import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/design_system.dart';
import '../../core/api/api_client.dart';
import '../../shared/widgets/app_button.dart';
import 'home_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> cartData;

  const CheckoutScreen({super.key, required this.cartData});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _isProcessing = false;
  final TextEditingController _addressController = TextEditingController(text: '123 Main St, Tech Park, Bengaluru');

  void _placeOrder() async {
    setState(() => _isProcessing = true);
    try {
      final items = (widget.cartData['items'] as List).map((item) {
        return {
          'productId': item['productId'],
          'quantity': item['quantity'],
          'price': item['product']['price'],
        };
      }).toList();

      final total = widget.cartData['total'];

      await apiClient.post('/orders', data: {
        'items': items,
        'total': total,
      });

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildSuccessDialog(),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to place order. Please try again.', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      setState(() => _isProcessing = false);
    }
  }

  Widget _buildSuccessDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: DesignSystem.success, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
            ).animate().scale(curve: Curves.elasticOut, duration: 800.ms),
            const SizedBox(height: 24),
            Text('Order Confirmed!', style: DesignSystem.h2),
            const SizedBox(height: 8),
            Text(
              'Your items will be delivered soon.',
              textAlign: TextAlign.center,
              style: DesignSystem.bodyMedium,
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Continue Shopping',
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double total = (widget.cartData['total'] ?? 0).toDouble();

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        title: Text('Checkout', style: DesignSystem.h2),
        backgroundColor: DesignSystem.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: DesignSystem.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Shipping Address', style: DesignSystem.h2.copyWith(fontSize: 18)),
            const SizedBox(height: 16),
            Container(
              decoration: DesignSystem.premiumCard,
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: const Icon(Icons.location_on_rounded, color: DesignSystem.primary),
                  hintText: 'Enter full address',
                ),
              ),
            ).animate().fadeIn().slideX(begin: 0.1),
            const SizedBox(height: 32),
            Text('Payment Method', style: DesignSystem.h2.copyWith(fontSize: 18)),
            const SizedBox(height: 16),
            Container(
              decoration: DesignSystem.premiumCard.copyWith(
                border: Border.all(color: DesignSystem.accent, width: 2),
              ),
              child: ListTile(
                leading: const Icon(Icons.money_rounded, color: DesignSystem.accent),
                title: Text('Cash on Delivery', style: DesignSystem.h2.copyWith(fontSize: 16)),
                trailing: const Icon(Icons.check_circle_rounded, color: DesignSystem.accent),
              ),
            ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: DesignSystem.primary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: DesignSystem.softShadow,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total to Pay', style: TextStyle(color: Colors.white70, fontSize: 16)),
                      Text('₹${total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    text: 'Confirm Order',
                    isLoading: _isProcessing,
                    onPressed: _placeOrder,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }
}
