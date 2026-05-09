import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';
import '../utils/app_constants.dart';
import 'auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  final _pages = const [
    _OnboardPage(
      icon: Icons.volunteer_activism,
      color: AppTheme.tealGreen,
      title: 'Welcome to Somusa',
      subtitle: 'The helping hand connecting food donors\nwith people and charities in need.',
    ),
    _OnboardPage(
      icon: Icons.restaurant,
      color: AppTheme.forestGreen,
      title: 'Donate surplus food',
      subtitle: 'Campuses and restaurants can post\nexcess food in seconds — no food wasted.',
    ),
    _OnboardPage(
      icon: Icons.people,
      color: AppTheme.warmAmber,
      title: 'Request what you need',
      subtitle: 'Browse nearby donations, request food,\nand schedule a pickup time that works for you.',
    ),
    _OnboardPage(
      icon: Icons.psychology,
      color: AppTheme.coralAccent,
      title: 'AI-powered matching',
      subtitle: 'Somusa\'s smart matching engine\nconnects the right donor with the right recipient.',
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefOnboardingDone, true);
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip', style: TextStyle(color: AppTheme.tealGreen)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _pages[i],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _page == i ? 24 : 8, height: 8,
                decoration: BoxDecoration(
                  color: _page == i ? AppTheme.tealGreen : AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: _page == _pages.length - 1
                    ? _finish
                    : () => _ctrl.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut),
                child: Text(_page == _pages.length - 1 ? 'Get Started' : 'Next'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  const _OnboardPage({required this.icon, required this.color,
      required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140, height: 140,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 72, color: color),
          ),
          const SizedBox(height: 40),
          Text(title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(subtitle,
            style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
            textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
