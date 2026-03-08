import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/design_system.dart';
import '../../core/api/api_client.dart';
import '../../shared/widgets/product_card.dart';
import 'cart_screen.dart' as cart;
import 'profile_screen.dart';
import 'search_screen.dart';

final productsProvider = FutureProvider<List<Product>>((ref) async {
  try {
    final response = await apiClient.get('/products');
    final List<dynamic> data = response.data;
    return data.map((json) => Product.fromJson(json)).toList();
  } catch (e) {
    return [];
  }
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedCategory = 'All';
  int _currentIndex = 0;

  void _showComingSoon(String feature) {
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

  void _onNavTapped(int index) {
    if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const cart.CartScreen()));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
    } else {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: DesignSystem.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPromoBanner(),
                _buildSectionHeader('Top Categories'),
                _buildCategoryList(),
                _buildSectionHeader('Featured Products'),
              ],
            ),
          ),
          _buildProductGrid(productsAsync),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.refresh(productsProvider),
        backgroundColor: DesignSystem.accent,
        child: const Icon(Icons.refresh_rounded, color: DesignSystem.primary),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: DesignSystem.background,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(color: DesignSystem.background),
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: DesignSystem.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.local_shipping_rounded, size: 18, color: DesignSystem.accent),
            ),
            const SizedBox(width: 12),
            Text('Delhivery', style: DesignSystem.h2.copyWith(fontSize: 20)),
          ],
        ),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.search_rounded, color: DesignSystem.primary), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen()))),
        IconButton(icon: const Icon(Icons.notifications_none_rounded, color: DesignSystem.primary), onPressed: () => _showComingSoon('Notifications')),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: DesignSystem.h2.copyWith(fontSize: 18)),
          Text('View All', style: DesignSystem.bodyMedium.copyWith(color: DesignSystem.accent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: DesignSystem.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: DesignSystem.softShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            bottom: -30,
            child: Icon(Icons.shopping_bag_outlined, size: 200, color: Colors.white.withValues(alpha: 0.05)),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'UP TO 50% OFF',
                  style: TextStyle(color: DesignSystem.accent, fontWeight: FontWeight.w900, letterSpacing: 2),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Premium Collection',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showComingSoon('Premium Collection'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.accent,
                    foregroundColor: DesignSystem.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Shop Now', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ).animate().slideX(begin: 0.1, duration: 600.ms, curve: Curves.easeOutCubic).fadeIn(),
    );
  }

  Widget _buildCategoryList() {
    final categories = ['All', 'Electronics', 'Fashion', 'Home', 'Audio'];
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = categories[index] == _selectedCategory;
          return AnimatedContainer(
            duration: 300.ms,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: ChoiceChip(
              label: Text(categories[index]),
              selected: isSelected,
              onSelected: (val) {
                if (val) setState(() => _selectedCategory = categories[index]);
              },
              selectedColor: DesignSystem.primary,
              labelStyle: TextStyle(
                color: isSelected ? DesignSystem.accent : DesignSystem.primary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: DesignSystem.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(AsyncValue<List<Product>> productsAsync) {
    return productsAsync.when(
      data: (products) => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => ProductCard(product: products[index]),
            childCount: products.length,
          ),
        ),
      ),
      loading: () => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildShimmerCard(),
            childCount: 4,
          ),
        ),
      ),
      error: (err, stack) => SliverToBoxAdapter(
        child: Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 90,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DesignSystem.primary,
        borderRadius: BorderRadius.circular(30),
        boxShadow: DesignSystem.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: _onNavTapped,
          selectedItemColor: DesignSystem.accent,
          unselectedItemColor: Colors.white.withValues(alpha: 0.5),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_outline_rounded), label: 'Fav'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Cart'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
          ],
        ),
      ),
    ).animate().slideY(begin: 1, duration: 800.ms, curve: Curves.easeOutBack);
  }
}
