import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';

import '../models/pickup_model.dart';
import '../services/pickup_service.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class CreatePickupPage extends ConsumerStatefulWidget {
  const CreatePickupPage({super.key});

  @override
  ConsumerState<CreatePickupPage> createState() => _CreatePickupPageState();
}

class _CreatePickupPageState extends ConsumerState<CreatePickupPage> {
  // Helper untuk mendapatkan icon berdasarkan jenis sampah
  IconData _getWasteIcon(WasteType type) {
    switch (type) {
      case WasteType.organik:
        return Icons.eco; // atau Icons.compost
      case WasteType.anorganik:
        return Icons.recycling;
      case WasteType.b3:
        return Icons.warning_amber_rounded;
    }
  }

  // Helper untuk mendapatkan warna berdasarkan jenis sampah
  Color _getWasteColor(WasteType type) {
    switch (type) {
      case WasteType.organik:
        return const Color(0xFF4CAF50); // Green
      case WasteType.anorganik:
        return const Color(0xFF2196F3); // Blue
      case WasteType.b3:
        return const Color(0xFFFF5722); // Red/Orange
    }
  }

  // Helper untuk mendapatkan deskripsi singkat
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

  final _formKey = GlobalKey<FormState>();
  final _locationService = LocationService();
  final _pickupService = PickupService();
  final _storageService = StorageService();
  final _mapController = MapController();

  // Form fields
  WasteType _selectedWasteType = WasteType.organik;
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _searchController = TextEditingController();
  List<LocationSearchResult> _searchResults = [];
  bool _isSearching = false;
  bool _showManualInput = false;

  // Location
  LatLng? _selectedLocation;
  String _address = 'Pilih lokasi di map';
  bool _isLoadingLocation = false;

  // Image
  File? _selectedImage;
  bool _isUploadingImage = false;

