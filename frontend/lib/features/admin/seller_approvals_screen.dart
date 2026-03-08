import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/design_system.dart';
import '../../core/api/api_client.dart';

final pendingSellersProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final response = await apiClient.get('/admin/sellers/pending');
  return response.data;
});

class SellerApprovalsScreen extends ConsumerWidget {
  const SellerApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellersAsync = ref.watch(pendingSellersProvider);

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        title: Text('Pending Approvals', style: DesignSystem.h2),
        backgroundColor: DesignSystem.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: DesignSystem.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: sellersAsync.when(
        data: (sellers) {
          if (sellers.isEmpty) {
            return _buildEmptyState();
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(pendingSellersProvider),
            color: DesignSystem.accent,
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: sellers.length,
              itemBuilder: (context, index) => _buildSellerCard(context, ref, sellers[index]),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: DesignSystem.primary)),
        error: (err, stack) => Center(child: Text('Error loading sellers: $err')),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_user_rounded, size: 80, color: DesignSystem.primary.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text('No pending approvals', style: DesignSystem.bodyLarge),
          const SizedBox(height: 8),
          Text('All seller accounts have been processed.', style: DesignSystem.bodyMedium),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildSellerCard(BuildContext context, WidgetRef ref, dynamic seller) {
    final isProcessing = false; // Add stateful wrapper if needed for spinner per item

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: DesignSystem.premiumCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DesignSystem.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.store_rounded, color: DesignSystem.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(seller['storeName'] ?? 'Unknown Store', style: DesignSystem.h2.copyWith(fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(seller['user']['name'] ?? 'Unknown Owner', style: DesignSystem.bodyMedium),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('PENDING', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: DesignSystem.secondary),
          const SizedBox(height: 16),
          _buildInfoRow('Email', seller['user']['email'] ?? 'N/A'),
          const SizedBox(height: 8),
          _buildInfoRow('Phone', seller['user']['phone'] ?? 'N/A'),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Rejection flow coming soon!', style: TextStyle(color: Colors.white)),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await apiClient.patch('/admin/sellers/${seller['id']}/verify');
                      ref.invalidate(pendingSellersProvider);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Seller verified successfully!', style: TextStyle(color: Colors.white)),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: DesignSystem.success,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Error verifying seller.', style: TextStyle(color: Colors.white)),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.primary,
                    foregroundColor: DesignSystem.accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Approve Store', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1);
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: DesignSystem.bodyMedium),
        Text(value, style: DesignSystem.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
