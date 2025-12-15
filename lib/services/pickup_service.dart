import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/pickup_model.dart';

class PickupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Create pickup request
  Future<String?> createPickup(PickupModel pickup) async {
    try {
      print('📤 Creating pickup request...');
      
      final docRef = await _firestore.collection('pickups').add(pickup.toFirestore());
      
      // Update pickupId dengan document ID
      await docRef.update({'pickupId': docRef.id});
      
      print('✅ Pickup created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating pickup: $e');
      return null;
    }
  }

  /// Get customer's pickups
  Stream<List<PickupModel>> getCustomerPickups() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('pickups')
        .where('customerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PickupModel.fromFirestore(doc))
            .toList());
  }

  /// Get all pickups for petugas
  Stream<List<PickupModel>> getAllPickups({PickupStatus? filterStatus}) {
    Query query = _firestore.collection('pickups');
    
    if (filterStatus != null) {
      query = query.where('status', isEqualTo: filterStatus.name);
    }
    
    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PickupModel.fromFirestore(doc))
            .toList());
  }

  /// Update pickup status
  Future<bool> updatePickupStatus({
    required String pickupId,
    required PickupStatus newStatus,
    String? petugasId,
    String? petugasName,
    String? notes,
  }) async {
    try {
      final updateData = {
        'status': newStatus.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (petugasId != null) updateData['assignedPetugasId'] = petugasId;
      if (petugasName != null) updateData['assignedPetugasName'] = petugasName;
      if (notes != null) updateData['notes'] = notes;
      
      if (newStatus == PickupStatus.completed) {
        updateData['completedAt'] = FieldValue.serverTimestamp();
      }

      await _firestore.collection('pickups').doc(pickupId).update(updateData);
      
      print('✅ Pickup status updated to ${newStatus.name}');
      return true;
    } catch (e) {
      print('❌ Error updating pickup: $e');
      return false;
    }
  }

  /// Delete pickup (only if pending)
  Future<bool> deletePickup(String pickupId) async {
    try {
      await _firestore.collection('pickups').doc(pickupId).delete();
      print('✅ Pickup deleted');
      return true;
    } catch (e) {
      print('❌ Error deleting pickup: $e');
      return false;
    }
  }
}