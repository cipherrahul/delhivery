import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/design_system.dart';
import '../../shared/widgets/app_button.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        title: Text('List New Product', style: DesignSystem.h2),
        backgroundColor: DesignSystem.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: DesignSystem.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader('1', 'Visual Identity'),
            const SizedBox(height: 20),
            _buildImageUploadArea(),
            const SizedBox(height: 40),
            _buildStepHeader('2', 'Product Details'),
            const SizedBox(height: 24),
            _buildLabel('Product Name'),
            _buildTextField(_nameController, 'e.g. Nike Air Max', Icons.edit_rounded),
            const SizedBox(height: 24),
            _buildLabel('Description'),
            _buildTextField(_descController, 'Write a compelling story...', Icons.description_outlined, maxLines: 4),
            const SizedBox(height: 40),
            _buildStepHeader('3', 'Pricing & Inventory'),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Price (₹)'),
                    _buildTextField(_priceController, '2999', Icons.currency_rupee_rounded),
                  ],
                )),
                const SizedBox(width: 20),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Stock'),
                    _buildTextField(_stockController, '50', Icons.inventory_2_outlined),
                  ],
                )),
              ],
            ),
            const SizedBox(height: 60),
            AppButton(
              text: 'Publish to Marketplace',
              onPressed: () {
                // Implement publish logic
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStepHeader(String step, String title) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(color: DesignSystem.primary, shape: BoxShape.circle),
          child: Center(child: Text(step, style: const TextStyle(color: DesignSystem.accent, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(width: 12),
        Text(title, style: DesignSystem.h2.copyWith(fontSize: 18)),
      ],
    );
  }

  Widget _buildImageUploadArea() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: DesignSystem.secondary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: DesignSystem.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_outlined, size: 48, color: DesignSystem.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text('Upload HD Images', style: DesignSystem.bodyMedium),
          Text('Recommended size 1080x1080', style: DesignSystem.bodyMedium.copyWith(fontSize: 10)),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(text, style: DesignSystem.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {int maxLines = 1}) {
    return Container(
      decoration: DesignSystem.premiumCard.copyWith(color: Colors.white),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: DesignSystem.primary.withValues(alpha: 0.3)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }
}
