import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/design_system.dart';
import '../../shared/widgets/product_card.dart';

import '../../core/api/api_client.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool _isFavorite = false;
  bool _isAddingToCart = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: DesignSystem.accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.product.category.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: DesignSystem.accent, size: 20),
                          const SizedBox(width: 4),
                          Text('4.8 (120 reviews)', style: DesignSystem.bodyMedium),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(widget.product.name, style: DesignSystem.h1),
                  const SizedBox(height: 16),
                  Text(
                    '₹${widget.product.price.toStringAsFixed(0)}',
                    style: DesignSystem.h2.copyWith(fontSize: 32, color: DesignSystem.primary),
                  ),
                  const SizedBox(height: 32),
                  Text('Description', style: DesignSystem.h2.copyWith(fontSize: 18)),
                  const SizedBox(height: 12),
                  Text(
                    widget.product.description,
                    style: DesignSystem.bodyLarge.copyWith(
                      color: DesignSystem.primary.withValues(alpha: 0.6),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 120), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomAction(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 400,
      backgroundColor: DesignSystem.secondary,
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'product_${widget.product.id}',
          child: CachedNetworkImage(
            imageUrl: widget.product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: DesignSystem.primary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: _isFavorite ? Colors.redAccent : DesignSystem.primary,
              ),
              onPressed: () {
                setState(() => _isFavorite = !_isFavorite);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isFavorite ? 'Saved to Favorites' : 'Removed from Favorites', style: const TextStyle(color: Colors.white)),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: DesignSystem.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: DesignSystem.softShadow,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: DesignSystem.premiumCard.copyWith(color: DesignSystem.secondary),
            child: const Icon(Icons.shopping_bag_outlined, color: DesignSystem.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isAddingToCart ? null : () async {
                setState(() => _isAddingToCart = true);
                try {
                  await apiClient.post('/cart', data: {
                    'productId': widget.product.id,
                    'quantity': 1,
                  });
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Added to Cart securely!', style: TextStyle(color: Colors.white)),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: DesignSystem.success,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Failed to add to cart.', style: TextStyle(color: Colors.white)),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                } finally {
                  if (mounted) setState(() => _isAddingToCart = false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.primary,
                foregroundColor: DesignSystem.accent,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isAddingToCart
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: DesignSystem.accent))
                  : const Text('Add to Cart', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 1, duration: 600.ms, curve: Curves.easeOutCubic);
  }
}
