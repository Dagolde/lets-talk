import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildContactSection(),
            const SizedBox(height: 16),
            _buildFAQSection(),
            const SizedBox(height: 16),
            _buildResourcesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Contact Support',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.email, color: Color(0xFF4CAF50)),
            title: const Text('Email Support'),
            subtitle: const Text('support@lets-talk.app'),
            onTap: () => _launchEmail('support@lets-talk.app'),
          ),
          ListTile(
            leading: const Icon(Icons.phone, color: Color(0xFF4CAF50)),
            title: const Text('Phone Support'),
            subtitle: const Text('+234 123 456 7890'),
            onTap: () => _launchPhone('+2341234567890'),
          ),
          ListTile(
            leading: const Icon(Icons.chat, color: Color(0xFF4CAF50)),
            title: const Text('Live Chat'),
            subtitle: const Text('Available 24/7'),
            onTap: () {
              // TODO: Implement live chat
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
          _buildFAQItem(
            'How do I change my profile picture?',
            'Go to Profile > Edit Profile > tap on your profile picture to select a new image from your gallery or take a photo.',
          ),
          _buildFAQItem(
            'How do I add money to my wallet?',
            'Go to Wallet > Add Money and choose your preferred payment method. We support multiple payment gateways.',
          ),
          _buildFAQItem(
            'How do I start a new conversation?',
            'Tap the + icon in the chat list or use the QR scanner to connect with other users.',
          ),
          _buildFAQItem(
            'How do I invite friends?',
            'Go to Contacts > tap the person_add icon to invite your phone contacts to Let\'s Talk.',
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildResourcesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Resources',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.book, color: Color(0xFF4CAF50)),
            title: const Text('User Guide'),
            subtitle: const Text('Complete app tutorial'),
            onTap: () => _launchUrl('https://lets-talk.app/guide'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Color(0xFF4CAF50)),
            title: const Text('Privacy Policy'),
            subtitle: const Text('How we protect your data'),
            onTap: () => _launchUrl('https://lets-talk.app/privacy'),
          ),
          ListTile(
            leading: const Icon(Icons.description, color: Color(0xFF4CAF50)),
            title: const Text('Terms of Service'),
            subtitle: const Text('App usage terms'),
            onTap: () => _launchUrl('https://lets-talk.app/terms'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
