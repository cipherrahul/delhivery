import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/design_system.dart';
import '../../shared/widgets/app_button.dart';
import 'signup_screen.dart';
import '../user/home_screen.dart';
import '../seller/seller_dashboard.dart';
import '../admin/admin_dashboard.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: DesignSystem.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: DesignSystem.primary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: DesignSystem.softShadow,
                  ),
                  child: const Icon(
                    Icons.local_shipping_rounded,
                    size: 50,
                    color: DesignSystem.accent,
                  ),
                ),
              ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.bounceOut),
              const SizedBox(height: 40),
              Text(
                'Welcome Back',
                style: DesignSystem.h1,
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue your journey',
                style: DesignSystem.bodyLarge.copyWith(color: DesignSystem.primary.withValues(alpha: 0.5)),
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 12),
              _buildRoleSelector(context),
              const SizedBox(height: 48),
              _buildLabel('Email Address'),
              _buildTextField(
                controller: _emailController,
                hint: 'name@example.com',
                icon: Icons.alternate_email_rounded,
              ),
              const SizedBox(height: 24),
              _buildLabel('Password'),
              _buildTextField(
                controller: _passwordController,
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: DesignSystem.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              AppButton(
                text: 'Sign In',
                isLoading: authState.isLoading,
                onPressed: () async {
                  if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter both email and password')),
                    );
                    return;
                  }
                  try {
                    await ref.read(authProvider.notifier).login(
                      _emailController.text.trim(),
                      _passwordController.text,
                    );
                    if (!mounted) return;
                    
                    final targetRole = ref.read(authProvider).role;
                    Widget targetScreen = const HomeScreen();
                    
                    if (targetRole == 'SELLER') targetScreen = const SellerDashboard();
                    if (targetRole == 'ADMIN') targetScreen = const AdminDashboard();

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => targetScreen),
                    );
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Invalid credentials or network error.', style: TextStyle(color: Colors.white)),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("New to Delhivery? ", style: DesignSystem.bodyMedium),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupScreen()),
                      );
                    },
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        color: DesignSystem.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: DesignSystem.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: PopupMenuButton<String>(
          onSelected: (role) {
            Widget target;
            if (role == 'Seller') {
              target = const SellerDashboard();
            } else if (role == 'Admin') {
              target = const AdminDashboard();
            } else {
              target = const HomeScreen();
            }
            Navigator.push(context, MaterialPageRoute(builder: (context) => target));
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.swap_horiz_rounded, size: 18, color: DesignSystem.primary),
              const SizedBox(width: 8),
              Text('Switch Role (Demo)', style: DesignSystem.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'Customer', child: Text('Customer App')),
            const PopupMenuItem(value: 'Seller', child: Text('Seller Dashboard')),
            const PopupMenuItem(value: 'Admin', child: Text('Admin Panel')),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: DesignSystem.bodyMedium.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: DesignSystem.premiumCard.copyWith(color: Colors.white),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        style: DesignSystem.bodyLarge,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: DesignSystem.primary.withValues(alpha: 0.3)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: DesignSystem.primary.withValues(alpha: 0.3),
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1);
  }
}
