import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  Stream<List<NotificationModel>> streamNotifications(String userId) =>
      _service.streamNotifications(userId);

  Future<void> init() => _service.init();

  // ── Listen to real-time unread count ──────────────────────────────
  void listenToUnreadCount(String userId) {
    _service.streamNotifications(userId).listen((notifications) {
      final count = notifications.where((n) => !n.isRead).length;
      if (count != _unreadCount) {
        _unreadCount = count;
        notifyListeners();
      }
    });
  }

  Future<void> loadUnreadCount(String userId) async {
    _unreadCount = await _service.unreadCount(userId);
    notifyListeners();
  }

  Future<void> markAsRead(String notifId, String userId) async {
    await _service.markAsRead(notifId);
    await loadUnreadCount(userId);
  }

  Future<void> saveNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? relatedId,
  }) async {
    await _service.saveNotification(
      userId: userId,
      title: title,
      body: body,
      type: type,
      relatedId: relatedId,
    );
  }
}
