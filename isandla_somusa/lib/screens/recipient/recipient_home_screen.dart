import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donation_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/donation_model.dart';
import '../../models/user_model.dart';
import '../../services/ai_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../widgets/donation_card.dart';
import '../shared/notifications_screen.dart';
import '../shared/profile_screen.dart';
import '../shared/chatbot_screen.dart';
import '../shared/map_screen.dart';
import 'recipient_requests_screen.dart';
import '../donor/donation_detail_screen.dart';

class RecipientHomeScreen extends StatefulWidget {
  const RecipientHomeScreen({super.key});
  @override
  State<RecipientHomeScreen> createState() => _RecipientHomeScreenState();
}

class _RecipientHomeScreenState extends State<RecipientHomeScreen> {
  int _tab = 0;
  double? _lat, _lng;
  String _search = '';
  String _filterCategory = 'All';

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm != LocationPermission.deniedForever) {
        final pos = await Geolocator.getCurrentPosition();
        if (mounted) setState(() { _lat = pos.latitude; _lng = pos.longitude; });
      }
    } catch (_) {
      setState(() { _lat = AppConstants.defaultLat; _lng = AppConstants.defaultLng; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth  = context.watch<AuthProvider>();
    final notif = context.watch<NotificationProvider>();

    final screens = [
      _FeedTab(lat: _lat, lng: _lng, user: auth.user, search: _search, category: _filterCategory,
        onSearchChanged: (v) => setState(() => _search = v),
        onCategoryChanged: (v) => setState(() => _filterCategory = v)),
      MapScreen(lat: _lat ?? AppConstants.defaultLat, lng: _lng ?? AppConstants.defaultLng),
      const RecipientRequestsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          Icon(Icons.volunteer_activism, color: Colors.white),
          SizedBox(width: 8),
          Text('Somusa'),
        ]),
        actions: [
          Stack(children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen())),
            ),
            if (notif.unreadCount > 0)
              Positioned(right: 8, top: 8, child: Container(
                width: 16, height: 16,
                decoration: const BoxDecoration(color: AppTheme.coralAccent, shape: BoxShape.circle),
                child: Text('${notif.unreadCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center),
              )),
          ]),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen())),
          ),
        ],
      ),
      body: screens[_tab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Browse'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'My requests'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _FeedTab extends StatelessWidget {
  final double? lat, lng;
  final UserModel? user;
  final String search, category;
  final void Function(String) onSearchChanged;
  final void Function(String) onCategoryChanged;

  const _FeedTab({this.lat, this.lng, this.user, required this.search,
      required this.category, required this.onSearchChanged, required this.onCategoryChanged});

  @override
  Widget build(BuildContext context) {
    final prov = context.read<DonationProvider>();

    return StreamBuilder<List<DonationModel>>(
      stream: prov.streamAvailable(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());

        var donations = snap.data ?? [];

        // AI rank if location available
        if (lat != null && lng != null && user != null) {
          donations = AiService.rankDonations(
            donations: donations, recipient: user!,
            recipientLat: lat!, recipientLng: lng!);
        }

        // Search filter
        if (search.isNotEmpty) {
          donations = donations.where((d) =>
            d.title.toLowerCase().contains(search.toLowerCase()) ||
            d.category.toLowerCase().contains(search.toLowerCase()) ||
            d.donorName.toLowerCase().contains(search.toLowerCase())).toList();
        }

        // Category filter
        if (category != 'All') {
          donations = donations.where((d) => d.category == category).toList();
        }

        return Column(children: [
          // Search + filter bar
          Container(
            color: AppTheme.tealGreen,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(children: [
              TextField(
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search donations...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.tealGreen),
                  fillColor: Colors.white, filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(height: 36,
                child: ListView(scrollDirection: Axis.horizontal,
                  children: ['All', ...AppConstants.foodCategories].map((cat) {
                    final sel = category == cat;
                    return GestureDetector(
                      onTap: () => onCategoryChanged(cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: sel ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: sel ? Colors.white : Colors.white54),
                        ),
                        child: Text(cat,
                          style: TextStyle(color: sel ? AppTheme.tealGreen : Colors.white,
                            fontWeight: sel ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
                      ),
                    );
                  }).toList()),
              ),
            ]),
          ),
          // AI badge
          if (lat != null)
            Container(
              width: double.infinity, color: AppTheme.tealGreen.withOpacity(0.06),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: const Row(children: [
                Icon(Icons.psychology, size: 14, color: AppTheme.tealGreen),
                SizedBox(width: 6),
                Text('Sorted by Somusa AI — best matches near you',
                  style: TextStyle(fontSize: 12, color: AppTheme.tealGreen, fontWeight: FontWeight.w500)),
              ]),
            ),
          Expanded(
            child: donations.isEmpty
                ? const Center(child: Text('No donations found', style: TextStyle(color: Colors.grey)))
                : RefreshIndicator(
                    onRefresh: () async {},
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 80),
                      itemCount: donations.length,
                      itemBuilder: (_, i) => DonationCard(
                        donation: donations[i],
                        recipientLat: lat, recipientLng: lng,
                        onTap: () => Navigator.push(ctx, MaterialPageRoute(
                          builder: (_) => DonationDetailScreen(
                              donation: donations[i], isRecipientView: true))),
                      ),
                    ),
                  ),
          ),
        ]);
      },
    );
  }
}
