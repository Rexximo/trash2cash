import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationSearchResult {
  final String displayName;
  final double latitude;
  final double longitude;

  LocationSearchResult({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });
}

class LocationService {
  /// Search location by query menggunakan Nominatim
  Future<List<LocationSearchResult>> searchLocation(String query) async {
    if (query.isEmpty || query.length < 3) {
      return [];
    }

    try {
      print('🔍 Searching location: $query');
      
      // Nominatim Search API
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?'
        'q=$query&format=json&addressdetails=1&limit=5'
      );
      
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'Trash2Cash/1.0',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        final results = data.map((item) {
          return LocationSearchResult(
            displayName: item['display_name'] ?? '',
            latitude: double.parse(item['lat'].toString()),
            longitude: double.parse(item['lon'].toString()),
          );
        }).toList();
        
        print('✅ Found ${results.length} locations');
        return results;
      } else {
        print('❌ Search API error: ${response.statusCode}');
        return [];
      }
      
    } catch (e) {
      print('❌ Error searching location: $e');
      return [];
    }
  }

  /// Check & request location permission
  Future<bool> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location service is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('❌ Location services are disabled');
      return false;
    }

    // Check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('❌ Location permission denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('❌ Location permission permanently denied');
      return false;
    }

    print('✅ Location permission granted');
    return true;
  }

  /// Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) return null;

      print('📍 Getting current location...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      print('✅ Location: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('❌ Error getting location: $e');
      return null;
    }
  }

  /// Convert coordinates to address menggunakan Nominatim (OpenStreetMap)
  Future<String> getAddressFromCoordinatesNominatim(double lat, double lng) async {
    try {
      print('📍 Getting address from Nominatim for: $lat, $lng');
      
      // Nominatim Reverse Geocoding API (FREE!)
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?'
        'lat=$lat&lon=$lng&format=json&addressdetails=1'
      );
      
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'Trash2Cash/1.0', // REQUIRED by Nominatim
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['display_name'] != null) {
          final address = data['display_name'] as String;
          print('✅ Address from Nominatim: $address');
          return address;
        } else {
          print('⚠️ No display_name in response');
          return _formatCoordinates(lat, lng);
        }
      } else {
        print('❌ Nominatim API error: ${response.statusCode}');
        return _formatCoordinates(lat, lng);
      }
      
    } catch (e) {
      print('❌ Error getting address from Nominatim: $e');
      return _formatCoordinates(lat, lng);
    }
  }

  /// Convert coordinates to address menggunakan geocoding package (fallback)
  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      print('📍 Getting address from Geocoding package for: $lat, $lng');
      
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('⏱️ Geocoding timeout');
              return [];
            },
          );
      
      if (placemarks.isEmpty) {
        print('⚠️ No placemarks found');
        return _formatCoordinates(lat, lng);
      }
      
      final place = placemarks.first;
      
      // Build address dengan null checks
      List<String> addressParts = [];
      
      if (place.street != null && place.street!.isNotEmpty) {
        addressParts.add(place.street!);
      }
      if (place.subLocality != null && place.subLocality!.isNotEmpty) {
        addressParts.add(place.subLocality!);
      }
      if (place.locality != null && place.locality!.isNotEmpty) {
        addressParts.add(place.locality!);
      }
      if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
        addressParts.add(place.subAdministrativeArea!);
      }
      if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
        addressParts.add(place.administrativeArea!);
      }
      if (place.country != null && place.country!.isNotEmpty) {
        addressParts.add(place.country!);
      }
      
      if (addressParts.isEmpty) {
        print('⚠️ No address parts found');
        return _formatCoordinates(lat, lng);
      }
      
      final address = addressParts.join(', ');
      print('✅ Address from Geocoding: $address');
      return address;
      
    } catch (e) {
      print('❌ Error getting address from Geocoding: $e');
      return _formatCoordinates(lat, lng);
    }
  }

  /// Get address dengan retry mechanism - PRIORITAS NOMINATIM
  Future<String> getAddressWithRetry(double lat, double lng, {int maxRetries = 2}) async {
    int attempt = 0;
    
    while (attempt < maxRetries) {
      try {
        attempt++;
        print('🔄 Attempt $attempt/$maxRetries to get address');
        
        // PRIORITAS 1: Coba Nominatim dulu (lebih reliable)
        if (attempt == 1) {
          final address = await getAddressFromCoordinatesNominatim(lat, lng);
          if (!address.startsWith('Koordinat:')) {
            return address;
          }
        }
        
        // PRIORITAS 2: Fallback ke geocoding package
        if (attempt == 2) {
          final address = await getAddressFromCoordinates(lat, lng);
          if (!address.startsWith('Koordinat:')) {
            return address;
          }
        }
        
        // Tunggu sebentar sebelum retry
        if (attempt < maxRetries) {
          await Future.delayed(const Duration(seconds: 2));
        }
        
      } catch (e) {
        print('❌ Attempt $attempt failed: $e');
        if (attempt >= maxRetries) {
          return _formatCoordinates(lat, lng);
        }
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    
    return _formatCoordinates(lat, lng);
  }

  /// Convert LatLng to formatted address (dengan retry)
  Future<String> getAddressFromLatLng(LatLng latLng) async {
    return await getAddressWithRetry(latLng.latitude, latLng.longitude);
  }

  /// Format koordinat sebagai fallback
  String _formatCoordinates(double lat, double lng) {
    return 'Koordinat: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
  }
}