  // Submit
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _searchLocation(String query) async {
    if (query.length < 3) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    final results = await _locationService.searchLocation(query);

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _selectSearchResult(LocationSearchResult result) {
    final latLng = LatLng(result.latitude, result.longitude);
    
    setState(() {
      _selectedLocation = latLng;
      _address = result.displayName;
      _searchController.clear();
      _searchResults = [];
    });

    // Move map camera
    _mapController.move(latLng, 15.0);
  }

  Future<bool> checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> _getCurrentLocation() async {
    final hasInternet = await checkInternetConnection();
    if (!hasInternet) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada koneksi internet untuk mengambil alamat'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  
  setState(() => _isLoadingLocation = true);

    final position = await _locationService.getCurrentLocation();
    
    if (position != null) {
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedLocation = latLng;
        _address = 'Mengambil alamat...'; // Temporary text
      });

      // Move map camera first
      _mapController.move(latLng, 15.0);

      // Get address (dengan error handling)
      try {
        final address = await _locationService.getAddressWithRetry(
          latLng.latitude,
          latLng.longitude,
        );
        if (mounted) {
          setState(() {
            _address = address;
            _isLoadingLocation = false;
          });
        }
      } catch (e) {
        print('Error getting address: $e');
        if (mounted) {
          setState(() {
            _address = 'Koordinat: ${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}';
            _isLoadingLocation = false;
          });
        }
      }
    } else {
      setState(() => _isLoadingLocation = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat mengakses lokasi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final result = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () async {
                final image = await picker.pickImage(source: ImageSource.camera);
                if (mounted) Navigator.pop(context, image);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () async {
                final image = await picker.pickImage(source: ImageSource.gallery);
                if (mounted) Navigator.pop(context, image);
              },
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedImage = File(result.path);
      });
    }
  }

  Future<void> _onMapTap(TapPosition tapPosition, LatLng latLng) async {
    setState(() {
      _selectedLocation = latLng;
      _address = 'Mengambil alamat...';
      _isLoadingLocation = true;
    });

    try {
      final address = await _locationService.getAddressFromLatLng(latLng);
      if (mounted) {
        setState(() {
          _address = address;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      print('Error getting address: $e');
      if (mounted) {
        setState(() {
          _address = 'Koordinat: ${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}';
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _submitPickup() async {
    if (!_formKey.currentState!.validate()) return;

    // Validasi lokasi
    if (!_showManualInput && _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih lokasi penjemputan di map atau gunakan input manual'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_showManualInput && _address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alamat manual harus diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data()!;

      // Upload image jika ada
      String? photoUrl;
      if (_selectedImage != null) {
        setState(() => _isUploadingImage = true);
        photoUrl = await _storageService.uploadImage(_selectedImage!, 'pickups');
        setState(() => _isUploadingImage = false);
      }

      // Handle location berdasarkan mode input
      GeoPoint location;
      String finalAddress;

      if (_showManualInput) {
        // Manual input: gunakan koordinat default (pusat Bandung)
        location = const GeoPoint(-6.9175, 107.6191);
        finalAddress = _address;
      } else {
        // Map input: gunakan koordinat yang dipilih
        location = GeoPoint(_selectedLocation!.latitude, _selectedLocation!.longitude);
        finalAddress = _address;
      }

      // Create pickup model
      final pickup = PickupModel(
        pickupId: '',
        customerId: user.uid,
        customerName: userData['displayName'] ?? 'Customer',
        customerEmail: user.email!,
        customerPhone: _phoneController.text.trim(),
        wasteType: _selectedWasteType,
        weight: double.parse(_weightController.text),
        description: _descriptionController.text.trim(),
        photoUrl: photoUrl,
        location: location,
        address: finalAddress,
        status: PickupStatus.pending,
        createdAt: DateTime.now(),
      );

      // Submit to Firestore
      final pickupId = await _pickupService.createPickup(pickup);

      if (pickupId != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permintaan penjemputan berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        throw Exception('Failed to create pickup');
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isUploadingImage = false;
        });
      }
    }
  }


  @override
  void dispose() {
    _weightController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Permintaan Penjemputan'),
        backgroundColor: const Color(0xFF00C4CC),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Jenis Sampah
              const Text(
                'Jenis Sampah',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: WasteType.values.asMap().entries.map((entry) {
                    final index = entry.key;
                    final type = entry.value;
                    final isSelected = _selectedWasteType == type;
                    
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() => _selectedWasteType = type);
                          },
                          borderRadius: index == 0
                              ? const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                )
                              : index == WasteType.values.length - 1
                                  ? const BorderRadius.only(
                                      bottomLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    )
                                  : null,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? const Color(0xFF00C4CC).withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: index == 0
                                  ? const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    )
                                  : index == WasteType.values.length - 1
                                      ? const BorderRadius.only(
                                          bottomLeft: Radius.circular(12),
                                          bottomRight: Radius.circular(12),
                                        )
                                      : null,
                            ),
                            child: Row(
                              children: [
                                // Icon dengan background
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _getWasteColor(type).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getWasteIcon(type),
                                    color: _getWasteColor(type),
                                    size: 28,
                                  ),
                                ),
                                
                                const SizedBox(width: 16),
                                
                                // Text
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        type.displayName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected 
                                              ? const Color(0xFF00C4CC)
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _getWasteDescription(type),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Radio indicator
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected 
                                          ? const Color(0xFF00C4CC)
                                          : Colors.grey[400]!,
                                      width: 2,
                                    ),
                                    color: isSelected 
                                        ? const Color(0xFF00C4CC)
                                        : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Divider (kecuali item terakhir)
                        if (index < WasteType.values.length - 1)
                          Divider(
                            height: 1,
                            color: Colors.grey[300],
                            indent: 16,
                            endIndent: 16,
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Berat
              const Text(
                'Berat (kg)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Contoh: 5.5',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF00C4CC),
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Berat harus diisi';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Nomor HP
              const Text(
                'Nomor HP',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '08123456789',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF00C4CC),
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor HP harus diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Deskripsi
              const Text(
                'Deskripsi (Opsional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Contoh: Sampah dapur campur daun',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF00C4CC),
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Foto
              const Text(
                'Foto Sampah (Opsional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 50,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap untuk ambil foto',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Lokasi Section Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lokasi Penjemputan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _showManualInput = !_showManualInput);
                    },
                    icon: Icon(
                      _showManualInput ? Icons.map : Icons.edit,
                      size: 18,
                    ),
                    label: Text(_showManualInput ? 'Gunakan Map' : 'Input Manual'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF00C4CC),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Search Location Field
              if (!_showManualInput) ...[
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari lokasi (min. 3 huruf)...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchResults = []);
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF00C4CC),
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    _searchLocation(value);
                  },
                ),

                // Search Results
                if (_isSearching)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),

                if (_searchResults.isNotEmpty && !_isSearching)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _searchResults.length > 5 ? 5 : _searchResults.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.location_on,
                            color: Color(0xFF00C4CC),
                          ),
                          title: Text(
                            result.displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                          onTap: () => _selectSearchResult(result),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 12),
              ],

              // Manual Input Address
              if (_showManualInput) ...[
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Ketik alamat lengkap...',
                    prefixIcon: const Icon(Icons.edit_location),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF00C4CC),
                        width: 2,
                      ),
                    ),
                  ),
                  maxLines: 3,
                  onChanged: (value) {
                    setState(() {
                      _address = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Note: Jika input manual, lokasi akan diset ke pusat kota Bandung',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Map (hanya tampil jika tidak manual input)
              if (!_showManualInput) ...[
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _selectedLocation ?? const LatLng(-6.9175, 107.6191),
                            initialZoom: 15.0,
                            onTap: _onMapTap,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.trash2cash.app',
                            ),
                            if (_selectedLocation != null)
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: _selectedLocation!,
                                    width: 40,
                                    height: 40,
                                    child: const Icon(
                                      Icons.location_pin,
                                      color: Color(0xFF00C4CC),
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
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Address display
                if (_selectedLocation != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C4CC).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFF00C4CC),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _address,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),

                // Get current location button
                OutlinedButton.icon(
                  onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                  icon: _isLoadingLocation
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                  label: const Text('Gunakan Lokasi Saat Ini'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00C4CC),
                    side: const BorderSide(color: Color(0xFF00C4CC)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],

              const SizedBox(height: 12),

              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitPickup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C4CC),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Buat Permintaan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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