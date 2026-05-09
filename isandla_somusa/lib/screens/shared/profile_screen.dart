import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'notification_settings_screen.dart';
import 'privacy_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user!;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            decoration: const BoxDecoration(
              color: AppTheme.tealGreen,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: user.photoUrl != null
                    ? ClipOval(child: Image.network(user.photoUrl!,
                        fit: BoxFit.cover, width: 80, height: 80))
                    : Text(
                        user.displayName.isNotEmpty
                            ? user.displayName[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.tealGreen)),
              ),
              const SizedBox(height: 12),
              Text(user.displayName,
                style: const TextStyle(color: Colors.white, fontSize: 20,
                    fontWeight: FontWeight.bold)),
              Text(user.email,
                style: TextStyle(color: Colors.white.withOpacity(0.8),
                    fontSize: 14)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20)),
                child: Text(user.role.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 12,
                      fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              _StatCard(
                label: user.role == 'donor' ? 'Donations' : 'Pickups',
                value: '${user.role == 'donor' ? user.totalDonations : user.totalPickups}',
                icon: user.role == 'donor'
                    ? Icons.volunteer_activism : Icons.shopping_bag_outlined,
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'Rating',
                value: user.rating > 0 ? user.rating.toStringAsFixed(1) : 'N/A',
                icon: Icons.star_outline,
                iconColor: AppTheme.warmAmber,
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'Verified',
                value: user.isVerified ? 'Yes' : 'No',
                icon: user.isVerified ? Icons.verified : Icons.pending_outlined,
                iconColor: user.isVerified
                    ? AppTheme.successGreen : AppTheme.lightGray,
              ),
            ]),
          ),

          _MenuItem(
            icon: Icons.person_outline,
            label: 'Edit profile',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen())),
          ),
          if (user.role == 'donor')
            _MenuItem(
              icon: Icons.location_on_outlined,
              label: 'Update location',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(
                    'Location updates automatically when you post a donation'))),
            ),
          _MenuItem(
            icon: Icons.notifications_outlined,
            label: 'Notification settings',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => const NotificationSettingsScreen())),
          ),
          _MenuItem(
            icon: Icons.lock_outline,
            label: 'Change password',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
          ),
          _MenuItem(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy & POPIA',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PrivacyScreen())),
          ),
          _MenuItem(
            icon: Icons.help_outline,
            label: 'Help & support',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Email us at support@somusa.co.za'))),
          ),
          _MenuItem(
            icon: Icons.info_outline,
            label: 'About Isandla Somusa',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AboutScreen())),
          ),

          const Divider(height: 32),

          _MenuItem(
            icon: Icons.logout,
            label: 'Sign out',
            labelColor: AppTheme.errorRed,
            iconColor: AppTheme.errorRed,
            onTap: () async {
              await auth.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false);
              }
            },
          ),

          const SizedBox(height: 32),
          Text('Isandla Somusa v1.0.0\nNo food wasted. No one hungry.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[400], fontSize: 12,
                height: 1.6)),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color? iconColor;
  const _StatCard({required this.label, required this.value,
      required this.icon, this.iconColor});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        Icon(icon, color: iconColor ?? AppTheme.tealGreen, size: 24),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ]),
    ),
  );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor, iconColor;
  const _MenuItem({required this.icon, required this.label,
      required this.onTap, this.labelColor, this.iconColor});
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: iconColor ?? AppTheme.tealGreen),
    title: Text(label, style: TextStyle(color: labelColor)),
    trailing: const Icon(Icons.chevron_right, size: 20),
    onTap: onTap,
  );
}
