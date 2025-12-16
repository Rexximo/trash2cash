import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/pickup_model.dart';
import 'points_service.dart';

class PickupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final PointsService _pointsService = PointsService();

  /// Complete pickup dengan konfirmasi & award points
  Future<bool> completePickupWithPoints({
    required String pickupId,
    required PickupModel pickup,
    required WasteType confirmedWasteType,
    required double confirmedWeight,
    required String petugasId,
    required String petugasName,
    String? notes,
  }) async {
    try {
      print('🎯 Completing pickup with points...');

      // 1. Award points ke customer
      final pointsAwarded = await _pointsService.awardPoints(
        customerId: pickup.customerId,
        pickupId: pickupId,
        wasteType: confirmedWasteType.name,
        weight: confirmedWeight,
        petugasId: petugasId,
        petugasName: petugasName,
        notes: notes,
      );

      if (!pointsAwarded) {
        print('❌ Failed to award points');
        return false;
      }

      // 2. Update pickup document
      final calculatedPoints = _pointsService.calculatePoints(
        confirmedWasteType.name,
        confirmedWeight,
      );

      await _firestore.collection('pickups').doc(pickupId).update({
        'status': PickupStatus.completed.name,
        'confirmedWasteType': confirmedWasteType.name,
        'confirmedWeight': confirmedWeight,
        'pointsAwarded': calculatedPoints,
        'confirmedAt': FieldValue.serverTimestamp(),
        'confirmedBy': petugasId,
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'notes': notes,
      });

      print('✅ Pickup completed successfully with $calculatedPoints points');
      return true;
    } catch (e) {
      print('❌ Error completing pickup with points: $e');
      return false;
    }
  }

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