import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(DesignSystem.accent),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: DesignSystem.bodyMedium.copyWith(
                color: DesignSystem.primary.withValues(alpha: 0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
