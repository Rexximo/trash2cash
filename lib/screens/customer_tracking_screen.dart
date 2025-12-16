import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../models/pickup_model.dart';
import '../helpers/distance_helper.dart';

class CustomerTrackingScreen extends ConsumerStatefulWidget {
  final PickupModel pickup;

  const CustomerTrackingScreen({
    super.key,
    required this.pickup,
  });

  @override
  ConsumerState<CustomerTrackingScreen> createState() => _CustomerTrackingScreenState();
}

class _CustomerTrackingScreenState extends ConsumerState<CustomerTrackingScreen> {
  TrackingInfo? _trackingInfo;
  bool _isLoadingTracking = false;

  @override
  void initState() {
    super.initState();
    _loadTrackingInfo();
  }

  Future<void> _loadTrackingInfo() async {
    setState(() => _isLoadingTracking = true);

    final trackingInfo = await DistanceHelper.getTrackingInfo(widget.pickup.location);

    if (mounted) {
      setState(() {
        _trackingInfo = trackingInfo;
        _isLoadingTracking = false;
      });
    }
  }

  Future<void> _callPetugas() async {
    if (widget.pickup.customerPhone == null) return;
    
    final url = Uri.parse('tel:${widget.pickup.customerPhone}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Color _getStatusColor() {
    switch (widget.pickup.status) {
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

  String _getStatusMessage() {
    switch (widget.pickup.status) {
      case PickupStatus.pending:
        return 'Menunggu petugas menerima permintaan';
      case PickupStatus.accepted:
        return 'Petugas sedang menuju lokasi Anda';
      case PickupStatus.inProgress:
        return 'Petugas sedang melakukan penjemputan';
      case PickupStatus.completed:
        return 'Penjemputan selesai';
      case PickupStatus.cancelled:
        return 'Penjemputan dibatalkan';
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickup = widget.pickup;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Penjemputan'),
        backgroundColor: const Color(0xFF347433),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Map
            Container(
              height: 250,
              color: Colors.grey[200],
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(
                    pickup.location.latitude,
                    pickup.location.longitude,
                  ),
                  initialZoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.trash2cash.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(
                          pickup.location.latitude,
                          pickup.location.longitude,
                        ),
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: Color(0xFF347433),
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _getStatusIcon(),
                    size: 60,
                    color: _getStatusColor(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    pickup.status.displayName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getStatusMessage(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            // Tracking Info (jika accepted/in progress)
            if (pickup.status == PickupStatus.accepted || 
                pickup.status == PickupStatus.inProgress) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF347433),
                      const Color(0xFF347433).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF347433).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: _isLoadingTracking
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _trackingInfo != null
                        ? Column(
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.local_shipping,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Petugas Sedang Dalam Perjalanan',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoBox(
                                      icon: Icons.straighten,
                                      label: 'Jarak',
                                      value: _trackingInfo!.distanceFormatted,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildInfoBox(
                                      icon: Icons.access_time,
                                      label: 'Estimasi',
                                      value: _trackingInfo!.estimatedTimeFormatted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: _loadTrackingInfo,
                                icon: const Icon(Icons.refresh, color: Colors.white),
                                label: const Text(
                                  'Refresh',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          )
                        : const Column(
                            children: [
                              Icon(Icons.location_off, color: Colors.white, size: 40),
                              SizedBox(height: 8),
                              Text(
                                'Tidak dapat menghitung jarak',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
              ),
              const SizedBox(height: 16),
            ],

            // Petugas Info (jika ada)
            if (pickup.assignedPetugasName != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Petugas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFF347433).withOpacity(0.2),
                          child: Text(
                            pickup.assignedPetugasName![0].toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF347433),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            pickup.assignedPetugasName!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (pickup.customerPhone != null)
                          IconButton(
                            onPressed: _callPetugas,
                            icon: const Icon(Icons.phone),
                            color: const Color(0xFF347433),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Pickup Details
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detail Permintaan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.delete, 'Jenis', pickup.wasteType.displayName),
                  _buildDetailRow(Icons.scale, 'Berat', '${pickup.weight} kg'),
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Dibuat',
                    DateFormat('dd MMM yyyy, HH:mm').format(pickup.createdAt),
                  ),
                  _buildDetailRow(Icons.location_on, 'Lokasi', pickup.address),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (widget.pickup.status) {
      case PickupStatus.pending:
        return Icons.schedule;
      case PickupStatus.accepted:
        return Icons.check_circle;
      case PickupStatus.inProgress:
        return Icons.local_shipping;
      case PickupStatus.completed:
        return Icons.done_all;
      case PickupStatus.cancelled:
        return Icons.cancel;
    }
  }
}