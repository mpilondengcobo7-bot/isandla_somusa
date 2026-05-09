import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../utils/validators.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../donor/donor_home_screen.dart';
import '../recipient/recipient_home_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  String _selectedRole = AppConstants.roleRecipient;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signIn(
        email: _emailCtrl.text, password: _passCtrl.text);
    if (!mounted) return;
    if (ok) _navigate(auth);
    else _showError(auth.error ?? 'Login failed');
  }

  Future<void> _googleLogin() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.signInWithGoogle(role: _selectedRole);
    if (!mounted) return;
    if (ok) _navigate(auth);
    else _showError(auth.error ?? 'Google sign-in failed');
  }

  void _navigate(AuthProvider auth) {
    // Start real-time notification listening
    context.read<NotificationProvider>()
        .listenToUnreadCount(auth.user!.uid);

    Widget dest;
    if (auth.isAdmin)      dest = const AdminDashboardScreen();
    else if (auth.isDonor) dest = const DonorHomeScreen();
    else                   dest = const RecipientHomeScreen();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => dest));
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.errorRed));

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              const SizedBox(height: 40),
              Center(child: Column(children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.tealGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.volunteer_activism,
                      color: Colors.white, size: 44),
                ),
                const SizedBox(height: 12),
                const Text('Somusa',
                    style: TextStyle(fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.tealGreen)),
                const SizedBox(height: 4),
                Text(AppConstants.appTagline,
                    style: TextStyle(
                        color: Colors.grey[600], fontSize: 13)),
              ])),
              const SizedBox(height: 40),
              const Text('Welcome back',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Sign in to continue',
                  style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 24),
              Row(children: [
                _RoleChip(
                    label: 'Recipient',
                    value: AppConstants.roleRecipient,
                    selected: _selectedRole,
                    onTap: (v) => setState(() => _selectedRole = v)),
                const SizedBox(width: 8),
                _RoleChip(
                    label: 'Donor',
                    value: AppConstants.roleDonor,
                    selected: _selectedRole,
                    onTap: (v) => setState(() => _selectedRole = v)),
                const SizedBox(width: 8),
                _RoleChip(
                    label: 'Admin',
                    value: AppConstants.roleAdmin,
                    selected: _selectedRole,
                    onTap: (v) => setState(() => _selectedRole = v)),
              ]),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(Icons.email_outlined)),
                validator: Validators.email,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () =>
                        setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? 'Password is required' : null,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen())),
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: 8),
              auth.loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text('Sign in')),
              const SizedBox(height: 16),
              Row(children: [
                const Expanded(child: Divider()),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or',
                        style: TextStyle(color: Colors.grey[500]))),
                const Expanded(child: Divider()),
              ]),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: auth.loading ? null : _googleLogin,
                icon: const Icon(Icons.g_mobiledata, size: 24),
                label: const Text('Continue with Google'),
              ),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("Don't have an account? ",
                    style: TextStyle(color: Colors.grey[600])),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const RegisterScreen())),
                  child: const Text('Register',
                      style: TextStyle(
                          color: AppTheme.tealGreen,
                          fontWeight: FontWeight.bold)),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label, value, selected;
  final void Function(String) onTap;
  const _RoleChip({required this.label, required this.value,
      required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.tealGreen : Colors.transparent,
          border: Border.all(
              color: isSelected ? AppTheme.tealGreen : AppTheme.lightGray),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          )),
      ),
    );
  }
}
