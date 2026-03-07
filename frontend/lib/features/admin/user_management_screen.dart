import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/design_system.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        title: Text('User Management', style: DesignSystem.h2),
        backgroundColor: DesignSystem.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: DesignSystem.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterTabs(),
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        decoration: DesignSystem.premiumCard.copyWith(color: Colors.white),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search by name or email...',
            prefixIcon: Icon(Icons.search_rounded, color: DesignSystem.primary.withValues(alpha: 0.3)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _FilterChip(label: 'All Users', isSelected: true),
          _FilterChip(label: 'Sellers', isSelected: false),
          _FilterChip(label: 'Customers', isSelected: false),
          _FilterChip(label: 'Suspended', isSelected: false),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: DesignSystem.premiumCard,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: DesignSystem.secondary,
              child: Text('U${index}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            title: Text('User Profile $index', style: DesignSystem.h2.copyWith(fontSize: 16)),
            subtitle: Text('user$index@example.com', style: DesignSystem.bodyMedium),
            trailing: PopupMenuButton(
              icon: const Icon(Icons.more_vert_rounded),
              itemBuilder: (context) => [
                const PopupMenuItem(child: Text('View Details')),
                const PopupMenuItem(child: Text('Change Role')),
                const PopupMenuItem(child: Text('Suspend Account', style: TextStyle(color: DesignSystem.error))),
              ],
            ),
          ),
        );
      },
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2);
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _FilterChip({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? DesignSystem.primary : DesignSystem.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? DesignSystem.accent : DesignSystem.primary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
