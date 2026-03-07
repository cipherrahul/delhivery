import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/design_system.dart';
import 'user_management_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        title: Text('Platform Admin', style: DesignSystem.h2),
        backgroundColor: DesignSystem.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_rounded, color: DesignSystem.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPlatformHeader(),
            const SizedBox(height: 32),
            _buildMetricGrid(),
            const SizedBox(height: 40),
            _buildNavigationSection(context),
            const SizedBox(height: 40),
            Text('Recent Platform Events', style: DesignSystem.h2.copyWith(fontSize: 18)),
            const SizedBox(height: 20),
            _buildEventLog(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Systems Normal', style: DesignSystem.bodyMedium.copyWith(color: DesignSystem.success, fontWeight: FontWeight.bold)),
        Text('Global Overview', style: DesignSystem.h1),
      ],
    ).animate().fadeIn().slideX();
  }

  Widget _buildMetricGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildMetricCard('Total Users', '12.4k', Icons.people_rounded, Colors.blue),
        _buildMetricCard('Active Sellers', '840', Icons.store_rounded, Colors.orange),
        _buildMetricCard('Total GMV', '₹1.2Cr', Icons.payments_rounded, DesignSystem.success),
        _buildMetricCard('System Health', '99.9%', Icons.speed_rounded, Colors.purple),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: DesignSystem.premiumCard.copyWith(boxShadow: []),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(label, style: DesignSystem.bodyMedium.copyWith(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: DesignSystem.h2.copyWith(fontSize: 22)),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildNavigationSection(BuildContext context) {
    return Column(
      children: [
        _buildNavLink(
          'User Management',
          'Manage accounts, roles and permissions',
          Icons.manage_accounts_rounded,
          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UserManagementScreen())),
        ),
        const SizedBox(height: 16),
        _buildNavLink(
          'Seller Approvals',
          'Review pending seller applications',
          Icons.verified_user_rounded,
          () {},
        ),
        const SizedBox(height: 16),
        _buildNavLink(
          'System Logs',
          'View real-time backend events',
          Icons.terminal_rounded,
          () {},
        ),
      ],
    );
  }

  Widget _buildNavLink(String title, String sub, IconData icon, VoidCallback onTap) {
    return Container(
      decoration: DesignSystem.premiumCard,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(icon, color: DesignSystem.primary),
        title: Text(title, style: DesignSystem.h2.copyWith(fontSize: 16)),
        subtitle: Text(sub, style: DesignSystem.bodyMedium.copyWith(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildEventLog() {
    return Column(
      children: List.generate(4, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: DesignSystem.accent, shape: BoxShape.circle),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'System: New user registered from Bengaluru',
                  style: DesignSystem.bodyMedium,
                ),
              ),
              Text('2m ago', style: DesignSystem.bodyMedium.copyWith(fontSize: 10)),
            ],
          ),
        );
      }),
    );
  }
}
