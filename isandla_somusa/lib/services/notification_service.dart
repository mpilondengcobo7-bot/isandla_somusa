import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';
import '../utils/app_constants.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  final _uuid = const Uuid();

  Future<void> init() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    FirebaseMessaging.onMessage.listen((message) {
      _showLocalNotification(message);
    });
  }

  Future<String?> getToken() => _fcm.getToken();

  Future<void> saveToken(String userId, String token) async {
    await _db.collection(AppConstants.colUsers).doc(userId).update({
      'fcmToken': token,
    });
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _local.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'somusa_channel',
          'Somusa Notifications',
          channelDescription: 'Isandla Somusa app notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // ── Save notification to Firestore ─────────────────────────────────
  Future<void> saveNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? relatedId,
  }) async {
    final id = _uuid.v4();
    final notif = NotificationModel(
      id: id,
      userId: userId,
      title: title,
      body: body,
      type: type,
      relatedId: relatedId,
      createdAt: DateTime.now(),
    );
    await _db
        .collection(AppConstants.colNotifications)
        .doc(id)
        .set(notif.toMap());
  }

  // ── Stream user notifications ──────────────────────────────────────
  Stream<List<NotificationModel>> streamNotifications(String userId) {
    return _db
        .collection(AppConstants.colNotifications)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => NotificationModel.fromMap(d.data())).toList());
  }

  Future<void> markAsRead(String notifId) async {
    await _db
        .collection(AppConstants.colNotifications)
        .doc(notifId)
        .update({'isRead': true});
  }

  Future<int> unreadCount(String userId) async {
    final snap = await _db
        .collection(AppConstants.colNotifications)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .count()
        .get();
    return snap.count ?? 0;
  }
}
