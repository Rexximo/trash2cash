import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'points_service.dart';

class QRService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final PointsService _pointsService = PointsService();

  /// Parse QR data dari string JSON
  Map<String, dynamic>? parseQRData(String rawQR) {
    try {
      final data = json.decode(rawQR);
      
      // Validate required fields
      if (!_isValidQRFormat(data)) {
        return null;
      }
      
      return data;
    } catch (e) {
      print('❌ Error parsing QR: $e');
      return null;
    }
  }

  /// Validate QR format
  bool _isValidQRFormat(dynamic data) {
    if (data is! Map<String, dynamic>) return false;
    
    return data.containsKey('type') &&
           data['type'] == 'trash2cash' &&
           data.containsKey('wasteType') &&
           data.containsKey('weight') &&
           data.containsKey('points') &&
           data.containsKey('id');
  }

  /// Check apakah QR sudah pernah di-scan
  Future<bool> isQRAlreadyScanned(String qrId) async {
    try {
      final doc = await _firestore.collection('scanned_qr').doc(qrId).get();
      return doc.exists;
    } catch (e) {
      print('❌ Error checking QR: $e');
      return false;
    }
  }

  /// Get QR scan details (jika sudah di-scan)
  Future<Map<String, dynamic>?> getScannedQRDetails(String qrId) async {
    try {
      final doc = await _firestore.collection('scanned_qr').doc(qrId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('❌ Error getting QR details: $e');
      return null;
    }
  }

  /// Claim QR - Award points to customer
  Future<Map<String, dynamic>> claimQR({
    required String qrId,
    required String wasteType,
    required double weight,
    required int points,
    String? notes,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return {
          'success': false,
          'message': 'User tidak login',
        };
      }

      // 1. Check if QR already scanned
      final alreadyScanned = await isQRAlreadyScanned(qrId);
      if (alreadyScanned) {
        final details = await getScannedQRDetails(qrId);
        return {
          'success': false,
          'message': 'QR sudah pernah di-scan!',
          'scannedBy': details?['scannedByName'] ?? 'Unknown',
          'scannedAt': details?['scannedAt'],
        };
      }

      // 2. Get user data
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();
      final userName = userData?['displayName'] ?? 'Customer';

      // 3. Use Firestore Transaction untuk consistency
      await _firestore.runTransaction((transaction) async {
        // 3a. Save scanned QR record
        final qrRef = _firestore.collection('scanned_qr').doc(qrId);
        transaction.set(qrRef, {
          'qrId': qrId,
          'scannedBy': userId,
          'scannedByName': userName,
          'scannedAt': FieldValue.serverTimestamp(),
          'wasteType': wasteType,
          'weight': weight,
          'pointsEarned': points,
          'status': 'claimed',
          'notes': notes,
        });

        // 3b. Update user total points
        final userRef = _firestore.collection('users').doc(userId);
        transaction.update(userRef, {
          'totalPoints': FieldValue.increment(points),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 3c. Create points history
        final historyRef = _firestore.collection('points_history').doc();
        final calculation = '${_getPointsPerKg(wasteType)} poin/kg × ${weight.toStringAsFixed(1)} kg';
        
        transaction.set(historyRef, {
          'historyId': historyRef.id,
          'userId': userId,
          'type': 'earned',
          'wasteType': wasteType,
          'weight': weight,
          'pointsEarned': points,
          'calculation': calculation,
          'notes': notes ?? 'Scan QR Code',
          'qrId': qrId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      return {
        'success': true,
        'message': 'Poin berhasil diklaim!',
        'points': points,
      };
    } catch (e) {
      print('❌ Error claiming QR: $e');
      return {
        'success': false,
        'message': 'Gagal klaim poin: $e',
      };
    }
  }

  /// Helper: Get points per kg
  int _getPointsPerKg(String wasteType) {
    switch (wasteType.toLowerCase()) {
      case 'organik':
        return 20;
      case 'anorganik':
        return 25;
      case 'b3':
        return 15;
      default:
        return 20;
    }
  }

  /// Get user's scanned QR history
  Stream<List<Map<String, dynamic>>> getUserScannedQRHistory(String userId) {
    return _firestore
        .collection('scanned_qr')
        .where('scannedBy', isEqualTo: userId)
        .orderBy('scannedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  /// Validate QR data values
  bool validateQRValues({
    required String wasteType,
    required double weight,
    required int points,
  }) {
    // Check waste type
    if (!['organik', 'anorganik', 'b3'].contains(wasteType.toLowerCase())) {
      return false;
    }

    // Check weight (0.1 kg - 1000 kg range)
    if (weight < 0.1 || weight > 1000) {
      return false;
    }

    // Check points (1 - 50000 range)
    if (points < 1 || points > 50000) {
      return false;
    }

    // Validate calculation makes sense
    final expectedPoints = (_getPointsPerKg(wasteType) * weight).round();
    final difference = (points - expectedPoints).abs();
    
    // Allow 10% tolerance
    if (difference > expectedPoints * 0.1) {
      return false;
    }

    return true;
  }
}