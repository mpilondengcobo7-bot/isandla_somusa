import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../models/donation_model.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../utils/helpers.dart';
import '../auth/login_screen.dart';
import '../shared/chatbot_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _tab = 0;
  final _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Somusa Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (mounted) Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: _tab == 0 ? _DashboardTab(db: _db) : _UsersTab(db: _db),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Users'),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final FirebaseFirestore db;
  const _DashboardTab({required this.db});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Platform overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(children: [
          _StatCard(db: db, collection: AppConstants.colUsers, label: 'Total users', icon: Icons.people, color: AppTheme.tealGreen),
          const SizedBox(width: 12),
          _StatCard(db: db, collection: AppConstants.colDonations, label: 'Donations', icon: Icons.volunteer_activism, color: AppTheme.forestGreen),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _StatCard(db: db, collection: AppConstants.colRequests, label: 'Requests', icon: Icons.assignment, color: AppTheme.warmAmber),
          const SizedBox(width: 12),
          _StatCard(db: db, collection: AppConstants.colRatings, label: 'Ratings', icon: Icons.star, color: AppTheme.coralAccent),
        ]),
        const SizedBox(height: 24),
        const Text('Recent donations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: db.collection(AppConstants.colDonations)
              .orderBy('createdAt', descending: true)
              .limit(10)
              .snapshots(),
          builder: (ctx, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final docs = snap.data!.docs;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (_, i) {
                final d = DonationModel.fromMap(docs[i].data() as Map<String, dynamic>);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.tealGreen.withOpacity(0.1),
                    child: const Icon(Icons.restaurant, color: AppTheme.tealGreen, size: 20),
                  ),
                  title: Text(d.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: Text('${d.donorName} · ${Helpers.timeAgo(d.createdAt)}', style: const TextStyle(fontSize: 12)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: d.status == 'available'
                          ? AppTheme.successGreen.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      Helpers.statusLabel(d.status),
                      style: TextStyle(
                        fontSize: 11,
                        color: d.status == 'available' ? AppTheme.successGreen : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final FirebaseFirestore db;
  final String collection, label;
  final IconData icon;
  final Color color;
  const _StatCard({required this.db, required this.collection, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: StreamBuilder<QuerySnapshot>(
      stream: db.collection(collection).snapshots(),
      builder: (ctx, snap) {
        final count = snap.data?.docs.length ?? 0;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text('$count', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8))),
          ]),
        );
      },
    ),
  );
}

class _UsersTab extends StatelessWidget {
  final FirebaseFirestore db;
  const _UsersTab({required this.db});

  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot>(
    stream: db.collection(AppConstants.colUsers).orderBy('createdAt', descending: true).snapshots(),
    builder: (ctx, snap) {
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      final users = snap.data!.docs
          .map((d) => UserModel.fromMap(d.data() as Map<String, dynamic>))
          .toList();
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (_, i) {
          final u = users[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.tealGreen,
                child: Text(
                  u.displayName.isNotEmpty ? u.displayName[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(u.displayName, style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text('${u.email} · ${u.role}', style: const TextStyle(fontSize: 12)),
              trailing: Switch(
                value: u.isActive,
                activeColor: AppTheme.tealGreen,
                onChanged: (v) => db.collection(AppConstants.colUsers).doc(u.uid).update({'isActive': v}),
              ),
            ),
          );
        },
      );
    },
  );
}
