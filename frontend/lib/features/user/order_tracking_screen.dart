import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/design_system.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late IO.Socket socket;
  String currentStatus = 'Out for Delivery';
  String currentLocation = 'New Delhi Hub';

  @override
  void initState() {
    super.initState();
    _initSocket();
  }

  void _initSocket() {
    socket = IO.io('http://10.0.2.2:3000/tracking', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.connect();
    
    socket.onConnect((_) => print('Connected to tracking'));
    
    socket.on('locationUpdate:${widget.orderId}', (data) {
      setState(() {
        currentLocation = data['location'] ?? currentLocation;
        currentStatus = data['status'] ?? currentStatus;
      });
    });
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        title: Text('Track Order', style: DesignSystem.h2),
        backgroundColor: DesignSystem.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: DesignSystem.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildLiveMapView(),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: DesignSystem.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildDeliveryStatus(),
                   const SizedBox(height: 32),
                   Text('History', style: DesignSystem.h2.copyWith(fontSize: 18)),
                   const SizedBox(height: 24),
                   Expanded(child: _buildTrackingTimeline()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveMapView() {
    return Container(
      height: 300,
      width: double.infinity,
      color: DesignSystem.secondary,
      child: Stack(
        children: [
          Center(
            child: Icon(Icons.location_on_rounded, size: 48, color: DesignSystem.primary)
                .animate(onPlay: (controller) => controller.repeat())
                .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 1.seconds)
                .then()
                .scale(begin: const Offset(1.2, 1.2), end: const Offset(1, 1)),
          ),
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: DesignSystem.premiumCard,
              child: Row(
                children: [
                  const Icon(Icons.radar_rounded, color: DesignSystem.accent),
                  const SizedBox(width: 12),
                  Text('Live Location: ', style: DesignSystem.bodyMedium),
                  Text(currentLocation, style: DesignSystem.bodyLarge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryStatus() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: DesignSystem.secondary, borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.local_shipping_outlined, color: DesignSystem.primary),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status', style: DesignSystem.bodyMedium),
            Text(currentStatus, style: DesignSystem.h2.copyWith(fontSize: 20, color: DesignSystem.primary)),
          ],
        ),
      ],
    ).animate().fadeIn().slideX();
  }

  Widget _buildTrackingTimeline() {
    final statusList = [
      {'status': 'Out for Delivery', 'time': '10:30 AM', 'active': true},
      {'status': 'Arrived at Facility', 'time': 'Yesterday, 08:45 PM', 'active': false},
      {'status': 'Order Placed', 'time': '06 Mar, 11:20 AM', 'active': false},
    ];

    return ListView.builder(
      itemCount: statusList.length,
      itemBuilder: (context, index) {
        final item = statusList[index];
        return IntrinsicHeight(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: item['active'] as bool ? DesignSystem.accent : DesignSystem.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (index != statusList.length - 1)
                    Expanded(
                      child: Container(width: 2, color: DesignSystem.secondary),
                    ),
                ],
              ),
              const SizedBox(width: 24),
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['status'] as String, style: DesignSystem.bodyLarge.copyWith(
                      color: item['active'] as bool ? DesignSystem.primary : DesignSystem.primary.withOpacity(0.4),
                    )),
                    Text(item['time'] as String, style: DesignSystem.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
