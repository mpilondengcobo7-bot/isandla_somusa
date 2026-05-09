import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../utils/validators.dart';
import '../donor/donor_home_screen.dart';
import '../recipient/recipient_home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _orgCtrl   = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _confCtrl  = TextEditingController();
  bool _obscureP = true, _obscureC = true;
  String _role = AppConstants.roleRecipient;

  @override
  void dispose() {
    _nameCtrl.dispose(); _orgCtrl.dispose(); _emailCtrl.dispose();
    _phoneCtrl.dispose(); _passCtrl.dispose(); _confCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      email: _emailCtrl.text,
      password: _passCtrl.text,
      displayName: _nameCtrl.text.trim(),
      role: _role,
      organisationName: _orgCtrl.text.trim().isEmpty ? null : _orgCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => _role == AppConstants.roleDonor
            ? const DonorHomeScreen()
            : const RecipientHomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Registration failed'),
            backgroundColor: AppTheme.errorRed));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('I am a...', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 12),
            Row(children: [
              _RoleOption(label: 'Recipient', icon: Icons.people,
                  value: AppConstants.roleRecipient, selected: _role,
                  onTap: (v) => setState(() => _role = v)),
              const SizedBox(width: 12),
              _RoleOption(label: 'Donor', icon: Icons.restaurant,
                  value: AppConstants.roleDonor, selected: _role,
                  onTap: (v) => setState(() => _role = v)),
            ]),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Full name *', prefixIcon: Icon(Icons.person_outline)),
              validator: (v) => Validators.required(v, fieldName: 'Full name'),
            ),
            const SizedBox(height: 16),
            if (_role == AppConstants.roleDonor) ...[
              TextFormField(
                controller: _orgCtrl,
                decoration: const InputDecoration(labelText: 'Organisation / campus name', prefixIcon: Icon(Icons.business_outlined)),
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email address *', prefixIcon: Icon(Icons.email_outlined)),
              validator: Validators.email,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone number (optional)', prefixIcon: Icon(Icons.phone_outlined)),
              validator: Validators.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passCtrl,
              obscureText: _obscureP,
              decoration: InputDecoration(
                labelText: 'Password *',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscureP ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscureP = !_obscureP),
                ),
                helperText: 'Min 8 chars, 1 uppercase, 1 number',
              ),
              validator: Validators.password,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confCtrl,
              obscureText: _obscureC,
              decoration: InputDecoration(
                labelText: 'Confirm password *',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscureC ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscureC = !_obscureC),
                ),
              ),
              validator: (v) => Validators.confirmPassword(v, _passCtrl.text),
            ),
            const SizedBox(height: 8),
            Text('By registering, you agree to our Terms of Service and Privacy Policy (POPIA compliant).',
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 24),
            auth.loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(onPressed: _register, child: const Text('Create account')),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Already have an account? ', style: TextStyle(color: Colors.grey[600])),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text('Sign in', style: TextStyle(color: AppTheme.tealGreen, fontWeight: FontWeight.bold)),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  final String label, value, selected;
  final IconData icon;
  final void Function(String) onTap;
  const _RoleOption({required this.label, required this.icon,
      required this.value, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final sel = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: sel ? AppTheme.tealGreen.withOpacity(0.1) : Colors.transparent,
            border: Border.all(color: sel ? AppTheme.tealGreen : AppTheme.lightGray, width: sel ? 2 : 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: [
            Icon(icon, color: sel ? AppTheme.tealGreen : Colors.grey, size: 32),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(
              color: sel ? AppTheme.tealGreen : Colors.grey,
              fontWeight: sel ? FontWeight.bold : FontWeight.normal,
            )),
          ]),
        ),
      ),
    );
  }
}
