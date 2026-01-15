import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../models/pickup_model.dart';
import '../../helpers/distance_helper.dart';

class CustomerTrackingScreen extends ConsumerStatefulWidget {
  final PickupModel pickup;

  const CustomerTrackingScreen({
    super.key,
    required this.pickup,
  });

  @override
  ConsumerState<CustomerTrackingScreen> createState() => _CustomerTrackingScreenState();
}

class _CustomerTrackingScreenState extends ConsumerState<CustomerTrackingScreen> 
    with SingleTickerProviderStateMixin {
  TrackingInfo? _trackingInfo;
  bool _isLoadingTracking = false;
  

  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadTrackingInfo();
    
    // Setup pulse animation untuk status icon
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
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

  List<Color> _getStatusGradient() {
    switch (widget.pickup.status) {
      case PickupStatus.pending:
        return [const Color(0xFFFF9800), const Color(0xFFFFA726)];
      case PickupStatus.accepted:
        return [const Color(0xFF2196F3), const Color(0xFF42A5F5)];
      case PickupStatus.inProgress:
        return [const Color(0xFF00C4CC), const Color(0xFF26C6DA)];
      case PickupStatus.completed:
        return [const Color(0xFF4CAF50), const Color(0xFF66BB6A)];
      case PickupStatus.cancelled:
        return [const Color(0xFFE53935), const Color(0xFFEF5350)];
    }
  }

  Color _getStatusColor() {
    return _getStatusGradient().first;
  }

  String _getStatusMessage() {
    switch (widget.pickup.status) {
      case PickupStatus.pending:
        return 'Menunggu petugas menerima permintaan Anda';
      case PickupStatus.accepted:
        return 'Petugas telah menerima dan akan segera menuju lokasi';
      case PickupStatus.inProgress:
        return 'Petugas sedang melakukan penjemputan sampah Anda';
      case PickupStatus.completed:
        return 'Penjemputan telah selesai. Terima kasih!';
      case PickupStatus.cancelled:
        return 'Penjemputan telah dibatalkan';
    }
  }

  IconData _getStatusIcon() {
    switch (widget.pickup.status) {
      case PickupStatus.pending:
        return Icons.schedule_outlined;
      case PickupStatus.accepted:
        return Icons.check_circle_outline;
      case PickupStatus.inProgress:
        return Icons.local_shipping_outlined;
      case PickupStatus.completed:
        return Icons.task_alt;
      case PickupStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickup = widget.pickup;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        title: const Text(
          'Status Penjemputan',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF00C4CC),
        foregroundColor: Colors.white,
        
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Map dengan rounded bottom corners
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: Container(
                height: 280,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    FlutterMap(
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
                              width: 60,
                              height: 60,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: _getStatusColor().withOpacity(0.4),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.location_on,
                                      color: _getStatusColor(),
                                      size: 28,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    // Address badge at bottom
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.place,
                              color: _getStatusColor(),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                pickup.address,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Enhanced Status Card
            _buildEnhancedStatusCard(),

            const SizedBox(height: 16),

            // Tracking Info
            if (pickup.status == PickupStatus.accepted || 
                pickup.status == PickupStatus.inProgress)
              _buildTrackingCard(),

            const SizedBox(height: 16),

            // Petugas Info
            if (pickup.assignedPetugasName != null)
              _buildPetugasCard(),

            const SizedBox(height: 16),

            // Pickup Details
            _buildPickupDetailsCard(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedStatusCard() {
    final statusGradient = _getStatusGradient();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: statusGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: statusGradient.first.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          
          // Main content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // ✅ FIX: Check animation sebelum pakai
                _pulseAnimation != null
                    ? ScaleTransition(
                        scale: _pulseAnimation!,
                        child: _buildStatusIconContainer(statusGradient),
                      )
                    : _buildStatusIconContainer(statusGradient),
                
                const SizedBox(height: 20),
                
                // Status Title
                Text(
                  widget.pickup.status.displayName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Status Message
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusMessage(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Status Timeline
                _buildStatusTimeline(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Extract icon container ke separate widget
  Widget _buildStatusIconContainer(List<Color> statusGradient) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Icon(
        _getStatusIcon(),
        size: 48,
        color: statusGradient.first,
      ),
    );
  }

  Widget _buildStatusTimeline() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimelineDot(PickupStatus.pending),
        _buildTimelineLine(
          widget.pickup.status.index >= PickupStatus.accepted.index,
        ),
        _buildTimelineDot(PickupStatus.accepted),
        _buildTimelineLine(
          widget.pickup.status.index >= PickupStatus.inProgress.index,
        ),
        _buildTimelineDot(PickupStatus.inProgress),
        _buildTimelineLine(
          widget.pickup.status == PickupStatus.completed,
        ),
        _buildTimelineDot(PickupStatus.completed),
      ],
    );
  }

  Widget _buildTimelineDot(PickupStatus status) {
    final isActive = widget.pickup.status.index >= status.index;
    final isCurrent = widget.pickup.status == status;
    
    return Container(
      width: isCurrent ? 14 : 10,
      height: isCurrent ? 14 : 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
        border: isCurrent
            ? Border.all(color: Colors.white, width: 3)
            : null,
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildTimelineLine(bool isActive) {
    return Container(
      width: 24,
      height: 2,
      color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildTrackingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _isLoadingTracking
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          : _trackingInfo != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C4CC).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.navigation,
                            color: Color(0xFF00C4CC),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Petugas Dalam Perjalanan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _loadTrackingInfo,
                          icon: const Icon(Icons.refresh),
                          color: const Color(0xFF00C4CC),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTrackingInfoBox(
                            icon: Icons.straighten,
                            label: 'Jarak',
                            value: _trackingInfo!.distanceFormatted,
                            color: const Color(0xFF42A5F5),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTrackingInfoBox(
                            icon: Icons.access_time,
                            label: 'Estimasi',
                            value: _trackingInfo!.estimatedTimeFormatted,
                            color: const Color(0xFF66BB6A),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Column(
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tidak dapat menghitung jarak',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
    );
  }

  Widget _buildTrackingInfoBox({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetugasCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00C4CC),
                      const Color(0xFF00C4CC).withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00C4CC).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.pickup.assignedPetugasName![0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.pickup.assignedPetugasName!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Petugas Penjemputan',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.pickup.customerPhone != null)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C4CC).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _callPetugas,
                    icon: const Icon(Icons.phone),
                    color: const Color(0xFF00C4CC),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPickupDetailsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
          const SizedBox(height: 16),
          _buildDetailRow(
            Icons.delete_outline,
            'Jenis Sampah',
            widget.pickup.wasteType.displayName,
            const Color(0xFF66BB6A),
          ),
          _buildDetailRow(
            Icons.scale_outlined,
            'Berat',
            '${widget.pickup.weight} kg',
            const Color(0xFF42A5F5),
          ),
          _buildDetailRow(
            Icons.calendar_today_outlined,
            'Dibuat',
            DateFormat('dd MMM yyyy, HH:mm').format(widget.pickup.createdAt),
            const Color(0xFFFF9800),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
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
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}