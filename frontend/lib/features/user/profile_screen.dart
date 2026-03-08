import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/design_system.dart';
import '../auth/auth_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final String name = authState.name ?? 'Valued Customer';
    final String email = authState.email ?? 'Loading profile data...';
    final String role = authState.role ?? 'USER';

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        title: Text('My Profile', style: DesignSystem.h2),
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
          children: [
            _buildProfileHeader(name, email, role),
            const SizedBox(height: 40),
            _buildSectionHeader('Account Settings'),
            const SizedBox(height: 16),
            _buildSettingsMenu(context),
            const SizedBox(height: 16),
            _buildSectionHeader('Preferences'),
            const SizedBox(height: 16),
            _buildPreferencesMenu(context),
            const SizedBox(height: 40),
            _buildLogoutButton(context, ref),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String name, String email, String role) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: DesignSystem.premiumCard.copyWith(
        color: DesignSystem.primary,
        boxShadow: DesignSystem.softShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: DesignSystem.accent,
            child: Text(
              name.substring(0, 1).toUpperCase(),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: DesignSystem.primary),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(email, style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7))),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: DesignSystem.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: DesignSystem.accent.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    role,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: DesignSystem.accent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: DesignSystem.h2.copyWith(fontSize: 18)),
    ).animate().fadeIn();
  }

  Widget _buildSettingsMenu(BuildContext context) {
    return Container(
      decoration: DesignSystem.premiumCard,
      child: Column(
        children: [
          _buildMenuTile(context, Icons.location_on_outlined, 'Delivery Addresses'),
          _buildDivider(),
          _buildMenuTile(context, Icons.payment_outlined, 'Payment Methods'),
          _buildDivider(),
          _buildMenuTile(context, Icons.history_rounded, 'Order History'),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildPreferencesMenu(BuildContext context) {
    return Container(
      decoration: DesignSystem.premiumCard,
      child: Column(
        children: [
          _buildMenuTile(context, Icons.notifications_none_rounded, 'Notifications'),
          _buildDivider(),
          _buildMenuTile(context, Icons.language_rounded, 'Language (English)'),
          _buildDivider(),
          _buildMenuTile(context, Icons.help_outline_rounded, 'Help & Support'),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildMenuTile(BuildContext context, IconData icon, String title) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: DesignSystem.secondary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: DesignSystem.primary),
      ),
      title: Text(title, style: DesignSystem.bodyLarge),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title coming soon!', style: const TextStyle(color: Colors.white)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: DesignSystem.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 64, color: DesignSystem.secondary);
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        ref.read(authProvider.notifier).logout();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
        foregroundColor: Colors.redAccent,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    ).animate().fadeIn(delay: 300.ms);
  }
}
