import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/design_system.dart';
import '../../shared/widgets/app_button.dart';
import '../user/home_screen.dart';
import 'auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: DesignSystem.primary),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Account',
                style: DesignSystem.h1,
              ).animate().fadeIn(),
              const SizedBox(height: 8),
              Text(
                'Join our premium logistics network today',
                style: DesignSystem.bodyLarge.copyWith(color: DesignSystem.primary.withValues(alpha: 0.5)),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 48),
              _buildLabel('Full Name'),
              _buildTextField(
                controller: _nameController,
                hint: 'John Doe',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 24),
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
              const SizedBox(height: 48),
              AppButton(
                text: 'Create Account',
                isLoading: authState.isLoading,
                onPressed: () async {
                  if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                    return;
                  }
                  try {
                    await ref.read(authProvider.notifier).signup(
                      _nameController.text.trim(),
                      _emailController.text.trim(),
                      _passwordController.text,
                    );
                    if (!mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                      (route) => false,
                    );
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Signup Failed: ${e.toString().replaceAll('Exception: ', '')}', style: const TextStyle(color: Colors.white)),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Text('By signing up, you agree to our', style: DesignSystem.bodyMedium),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLink('Terms of Service'),
                        Text(' and ', style: DesignSystem.bodyMedium),
                        _buildLink('Privacy Policy'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
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
    ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1);
  }

  Widget _buildLink(String text) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        text,
        style: TextStyle(
          color: DesignSystem.accent,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
