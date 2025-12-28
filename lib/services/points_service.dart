import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/points_history_model.dart';

class PointsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Tarif poin per kg
  static const Map<String, int> pointsRate = {
    'organik': 20,
    'anorganik': 25,
    'b3': 15,
  };

  /// Calculate points berdasarkan jenis & berat
  int calculatePoints(String wasteType, double weight) {
    final rate = pointsRate[wasteType.toLowerCase()] ?? 0;
    return (rate * weight).round();
  }

  /// Award points ke customer (dengan transaction untuk consistency)
  Future<bool> awardPoints({
    required String customerId,
    required String pickupId,
    required String wasteType,
    required double weight,
    required String petugasId,
    required String petugasName,
    String? notes,
  }) async {
    try {
      print('💰 Awarding points...');
      
      final points = calculatePoints(wasteType, weight);
      final rate = pointsRate[wasteType.toLowerCase()] ?? 0;
      final calculation = '$rate poin/kg × ${weight.toStringAsFixed(1)} kg';

      // Use Firestore transaction untuk consistency
      await _firestore.runTransaction((transaction) async {
        // 1. Update total points di user document
        final userRef = _firestore.collection('users').doc(customerId);
        final userDoc = await transaction.get(userRef);
        
        final currentPoints = userDoc.data()?['totalPoints'] ?? 0;
        transaction.update(userRef, {
          'totalPoints': currentPoints + points,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 2. Create history record
        final historyRef = _firestore.collection('points_history').doc();
        final history = PointsHistoryModel(
          historyId: historyRef.id,
          userId: customerId,
          pickupId: pickupId,
          pointsEarned: points,
          wasteType: wasteType,
          weight: weight,
          calculation: calculation,
          petugasId: petugasId,
          petugasName: petugasName,
          createdAt: DateTime.now(),
          notes: notes,
          type: PointsType.earned,
        );

        transaction.set(historyRef, history.toFirestore());

        print('✅ Points awarded: $points to user $customerId');
      });

      return true;
    } catch (e) {
      print('❌ Error awarding points: $e');
      return false;
    }
  }

  /// Get total points for a user
  Future<int> getTotalPoints(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data()?['totalPoints'] ?? 0;
    } catch (e) {
      print('❌ Error getting total points: $e');
      return 0;
    }
  }

  /// Stream total points (real-time)
  Stream<int> getTotalPointsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data()?['totalPoints'] ?? 0);
  }

  /// Get points history for a user
  Stream<List<PointsHistoryModel>> getPointsHistory(String userId) {
    return _firestore
        .collection('points_history')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PointsHistoryModel.fromFirestore(doc))
            .toList());
  }

  /// Get points earned this month
  Future<int> getPointsThisMonth(String userId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final snapshot = await _firestore
          .collection('points_history')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'earned')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .get();

      int total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['pointsEarned'] ?? 0) as int;
      }

      return total;
    } catch (e) {
      print('❌ Error getting points this month: $e');
      return 0;
    }
  }

  /// Get total setoran count
  Future<int> getSetoranCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('points_history')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'earned')
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('❌ Error getting setoran count: $e');
      return 0;
    }
  }

  /// Calculate level dari total points
  Map<String, dynamic> calculateLevel(int totalPoints) {
    if (totalPoints < 1000) {
      return {
        'level': 1,
        'title': 'Eco Starter',
        'nextLevel': 1000,
        'progress': totalPoints / 1000,
      };
    } else if (totalPoints < 3000) {
      return {
        'level': 2,
        'title': 'Green Saver',
        'nextLevel': 3000,
        'progress': (totalPoints - 1000) / 2000,
      };
    } else if (totalPoints < 6000) {
      return {
        'level': 3,
        'title': 'Eco Hero',
        'nextLevel': 6000,
        'progress': (totalPoints - 3000) / 3000,
      };
    } else {
      return {
        'level': 4,
        'title': 'Earth Champion',
        'nextLevel': null,
        'progress': 1.0,
      };
    }
  }
}