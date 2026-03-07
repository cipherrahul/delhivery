import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_button.dart';

class ShipmentUpdateScreen extends StatefulWidget {
  final String shipmentId;
  const ShipmentUpdateScreen({super.key, required this.shipmentId});

  @override
  State<ShipmentUpdateScreen> createState() => _ShipmentUpdateScreenState();
}

class _ShipmentUpdateScreenState extends State<ShipmentUpdateScreen> {
  String _currentStatus = 'PICKED_UP';
  final List<String> _statuses = ['PICKED_UP', 'IN_TRANSIT', 'OUT_FOR_DELIVERY', 'DELIVERED'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Shipment')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Shipment ID', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            Text(widget.shipmentId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 32),
            const Text('Update Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ..._statuses.map((status) => RadioListTile(
              title: Text(status.replaceAll('_', ' ')),
              value: status,
              groupValue: _currentStatus,
              onChanged: (value) => setState(() => _currentStatus = value!),
              activeColor: AppColors.accent,
            )),
            const Spacer(),
            AppButton(
              text: 'Save Update',
              onPressed: () {
                // TODO: API call to update status
              },
            ),
          ],
        ),
      ),
    );
  }
}
