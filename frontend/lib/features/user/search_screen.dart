import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/design_system.dart';
import '../../core/api/api_client.dart';
import '../../shared/widgets/product_card.dart';

// No need for StateProvider. Track query in widget state.
final searchResultsProvider = FutureProvider.autoDispose.family<List<Product>, String>((ref, query) async {
  if (query.isEmpty) return [];

  try {
    final response = await apiClient.get('/products?search=$query');
    final List<dynamic> data = response.data['products'] ?? response.data;
    return data.map((json) => Product.fromJson(json)).toList();
  } catch (e) {
    return [];
  }
});

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _searchQuery = '';

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
  }

  @override
  Widget build(BuildContext context) {
    final searchResultsAsync = ref.watch(searchResultsProvider(_searchQuery));

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          autofocus: true,
          style: DesignSystem.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Search for products...',
            border: InputBorder.none,
            hintStyle: DesignSystem.bodyLarge.copyWith(color: Colors.grey),
          ),
        ),
        backgroundColor: DesignSystem.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: DesignSystem.primary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, color: DesignSystem.primary),
              onPressed: () {
                _searchController.clear();
                _onSearchChanged('');
              },
            ),
        ],
      ),
      body: _searchQuery.isEmpty
          ? _buildInitialState()
          : searchResultsAsync.when(
              data: (products) => _buildSearchResults(products),
              loading: () => const Center(child: CircularProgressIndicator(color: DesignSystem.primary)),
              error: (err, stack) => Center(child: Text('Error searching products: $err')),
            ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded, size: 80, color: DesignSystem.primary.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text('What are you looking for?', style: DesignSystem.bodyLarge),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildSearchResults(List<Product> products) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_dissatisfied_rounded, size: 80, color: DesignSystem.primary.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            Text('No products found.', style: DesignSystem.bodyLarge),
          ],
        ).animate().fadeIn(),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideY(begin: 0.1);
      },
    );
  }
}
