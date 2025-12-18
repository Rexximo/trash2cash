import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trash2cash/screens/customer_tracking_screen.dart';

import '../models/pickup_model.dart';
import '../services/pickup_service.dart';

class CustomerPickupsListScreen extends ConsumerWidget {
  const CustomerPickupsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pickupService = PickupService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Permintaan'),
        backgroundColor: const Color(0xFF0097A7),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<PickupModel>>(
        stream: pickupService.getCustomerPickups(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0097A7),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final pickups = snapshot.data ?? [];

          if (pickups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada permintaan penjemputan',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pickups.length,
            itemBuilder: (context, index) {
              final pickup = pickups[index];
              return _buildPickupCard(context, pickup);
            },
          );
        },
      ),
    );
  }

  Widget _buildPickupCard(BuildContext context, PickupModel pickup) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerTrackingScreen(pickup: pickup),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status & Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(pickup.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      pickup.status.displayName,
                      style: TextStyle(
                        color: _getStatusColor(pickup.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    DateFormat('dd MMM yyyy').format(pickup.createdAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Waste Type & Weight
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getWasteColor(pickup.wasteType).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getWasteIcon(pickup.wasteType),
                      color: _getWasteColor(pickup.wasteType),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pickup.wasteType.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${pickup.weight} kg',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Location
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      pickup.address,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Petugas Info (jika ada)
              if (pickup.assignedPetugasName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Petugas: ${pickup.assignedPetugasName}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(PickupStatus status) {
    switch (status) {
      case PickupStatus.pending:
        return Colors.orange;
      case PickupStatus.accepted:
        return Colors.blue;
      case PickupStatus.inProgress:
        return const Color(0xFFFFC107);
      case PickupStatus.completed:
        return Colors.green;
      case PickupStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getWasteIcon(WasteType type) {
    switch (type) {
      case WasteType.organik:
        return Icons.eco;
      case WasteType.anorganik:
        return Icons.recycling;
      case WasteType.b3:
        return Icons.warning;
    }
  }

  Color _getWasteColor(WasteType type) {
    switch (type) {
      case WasteType.organik:
        return Colors.green;
      case WasteType.anorganik:
        return Colors.blue;
      case WasteType.b3:
        return Colors.red;
    }
  }
}