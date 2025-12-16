import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/pickup_model.dart';
import '../services/pickup_service.dart';
import '../services/location_service.dart';
import '../services/cloudinary_service.dart';

/// ==================== DESIGN SYSTEM ====================
const kPrimary = Color(0xFF00C4CC);
const kPrimaryDark = Color(0xFF0097A7);
const kBackground = Color(0xFFF5F7F9);
const kSurface = Colors.white;
const kDivider = Color(0xFFE5E7EB);
const kTextPrimary = Color(0xFF1F2937);
const kTextSecondary = Color(0xFF6B7280);

class RequestPickupScreen extends ConsumerStatefulWidget {
  const RequestPickupScreen({super.key});

  @override
  ConsumerState<RequestPickupScreen> createState() =>
      _RequestPickupScreenState();
}

class _RequestPickupScreenState
    extends ConsumerState<RequestPickupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _locationService = LocationService();
  final _pickupService = PickupService();
  final _cloudinaryService = CloudinaryService();
  final _mapController = MapController();

  WasteType _selectedWasteType = WasteType.organik;
  LatLng? _selectedLocation;
  String _address = 'Pilih lokasi di map';

  bool _isSubmitting = false;
  bool _isLoadingLocation = false;

  XFile? _selectedImage;

  final _weightController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// ==================== HELPERS ====================
  IconData _getWasteIcon(WasteType type) {
    switch (type) {
      case WasteType.organik:
        return Icons.eco;
      case WasteType.anorganik:
        return Icons.recycling;
      case WasteType.b3:
        return Icons.warning_amber_rounded;
    }
  }

  Color _getWasteColor(WasteType type) {
    switch (type) {
      case WasteType.organik:
        return Colors.green;
      case WasteType.anorganik:
        return Colors.blue;
      case WasteType.b3:
        return Colors.deepOrange;
    }
  }

  String _getWasteDescription(WasteType type) {
    switch (type) {
      case WasteType.organik:
        return 'Sisa makanan, daun, kayu';
      case WasteType.anorganik:
        return 'Plastik, kaca, kaleng, kertas';
      case WasteType.b3:
        return 'Baterai, lampu, obat-obatan';
    }
  }

  InputDecoration _input(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: kBackground,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kPrimary, width: 1.5),
      ),
    );
  }

  Widget _section(String title, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: kTextPrimary)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  /// ==================== LOCATION ====================
  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    final hasInternet =
        await Connectivity().checkConnectivity() !=
            ConnectivityResult.none;

    if (!hasInternet) {
      setState(() => _isLoadingLocation = false);
      return;
    }

    final pos = await _locationService.getCurrentLocation();
    if (pos == null) return;

    final latLng = LatLng(pos.latitude, pos.longitude);
    _mapController.move(latLng, 15);

    final address = await _locationService.getAddressWithRetry(
      latLng.latitude,
      latLng.longitude,
    );

    setState(() {
      _selectedLocation = latLng;
      _address = address;
      _isLoadingLocation = false;
    });
  }

  /// ==================== IMAGE ====================
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1920,
    );
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  /// ==================== SUBMIT ====================
  Future<void> _submitPickup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) return;

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      String? photoUrl;
      if (_selectedImage != null) {
        photoUrl =
            await _cloudinaryService.uploadPickupImage(_selectedImage!);
      }

      final pickup = PickupModel(
        pickupId: '',
        customerId: user.uid,
        customerName:
            userDoc.data()?['displayName'] ?? 'Customer',
        customerEmail: user.email!,
        customerPhone: _phoneController.text,
        wasteType: _selectedWasteType,
        weight: double.parse(_weightController.text),
        description: _descriptionController.text,
        photoUrl: photoUrl,
        location: GeoPoint(
          _selectedLocation!.latitude,
          _selectedLocation!.longitude,
        ),
        address: _address,
        status: PickupStatus.pending,
        createdAt: DateTime.now(),
      );

      await _pickupService.createPickup(pickup);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Permintaan penjemputan berhasil dibuat'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  /// ==================== UI ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kPrimary,
        foregroundColor: kBackground,
        title: const Text(
          'Buat Permintaan Penjemputan',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              /// JENIS SAMPAH
              _section(
                'Jenis Sampah',
                Column(
                  children: WasteType.values.map((type) {
                    final selected =
                        _selectedWasteType == type;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedWasteType = type),
                      child: AnimatedContainer(
                        duration:
                            const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: selected
                              ? kPrimary.withOpacity(0.08)
                              : Colors.transparent,
                          borderRadius:
                              BorderRadius.circular(14),
                          border: Border.all(
                              color: selected
                                  ? kPrimary
                                  : kDivider),
                        ),
                        child: Row(
                          children: [
                            Icon(_getWasteIcon(type),
                                color: _getWasteColor(type)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(type.displayName,
                                      style: const TextStyle(
                                          fontWeight:
                                              FontWeight.w600)),
                                  Text(
                                    _getWasteDescription(type),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: kTextSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              selected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color:
                                  selected ? kPrimary : kDivider,
                            )
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              /// FORM
              _section(
                'Detail Sampah',
                Column(
                  children: [
                    TextFormField(
                      controller: _weightController,
                      decoration: _input('Berat (kg)'),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty
                              ? 'Wajib diisi'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      decoration: _input('Nomor HP'),
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          v == null || v.isEmpty
                              ? 'Wajib diisi'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration:
                          _input('Deskripsi (opsional)'),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),

              /// FOTO
              _section(
                'Foto Sampah',
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: kBackground,
                      borderRadius:
                          BorderRadius.circular(16),
                      border: Border.all(color: kDivider),
                    ),
                    child: _selectedImage == null
                        ? const Center(
                            child: Icon(
                              Icons.add_a_photo_outlined,
                              size: 40,
                              color: kTextSecondary,
                            ),
                          )
                        : ClipRRect(
                            borderRadius:
                                BorderRadius.circular(16),
                            child: kIsWeb
                                ? Image.network(
                                    _selectedImage!.path,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(_selectedImage!.path),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                  ),
                ),
              ),

              /// MAP
              _section(
                'Lokasi Penjemputan',
                Column(
                  children: [
                    Container(
                      height: 260,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(16),
                        border: Border.all(color: kDivider),
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter:
                                    _selectedLocation ??
                                        const LatLng(
                                            -6.9175,
                                            107.6191),
                                initialZoom: 15,
                                onTap: (_, latLng) async {
                                  setState(() {
                                    _selectedLocation = latLng;
                                    _isLoadingLocation = true;
                                  });

                                  final addr =
                                      await _locationService
                                          .getAddressFromLatLng(
                                    latLng,
                                  );

                                  setState(() {
                                    _address = addr;
                                    _isLoadingLocation = false;
                                  });
                                },
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName:
                                      'com.banksampah.app',
                                ),
                                if (_selectedLocation != null)
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point:
                                            _selectedLocation!,
                                        width: 40,
                                        height: 40,
                                        child: const Icon(
                                          Icons.location_pin,
                                          color: kPrimary,
                                          size: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            if (_isLoadingLocation)
                              Container(
                                color: Colors.black26,
                                child: const Center(
                                  child:
                                      CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            kPrimary.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: kPrimary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _address,
                              style:
                                  const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed:
                          _isLoadingLocation
                              ? null
                              : _getCurrentLocation,
                      icon: const Icon(Icons.my_location),
                      label:
                          const Text('Gunakan Lokasi Saat Ini'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimary,
                        side:
                            const BorderSide(color: kPrimary),
                        minimumSize:
                            const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// SUBMIT
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      _isSubmitting ? null : _submitPickup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Buat Permintaan',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
