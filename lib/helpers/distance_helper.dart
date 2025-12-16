import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class DistanceHelper {
  /// Calculate distance between two GeoPoints (Haversine formula)
  /// Returns distance in kilometers
  static double calculateDistance(GeoPoint point1, GeoPoint point2) {
    const double earthRadius = 6371; // Earth radius in km

    final lat1 = point1.latitude;
    final lon1 = point1.longitude;
    final lat2 = point2.latitude;
    final lon2 = point2.longitude;

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadius * c;

    return distance;
  }

  /// Calculate distance from current position to GeoPoint
  static Future<double?> calculateDistanceFromCurrentLocation(GeoPoint destination) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final origin = GeoPoint(position.latitude, position.longitude);
      return calculateDistance(origin, destination);
    } catch (e) {
      print('❌ Error getting current location: $e');
      return null;
    }
  }

  /// Convert degrees to radians
  static double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// Format distance to readable string
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).toStringAsFixed(0)} m';
    } else {
      return '${distanceInKm.toStringAsFixed(1)} km';
    }
  }

  /// Estimate time in minutes (assuming average speed)
  /// Average speed in city: 20-30 km/h
  /// We use 25 km/h as default
  static int estimateTimeInMinutes(double distanceInKm, {double avgSpeedKmh = 25}) {
    final timeInHours = distanceInKm / avgSpeedKmh;
    final timeInMinutes = (timeInHours * 60).round();
    return timeInMinutes;
  }

  /// Format estimated time to readable string
  static String formatEstimatedTime(int minutes) {
    if (minutes < 1) {
      return '< 1 menit';
    } else if (minutes < 60) {
      return '$minutes menit';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours jam';
      } else {
        return '$hours jam $remainingMinutes menit';
      }
    }
  }

  /// Get complete tracking info
  static Future<TrackingInfo?> getTrackingInfo(GeoPoint destination) async {
    try {
      final distance = await calculateDistanceFromCurrentLocation(destination);
      if (distance == null) return null;

      final estimatedMinutes = estimateTimeInMinutes(distance);

      return TrackingInfo(
        distanceKm: distance,
        distanceFormatted: formatDistance(distance),
        estimatedMinutes: estimatedMinutes,
        estimatedTimeFormatted: formatEstimatedTime(estimatedMinutes),
      );
    } catch (e) {
      print('❌ Error getting tracking info: $e');
      return null;
    }
  }
}

/// Model untuk tracking info
class TrackingInfo {
  final double distanceKm;
  final String distanceFormatted;
  final int estimatedMinutes;
  final String estimatedTimeFormatted;

  TrackingInfo({
    required this.distanceKm,
    required this.distanceFormatted,
    required this.estimatedMinutes,
    required this.estimatedTimeFormatted,
  });

  @override
  String toString() {
    return 'Distance: $distanceFormatted, ETA: $estimatedTimeFormatted';
  }
}