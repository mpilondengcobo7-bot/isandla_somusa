import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Isandla Somusa')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const SizedBox(height: 20),
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: AppTheme.tealGreen,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.volunteer_activism, size: 56, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text('Isandla Somusa', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('"The helping hand"', style: TextStyle(color: AppTheme.tealGreen, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Version ${AppConstants.appVersion}', style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 32),
          _InfoCard(Icons.info_outline, 'Our mission',
            '"No food wasted. No one hungry." Isandla Somusa connects food donors — campuses and restaurants — with individuals and charities in need across South Africa.'),
          const SizedBox(height: 16),
          _InfoCard(Icons.psychology_outlined, 'AI-powered matching',
            'Our smart matching engine uses location proximity, expiry urgency, and user history to connect the right donor with the right recipient.'),
          const SizedBox(height: 16),
          _InfoCard(Icons.people_outline, 'Community impact',
            'Every donation on Somusa helps reduce food waste and fight hunger in our communities. Together we are making a difference — one meal at a time.'),
          const SizedBox(height: 16),
          _InfoCard(Icons.school_outlined, 'Academic project',
            'Isandla Somusa was developed as part of an Application Development Framework project — Group 14.'),
          const SizedBox(height: 32),
          Text('Built with Flutter & Firebase',
            style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          Text('© 2026 Isandla Somusa — Group 14',
            style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title, content;
  const _InfoCard(this.icon, this.title, this.content);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: AppTheme.tealGreen, size: 24),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        Text(content, style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5)),
      ])),
    ]),
  );
}
