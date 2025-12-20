// File: lib/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get user display name stream (real-time)
  Stream<String> getUserDisplayName(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return 'Pejuang Lingkungan';
          return doc.data()?['displayName'] ?? 'Pejuang Lingkungan';
        });
  }

  /// Get user email stream
  Stream<String> getUserEmail(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data()?['email'] ?? '');
  }

  /// Get user role stream
  Stream<String> getUserRole(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data()?['role'] ?? 'customer');
  }

  /// Get complete user data stream
  Stream<Map<String, dynamic>?> getUserData(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return doc.data();
        });
  }

  /// Get user data once (tidak real-time)
  Future<Map<String, dynamic>?> getUserDataOnce(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      print('❌ Error getting user data: $e');
      return null;
    }
  }

  /// Update user display name
  Future<bool> updateDisplayName(String userId, String newName) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'displayName': newName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('❌ Error updating display name: $e');
      return false;
    }
  }

  /// Update last login
  Future<void> updateLastLogin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Error updating last login: $e');
    }
  }
}