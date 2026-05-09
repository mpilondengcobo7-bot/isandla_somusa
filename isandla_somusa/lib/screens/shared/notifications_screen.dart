import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/helpers.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final auth = context.read<AuthProvider>();
    final notif = context.read<NotificationProvider>();
    
    notif.streamNotifications(auth.user!.uid).listen((list) {
      if (mounted) {
        setState(() {
          _notifications = list;
          _loading = false;
        });
      }
    });
  }

  Future<void> _markAllRead() async {
    final auth = context.read<AuthProvider>();
    final notif = context.read<NotificationProvider>();
    for (final n in _notifications.where((n) => !n.isRead)) {
      await notif.markAsRead(n.id, auth.user!.uid);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read'),
          backgroundColor: AppTheme.successGreen));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final notif = context.read<NotificationProvider>();
    final unread = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read',
                style: TextStyle(color: Colors.white, fontSize: 13)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none_outlined,
                        size: 80, color: AppTheme.lightGray),
                    SizedBox(height: 16),
                    Text('No notifications yet',
                        style: TextStyle(fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('You will be notified about donations,\nrequests and pickups here',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey)),
                  ],
                ))
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.separated(
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final n = _notifications[i];
                      return Dismissible(
                        key: Key(n.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: AppTheme.errorRed,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete_outline,
                              color: Colors.white),
                        ),
                        onDismissed: (_) async {
                          setState(() => _notifications.removeAt(i));
                          await notif.markAsRead(n.id, auth.user!.uid);
                        },
                        child: ListTile(
                          tileColor: n.isRead
                              ? null
                              : AppTheme.tealGreen.withOpacity(0.05),
                          leading: CircleAvatar(
                            backgroundColor:
                                _iconColor(n.type).withOpacity(0.15),
                            child: Icon(_typeIcon(n.type),
                                color: _iconColor(n.type), size: 20),
                          ),
                          title: Text(n.title,
                            style: TextStyle(
                              fontWeight: n.isRead
                                  ? FontWeight.normal : FontWeight.bold,
                              fontSize: 14)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.body,
                                  style: const TextStyle(fontSize: 13)),
                              const SizedBox(height: 2),
                              Text(Helpers.timeAgo(n.createdAt),
                                style: TextStyle(fontSize: 11,
                                    color: Colors.grey[500])),
                            ],
                          ),
                          isThreeLine: true,
                          onTap: () async {
                            if (!n.isRead) {
                              await notif.markAsRead(n.id, auth.user!.uid);
                              setState(() {
                                _notifications[i] = NotificationModel(
                                  id: n.id,
                                  userId: n.userId,
                                  title: n.title,
                                  body: n.body,
                                  type: n.type,
                                  relatedId: n.relatedId,
                                  isRead: true,
                                  createdAt: n.createdAt,
                                );
                              });
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'match':   return Icons.psychology;
      case 'request': return Icons.assignment_outlined;
      case 'pickup':  return Icons.local_shipping_outlined;
      case 'rating':  return Icons.star_outline;
      default:        return Icons.notifications_outlined;
    }
  }

  Color _iconColor(String type) {
    switch (type) {
      case 'match':   return AppTheme.tealGreen;
      case 'request': return AppTheme.warmAmber;
      case 'pickup':  return AppTheme.forestGreen;
      case 'rating':  return AppTheme.coralAccent;
      default:        return AppTheme.lightGray;
    }
  }
}
