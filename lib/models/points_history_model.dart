import 'package:cloud_firestore/cloud_firestore.dart';

enum PointsType {
  earned,  // Dapat dari setoran
  spent;   // Pakai untuk reward (dummy)
  
  String get displayName {
    switch (this) {
      case PointsType.earned:
        return 'Setoran Sampah';
      case PointsType.spent:
        return 'Tukar Reward';
    }
  }
}

class PointsHistoryModel {
  final String historyId;
  final String userId;
  final String pickupId;
  final int pointsEarned;
  final String wasteType;
  final double weight;
  final String calculation;
  final String petugasId;
  final String petugasName;
  final DateTime createdAt;
  final String? notes;
  final PointsType type;

  PointsHistoryModel({
    required this.historyId,
    required this.userId,
    required this.pickupId,
    required this.pointsEarned,
    required this.wasteType,
    required this.weight,
    required this.calculation,
    required this.petugasId,
    required this.petugasName,
    required this.createdAt,
    this.notes,
    this.type = PointsType.earned,
  });

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'historyId': historyId,
      'userId': userId,
      'pickupId': pickupId,
      'pointsEarned': pointsEarned,
      'wasteType': wasteType,
      'weight': weight,
      'calculation': calculation,
      'petugasId': petugasId,
      'petugasName': petugasName,
      'createdAt': Timestamp.fromDate(createdAt),
      'notes': notes,
      'type': type.name,
    };
  }

  // From Firestore
  factory PointsHistoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return PointsHistoryModel(
      historyId: data['historyId'] ?? doc.id,
      userId: data['userId'] ?? '',
      pickupId: data['pickupId'] ?? '',
      pointsEarned: data['pointsEarned'] ?? 0,
      wasteType: data['wasteType'] ?? '',
      weight: (data['weight'] ?? 0).toDouble(),
      calculation: data['calculation'] ?? '',
      petugasId: data['petugasId'] ?? '',
      petugasName: data['petugasName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      notes: data['notes'],
      type: PointsType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => PointsType.earned,
      ),
    );
  }

  // Helper untuk display
  String get wasteTypeDisplay {
    switch (wasteType.toLowerCase()) {
      case 'organik':
        return 'Organik';
      case 'anorganik':
        return 'Anorganik';
      case 'b3':
        return 'B3';
      default:
        return wasteType;
    }
  }
}