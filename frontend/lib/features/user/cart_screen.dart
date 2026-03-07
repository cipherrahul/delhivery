import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/design_system.dart';
import '../../core/api/api_client.dart';

final cartProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final response = await apiClient.get('/cart');
  return response.data;
});

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        title: Text('My Bag', style: DesignSystem.h2),
        backgroundColor: DesignSystem.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: DesignSystem.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: cartAsync.when(
        data: (cart) => _buildCartContent(context, cart, ref),
        loading: () => const Center(child: CircularProgressIndicator(color: DesignSystem.primary)),
        error: (err, stack) => Center(child: Text('Error loading cart: $err')),
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, Map<String, dynamic> cart, WidgetRef ref) {
    final List items = cart['items'] ?? [];
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 80, color: DesignSystem.primary.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            Text('Your bag is empty', style: DesignSystem.bodyLarge),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: items.length,
            itemBuilder: (context, index) => _buildCartItem(items[index]),
          ),
        ),
        _buildCheckoutSection(context, cart),
      ],
    );
  }

  Widget _buildCartItem(dynamic item) {
    final product = item['product'];
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: DesignSystem.premiumCard,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: product['imageUrl'] ?? '',
              height: 90,
              width: 90,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['name'], style: DesignSystem.bodyLarge, maxLines: 1),
                const SizedBox(height: 8),
                Text('₹${product['price']}', style: DesignSystem.h2.copyWith(fontSize: 18)),
              ],
            ),
          ),
          Column(
            children: [
              _buildQtyBtn(Icons.add_rounded, DesignSystem.primary, Colors.white),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('${item['quantity']}', style: DesignSystem.bodyLarge),
              ),
              _buildQtyBtn(Icons.remove_rounded, DesignSystem.secondary, DesignSystem.primary),
            ],
          ),
        ],
      ),
    ).animate().slideX(begin: 0.2, duration: 400.ms, delay: 100.ms);
  }

  Widget _buildQtyBtn(IconData icon, Color bg, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, size: 18, color: iconColor),
    );
  }

  Widget _buildCheckoutSection(BuildContext context, Map<String, dynamic> cart) {
    final double total = (cart['total'] ?? 0).toDouble();
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: DesignSystem.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: DesignSystem.softShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount', style: TextStyle(color: Colors.white70, fontSize: 16)),
              Text('₹${total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.accent,
              foregroundColor: DesignSystem.primary,
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: const Text('Checkout Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ],
      ),
    ).animate().slideY(begin: 1, duration: 600.ms, curve: Curves.easeOutCubic);
  }
}
