import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & POPIA')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _Section('About POPIA',
            'Isandla Somusa complies with the Protection of Personal Information Act (POPIA) of South Africa. We are committed to protecting your personal information and your right to privacy.'),
          _Section('Information we collect', 
            '• Full name and email address\n• Phone number (optional)\n• Location data (for matching donors and recipients)\n• Organisation or campus name (for donors)\n• App usage data to improve our service'),
          _Section('How we use your information',
            '• To match food donors with recipients nearby\n• To send notifications about donations and requests\n• To calculate and display ratings\n• To improve the Somusa platform'),
          _Section('Data security',
            '• Passwords are hashed using SHA-256 before storage\n• All data is transmitted over encrypted HTTPS connections\n• Firebase security rules restrict access based on your role\n• We never sell or share your data with third parties'),
          _Section('Your rights under POPIA',
            '• Right to access your personal information\n• Right to correct inaccurate information\n• Right to delete your account and data\n• Right to object to processing of your information'),
          _Section('Delete your account',
            'You can delete your account at any time from the Profile screen. This will permanently remove all your personal data from our systems.'),
          _Section('Contact us',
            'For any privacy concerns or data requests, contact us at:\nsupport@somusa.co.za'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.tealGreen.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.verified_user_outlined, color: AppTheme.tealGreen),
              SizedBox(width: 12),
              Expanded(child: Text(
                'Isandla Somusa is fully POPIA compliant. Your data is safe with us.',
                style: TextStyle(color: AppTheme.tealGreen, fontWeight: FontWeight.w500),
              )),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title, content;
  const _Section(this.title, this.content);
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 20),
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.tealGreen)),
      const SizedBox(height: 8),
      Text(content, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.6)),
      const Divider(height: 32),
    ],
  );
}
