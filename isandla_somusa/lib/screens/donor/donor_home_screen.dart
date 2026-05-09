import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donation_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/donation_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/donation_card.dart';
import '../shared/notifications_screen.dart';
import '../shared/profile_screen.dart';
import '../shared/chatbot_screen.dart';
import 'create_donation_screen.dart';
import 'donor_requests_screen.dart';
import 'donation_detail_screen.dart';

class DonorHomeScreen extends StatefulWidget {
  const DonorHomeScreen({super.key});
  @override
  State<DonorHomeScreen> createState() => _DonorHomeScreenState();
}

class _DonorHomeScreenState extends State<DonorHomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final notifProv = context.watch<NotificationProvider>();
    final user = auth.user!;

    final screens = [
      _DonorFeedTab(donorId: user.uid),
      const DonorRequestsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Icon(Icons.volunteer_activism, color: Colors.white),
          const SizedBox(width: 8),
          const Text('Somusa'),
        ]),
        actions: [
          Stack(children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen())),
            ),
            if (notifProv.unreadCount > 0)
              Positioned(right: 8, top: 8, child: Container(
                width: 16, height: 16,
                decoration: const BoxDecoration(color: AppTheme.coralAccent, shape: BoxShape.circle),
                child: Text('${notifProv.unreadCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                  textAlign: TextAlign.center),
              )),
          ]),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ChatbotScreen())),
          ),
        ],
      ),
      body: screens[_tab],
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CreateDonationScreen())),
              icon: const Icon(Icons.add),
              label: const Text('Donate food'),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home), label: 'My donations'),
          BottomNavigationBarItem(icon: Icon(Icons.inbox_outlined),
              activeIcon: Icon(Icons.inbox), label: 'Requests'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _DonorFeedTab extends StatelessWidget {
  final String donorId;
  const _DonorFeedTab({required this.donorId});

  @override
  Widget build(BuildContext context) {
    final prov = context.read<DonationProvider>();
    return StreamBuilder<List<DonationModel>>(
      stream: prov.streamMyDonations(donorId),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snap.hasData || snap.data!.isEmpty)
          return _EmptyState();
        final donations = snap.data!;
        return RefreshIndicator(
          onRefresh: () async {},
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: donations.length,
            itemBuilder: (_, i) => DonationCard(
              donation: donations[i],
              onTap: () => Navigator.push(ctx, MaterialPageRoute(
                builder: (_) => DonationDetailScreen(donation: donations[i]))),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.restaurant_outlined, size: 80, color: AppTheme.lightGray),
      const SizedBox(height: 16),
      const Text('No donations yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('Tap the button below to post your first donation',
        textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
    ]),
  );
}
