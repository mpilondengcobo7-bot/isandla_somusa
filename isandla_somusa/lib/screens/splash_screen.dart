import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../utils/app_theme.dart';
import '../utils/app_constants.dart';
import 'auth/login_screen.dart';
import 'donor/donor_home_screen.dart';
import 'recipient/recipient_home_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final onboardingDone =
        prefs.getBool(AppConstants.prefOnboardingDone) ?? false;

    if (!onboardingDone) {
      _go(const OnboardingScreen());
      return;
    }

    final auth = context.read<AuthProvider>();
    await auth.loadCurrentUser();

    if (!mounted) return;
    if (!auth.isLoggedIn) {
      _go(const LoginScreen());
      return;
    }

    // Start listening to notifications in real time
    context.read<NotificationProvider>().listenToUnreadCount(auth.user!.uid);

    if (!mounted) return;
    if (auth.isAdmin)      { _go(const AdminDashboardScreen()); return; }
    if (auth.isDonor)      { _go(const DonorHomeScreen()); return; }
    _go(const RecipientHomeScreen());
  }

  void _go(Widget screen) => Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (_) => screen));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.tealGreen,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: const Offset(0, 8))],
                  ),
                  child: const Icon(Icons.volunteer_activism,
                      size: 64, color: AppTheme.tealGreen),
                ),
                const SizedBox(height: 24),
                const Text('Isandla Somusa',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                      color: Colors.white, letterSpacing: 0.5)),
                const SizedBox(height: 8),
                Text(AppConstants.appTagline,
                  style: TextStyle(
                      fontSize: 14, color: Colors.white.withOpacity(0.85))),
                const SizedBox(height: 48),
                const CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
