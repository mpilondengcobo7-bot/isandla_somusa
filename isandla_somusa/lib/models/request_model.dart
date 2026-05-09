import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  final String id;
  final String donationId;
  final String donationTitle;
  final String recipientId;
  final String recipientName;
  final String? recipientPhoto;
  final String donorId;
  final String selectedTimeSlot;
  final String status;
  final String? message;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final DateTime? completedAt;
  final double? aiMatchScore;

  RequestModel({
    required this.id,
    required this.donationId,
    required this.donationTitle,
    required this.recipientId,
    required this.recipientName,
    this.recipientPhoto,
    required this.donorId,
    required this.selectedTimeSlot,
    this.status = 'pending',
    this.message,
    required this.createdAt,
    this.respondedAt,
    this.completedAt,
    this.aiMatchScore,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'donationId': donationId,
    'donationTitle': donationTitle,
    'recipientId': recipientId,
    'recipientName': recipientName,
    'recipientPhoto': recipientPhoto,
    'donorId': donorId,
    'selectedTimeSlot': selectedTimeSlot,
    'status': status,
    'message': message,
    'createdAt': Timestamp.fromDate(createdAt),
    'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
    'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    'aiMatchScore': aiMatchScore,
  };

  factory RequestModel.fromMap(Map<String, dynamic> m) => RequestModel(
    id: m['id'] ?? '',
    donationId: m['donationId'] ?? '',
    donationTitle: m['donationTitle'] ?? '',
    recipientId: m['recipientId'] ?? '',
    recipientName: m['recipientName'] ?? '',
    recipientPhoto: m['recipientPhoto'],
    donorId: m['donorId'] ?? '',
    selectedTimeSlot: m['selectedTimeSlot'] ?? '',
    status: m['status'] ?? 'pending',
    message: m['message'],
    createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    respondedAt: (m['respondedAt'] as Timestamp?)?.toDate(),
    completedAt: (m['completedAt'] as Timestamp?)?.toDate(),
    aiMatchScore: (m['aiMatchScore'] as num?)?.toDouble(),
  );
}
