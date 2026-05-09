import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});
  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _newDonations = true;
  bool _requestUpdates = true;
  bool _pickupReminders = true;
  bool _ratings = true;
  bool _systemUpdates = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _newDonations = prefs.getBool('notif_new_donations') ?? true;
      _requestUpdates = prefs.getBool('notif_request_updates') ?? true;
      _pickupReminders = prefs.getBool('notif_pickup_reminders') ?? true;
      _ratings = prefs.getBool('notif_ratings') ?? true;
      _systemUpdates = prefs.getBool('notif_system_updates') ?? false;
    });
  }

  Future<void> _savePref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification settings')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text('Push notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.tealGreen)),
          ),
          _NotifTile(
            icon: Icons.volunteer_activism_outlined,
            title: 'New donations nearby',
            subtitle: 'Get notified when food is available near you',
            value: _newDonations,
            onChanged: (v) { setState(() => _newDonations = v); _savePref('notif_new_donations', v); },
          ),
          _NotifTile(
            icon: Icons.assignment_outlined,
            title: 'Request updates',
            subtitle: 'Approval, rejection and completion alerts',
            value: _requestUpdates,
            onChanged: (v) { setState(() => _requestUpdates = v); _savePref('notif_request_updates', v); },
          ),
          _NotifTile(
            icon: Icons.local_shipping_outlined,
            title: 'Pickup reminders',
            subtitle: 'Reminders before your scheduled pickup time',
            value: _pickupReminders,
            onChanged: (v) { setState(() => _pickupReminders = v); _savePref('notif_pickup_reminders', v); },
          ),
          _NotifTile(
            icon: Icons.star_outline,
            title: 'Ratings & feedback',
            subtitle: 'When someone rates your donation or pickup',
            value: _ratings,
            onChanged: (v) { setState(() => _ratings = v); _savePref('notif_ratings', v); },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text('Other', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.tealGreen)),
          ),
          _NotifTile(
            icon: Icons.system_update_outlined,
            title: 'System updates',
            subtitle: 'App updates and announcements from Somusa',
            value: _systemUpdates,
            onChanged: (v) { setState(() => _systemUpdates = v); _savePref('notif_system_updates', v); },
          ),
        ],
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final bool value;
  final void Function(bool) onChanged;
  const _NotifTile({required this.icon, required this.title,
      required this.subtitle, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => SwitchListTile(
    secondary: Icon(icon, color: AppTheme.tealGreen),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
    subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
    value: value,
    activeColor: AppTheme.tealGreen,
    onChanged: onChanged,
  );
}
