import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/design_system.dart';
import 'add_product_screen.dart';

class SellerDashboard extends StatelessWidget {
  const SellerDashboard({super.key});

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!', style: const TextStyle(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: DesignSystem.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        title: Text('Seller Central', style: DesignSystem.h2),
        backgroundColor: DesignSystem.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: DesignSystem.primary),
            onPressed: () => _showComingSoon(context, 'Notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: DesignSystem.primary),
            onPressed: () => _showComingSoon(context, 'Settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 32),
            _buildActionCards(context),
            const SizedBox(height: 40),
            Text('Quick Statistics', style: DesignSystem.h2.copyWith(fontSize: 18)),
            const SizedBox(height: 20),
            _buildStatsGrid(),
            const SizedBox(height: 40),
            Text('Recent Activities', style: DesignSystem.h2.copyWith(fontSize: 18)),
            const SizedBox(height: 20),
            _buildActivityList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProductScreen())),
        backgroundColor: DesignSystem.primary,
        icon: const Icon(Icons.add_rounded, color: DesignSystem.accent),
        label: const Text('Add Product', style: TextStyle(color: DesignSystem.accent, fontWeight: FontWeight.bold)),
      ).animate().scale(delay: 500.ms),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hello, Premium Seller', style: DesignSystem.bodyMedium),
        Text('Business Overview', style: DesignSystem.h1),
      ],
    ).animate().fadeIn().slideX();
  }

  Widget _buildActionCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildSmallActionCard(
            label: 'Total Orders',
            value: '1,240',
            icon: Icons.shopping_basket_rounded,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSmallActionCard(
            label: 'Total Revenue',
            value: '₹8.2L',
            icon: Icons.account_balance_wallet_rounded,
            color: DesignSystem.success,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallActionCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: DesignSystem.premiumCard.copyWith(
        color: color.withValues(alpha: 0.1),
        boxShadow: [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Text(value, style: DesignSystem.h2.copyWith(fontSize: 22, color: color)),
          Text(label, style: DesignSystem.bodyMedium.copyWith(fontSize: 12)),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildMiniStat('Active Products', '42', Icons.inventory_2_rounded),
        _buildMiniStat('Pending Orders', '12', Icons.pending_actions_rounded),
        _buildMiniStat('Low Stock', '5', Icons.warning_amber_rounded),
        _buildMiniStat('Store Rating', '4.9', Icons.star_rounded),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: DesignSystem.premiumCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: DesignSystem.primary.withValues(alpha: 0.5)),
              const SizedBox(width: 8),
              Text(label, style: DesignSystem.bodyMedium.copyWith(fontSize: 10)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: DesignSystem.h2.copyWith(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: DesignSystem.premiumCard,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: DesignSystem.secondary,
              child: const Icon(Icons.history_rounded, color: DesignSystem.primary),
            ),
            title: Text('New order received #8902$index', style: DesignSystem.bodyLarge),
            subtitle: Text('2 mins ago', style: DesignSystem.bodyMedium),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
          ),
        );
      }),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2);
  }
}
