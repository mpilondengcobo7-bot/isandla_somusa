import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type; // match | request | pickup | rating | system
  final String? relatedId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.relatedId,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'title': title,
    'body': body,
    'type': type,
    'relatedId': relatedId,
    'isRead': isRead,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory NotificationModel.fromMap(Map<String, dynamic> m) => NotificationModel(
    id: m['id'] ?? '',
    userId: m['userId'] ?? '',
    title: m['title'] ?? '',
    body: m['body'] ?? '',
    type: m['type'] ?? 'system',
    relatedId: m['relatedId'],
    isRead: m['isRead'] ?? false,
    createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}
