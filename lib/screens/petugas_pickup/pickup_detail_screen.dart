import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/pickup_model.dart';
import '../../services/pickup_service.dart';
import '../../helpers/distance_helper.dart';
import '../../widgets/confirm_pickup_bottom_sheet.dart';

const kPrimary = Color(0xFF00C4CC);
const kPrimaryDark = Color(0xFF0097A7);
const kBg = Color(0xFFF5F7F9);

class PickupDetailScreen extends ConsumerStatefulWidget {
  final PickupModel pickup;

  const PickupDetailScreen({
    super.key,
    required this.pickup,
  });

  @override
  ConsumerState<PickupDetailScreen> createState() => _PickupDetailScreenState();
}

class _PickupDetailScreenState extends ConsumerState<PickupDetailScreen> 
    with SingleTickerProviderStateMixin { // Tambahkan Mixin untuk animasi
  final PickupService _pickupService = PickupService();
  final TextEditingController _notesController = TextEditingController();
  bool _isUpdating = false;

  TrackingInfo? _trackingInfo;
  bool _isLoadingTracking = false;

  // Animation controllers
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.pickup.notes != null) {
      _notesController.text = widget.pickup.notes!;
    }
    
    if (widget.pickup.status == PickupStatus.accepted || 
        widget.pickup.status == PickupStatus.inProgress) {
      _loadTrackingInfo();
    }

    // Setup pulse animation
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
    _notesController.dispose();
    _pulseController?.dispose(); // Dispose animasi
    super.dispose();
  }
  
  void _showConfirmationBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ConfirmPickupBottomSheet(
        pickup: widget.pickup,
        onConfirm: _handlePickupConfirmation,
      ),
    );
  }

  Future<void> _handlePickupConfirmation(
    WasteType confirmedWasteType,
    double confirmedWeight,
    String? notes,
  ) async {
    setState(() => _isUpdating = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isUpdating = false);
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final petugasName = userDoc.data()?['displayName'] ?? 'Petugas';

    final success = await _pickupService.completePickupWithPoints(
      pickupId: widget.pickup.pickupId,
      pickup: widget.pickup,
      confirmedWasteType: confirmedWasteType,
      confirmedWeight: confirmedWeight,
      petugasId: user.uid,
      petugasName: petugasName,
      notes: notes,
    );

    if (mounted) Navigator.pop(context);

    setState(() => _isUpdating = false);

    if (success && mounted) {
      _showSuccessSnackBar('Penjemputan Selesai!', 'Poin berhasil dikirim ke customer');
      Navigator.pop(context);
    } else if (mounted) {
      _showErrorSnackBar('Gagal menyelesaikan penjemputan');
    }
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

  Future<void> _updateStatus(PickupStatus newStatus) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final petugasName = userDoc.data()?['displayName'] ?? 'Petugas';

    setState(() => _isUpdating = true);

    final success = await _pickupService.updatePickupStatus(
      pickupId: widget.pickup.pickupId,
      newStatus: newStatus,
      petugasId: user.uid,
      petugasName: petugasName,
      notes: _notesController.text.trim(),
    );

    setState(() => _isUpdating = false);

    if (success && mounted) {
      _showSuccessSnackBar('Status Diupdate', 'Status: ${newStatus.displayName}');
      Navigator.pop(context);
    } else if (mounted) {
      _showErrorSnackBar('Gagal update status');
    }
  }

  Future<void> _callCustomer() async {
    final phone = widget.pickup.customerPhone;
    if (phone == null || phone.isEmpty) return;

    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _openMaps() async {
    final lat = widget.pickup.location.latitude;
    final lng = widget.pickup.location.longitude;
    
    final googleMapsUrl = Uri.parse('google.navigation:q=$lat,$lng');
    final webUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else if (await canLaunchUrl(webUrl)) {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  List<Color> _getStatusGradient() {
    switch (widget.pickup.status) {
      case PickupStatus.pending:
        return [const Color(0xFFFF9800), const Color(0xFFFFA726)];
      case PickupStatus.accepted:
        return [const Color(0xFF2196F3), const Color(0xFF42A5F5)];
      case PickupStatus.inProgress:
        return [kPrimary, const Color(0xFF26C6DA)];
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
        return 'Menunggu Anda menerima permintaan';
      case PickupStatus.accepted:
        return 'Anda telah menerima, segera mulai perjalanan';
      case PickupStatus.inProgress:
        return 'Sedang melakukan penjemputan ke lokasi';
      case PickupStatus.completed:
        return 'Penjemputan telah selesai';
      case PickupStatus.cancelled:
        return 'Penjemputan dibatalkan';
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
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text(
          'Detail Penjemputan',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Map dengan rounded bottom corners (Sama seperti CustomerTracking)
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

            // Action Buttons Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openMaps,
                      icon: const Icon(Icons.directions),
                      label: const Text('Buka Maps'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimary,
                        side: const BorderSide(color: kPrimary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: pickup.customerPhone != null ? _callCustomer : null,
                      icon: const Icon(Icons.phone),
                      label: const Text('Telepon'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimary,
                        side: const BorderSide(color: kPrimary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Enhanced Status Card (Matches CustomerTracking)
            _buildEnhancedStatusCard(),

            const SizedBox(height: 16),

            // Tracking Info
            if (pickup.status == PickupStatus.accepted || 
                pickup.status == PickupStatus.inProgress)
              _buildTrackingCard(),

            if (pickup.status == PickupStatus.accepted || 
                pickup.status == PickupStatus.inProgress)
              const SizedBox(height: 16),

            // Customer Info
            _buildCustomerCard(),

            const SizedBox(height: 16),

            // Waste Info
            _buildWasteCard(),

            // Photo (if exists)
            if (pickup.photoUrl != null) ...[
              const SizedBox(height: 16),
              _buildPhotoCard(),
            ],

            const SizedBox(height: 16),

            // Notes
            _buildNotesCard(),

            const SizedBox(height: 100), // Space for bottom button
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
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
                // Animated Status Icon
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

  // Menggunakan style Info Box yang bersih seperti CustomerTrackingScreen
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
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(),
              ),
            )
          : _trackingInfo != null
              ? Column(
                  children: [
                    Row(
                      children: [
                         Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C4CC).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.navigation, color: Color(0xFF00C4CC)),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Jarak ke Lokasi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _loadTrackingInfo,
                          icon: const Icon(Icons.refresh),
                          color: const Color(0xFF00C4CC),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
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
                      'Gagal memuat jarak',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: _loadTrackingInfo,
                      child: const Text('Coba Lagi'),
                    )
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard() {
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
            'Informasi Customer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            Icons.person,
            'Nama',
            widget.pickup.customerName,
            Colors.blue,
          ),
          _buildDetailRow(
            Icons.email,
            'Email',
            widget.pickup.customerEmail,
            Colors.orange,
          ),
          if (widget.pickup.customerPhone != null)
            _buildDetailRow(
              Icons.phone,
              'Telepon',
              widget.pickup.customerPhone!,
              Colors.green,
            ),
        ],
      ),
    );
  }

  Widget _buildWasteCard() {
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
            'Informasi Sampah',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            Icons.delete_outline,
            'Jenis',
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
          if (widget.pickup.description != null && widget.pickup.description!.isNotEmpty)
            _buildDetailRow(
              Icons.description_outlined,
              'Deskripsi',
              widget.pickup.description!,
              Colors.grey,
            ),
        ],
      ),
    );
  }

  // Helper untuk membuat baris detail yang seragam
  Widget _buildDetailRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _buildPhotoCard() {
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
            'Foto Sampah',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.pickup.photoUrl!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
                  color: Colors.grey[100],
                  child: const Center(
                    child: CircularProgressIndicator(color: kPrimaryDark),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[100],
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
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
            'Catatan Petugas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Tambahkan catatan...',
              filled: true,
              fillColor: kBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kPrimaryDark, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildBottomActions() {
    if (_isUpdating) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(color: kPrimaryDark),
        ),
      );
    }

    switch (widget.pickup.status) {
      case PickupStatus.pending:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () => _updateStatus(PickupStatus.accepted),
            icon: const Icon(Icons.check_circle_outline, size: 22),
            label: const Text(
              'Terima Permintaan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        );

      case PickupStatus.accepted:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () => _updateStatus(PickupStatus.inProgress),
            icon: const Icon(Icons.play_circle_outline, size: 22),
            label: const Text(
              'Mulai Penjemputan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        );

      case PickupStatus.inProgress:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: _showConfirmationBottomSheet,
            icon: const Icon(Icons.done_all, size: 22),
            label: const Text(
              'Selesaikan Penjemputan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        );

      case PickupStatus.completed:
      case PickupStatus.cancelled:
        return null;
    }
  }

  void _showSuccessSnackBar(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}