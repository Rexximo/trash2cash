import 'package:cloud_firestore/cloud_firestore.dart';

enum WasteType {
  organik,
  anorganik,
  b3;

  String get displayName {
    switch (this) {
      case WasteType.organik:
        return 'Organik';
      case WasteType.anorganik:
        return 'Anorganik';
      case WasteType.b3:
        return 'B3 (Berbahaya)';
    }
  }
}

enum PickupStatus {
  pending,
  accepted,
  inProgress,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case PickupStatus.pending:
        return 'Menunggu';
      case PickupStatus.accepted:
        return 'Diterima';
      case PickupStatus.inProgress:
        return 'Dalam Proses';
      case PickupStatus.completed:
        return 'Selesai';
      case PickupStatus.cancelled:
        return 'Dibatalkan';
    }
  }
}

class PickupModel {
  final String pickupId;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String? customerPhone;
  
  final WasteType wasteType;
  final double weight;
  final String? description;
  final String? photoUrl;
  
  final GeoPoint location;
  final String address;
  
  final PickupStatus status;
  final String? assignedPetugasId;
  final String? assignedPetugasName;
  
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  
  final String? notes;

  PickupModel({
    required this.pickupId,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    this.customerPhone,
    required this.wasteType,
    required this.weight,
    this.description,
    this.photoUrl,
    required this.location,
    required this.address,
    required this.status,
    this.assignedPetugasId,
    this.assignedPetugasName,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.notes,
  });

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'pickupId': pickupId,
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'wasteType': wasteType.name,
      'weight': weight,
      'description': description,
      'photoUrl': photoUrl,
      'location': location,
      'address': address,
      'status': status.name,
      'assignedPetugasId': assignedPetugasId,
      'assignedPetugasName': assignedPetugasName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'notes': notes,
    };
  }

  // Create from Firestore
  factory PickupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return PickupModel(
      pickupId: data['pickupId'] ?? '',
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      customerEmail: data['customerEmail'] ?? '',
      customerPhone: data['customerPhone'],
      wasteType: WasteType.values.firstWhere(
        (e) => e.name == data['wasteType'],
        orElse: () => WasteType.organik,
      ),
      weight: (data['weight'] ?? 0).toDouble(),
      description: data['description'],
      photoUrl: data['photoUrl'],
      location: data['location'] as GeoPoint,
      address: data['address'] ?? '',
      status: PickupStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => PickupStatus.pending,
      ),
      assignedPetugasId: data['assignedPetugasId'],
      assignedPetugasName: data['assignedPetugasName'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
      completedAt: data['completedAt'] != null ? (data['completedAt'] as Timestamp).toDate() : null,
      notes: data['notes'],
    );
  }
}