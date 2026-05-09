import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/validators.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent = false, _loading = false;

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().sendPasswordReset(_emailCtrl.text);
      if (mounted) setState(() { _sent = true; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppTheme.errorRed));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset password'), backgroundColor: Colors.transparent,
          foregroundColor: AppTheme.charcoal, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent
            ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.mark_email_read_outlined, size: 80, color: AppTheme.tealGreen),
                const SizedBox(height: 24),
                const Text('Email sent!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('Check your inbox at ${_emailCtrl.text} for a password reset link.',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                const SizedBox(height: 32),
                ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Back to sign in')),
              ])
            : Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 24),
                  const Text('Forgot your password?',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Enter your email and we\'ll send you a reset link.',
                    style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email address',
                        prefixIcon: Icon(Icons.email_outlined)),
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 24),
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(onPressed: _send, child: const Text('Send reset link')),
                ]),
              ),
      ),
    );
  }
}
