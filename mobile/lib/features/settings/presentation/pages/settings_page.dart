import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = false;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'USD';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAccountSection(),
            const SizedBox(height: 16),
            _buildPreferencesSection(),
            const SizedBox(height: 16),
            _buildSecuritySection(),
            const SizedBox(height: 16),
            _buildPaymentSection(),
            const SizedBox(height: 16),
            _buildPrivacySection(),
            const SizedBox(height: 16),
            _buildSupportSection(),
            const SizedBox(height: 16),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    final user = context.read<AuthProvider>().user;
    
    return _buildSection(
      title: 'Account',
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF4CAF50),
            backgroundImage: user?.avatar != null
                ? NetworkImage(user!.avatar!)
                : null,
            child: user?.avatar == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          title: Text(user?.name ?? 'Unknown'),
          subtitle: Text(user?.email ?? ''),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _editProfile();
          },
        ),
        _buildSettingTile(
          icon: Icons.notifications,
          title: 'Notifications',
          subtitle: 'Manage notification preferences',
          onTap: () {
            _showNotificationSettings();
          },
        ),
        _buildSettingTile(
          icon: Icons.language,
          title: 'Language',
          subtitle: _selectedLanguage,
          onTap: () {
            _showLanguageSettings();
          },
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return _buildSection(
      title: 'Preferences',
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.dark_mode, color: Color(0xFF4CAF50)),
          title: const Text('Dark Mode'),
          subtitle: const Text('Use dark theme'),
          value: _darkModeEnabled,
          onChanged: (value) {
            setState(() {
              _darkModeEnabled = value;
            });
            _toggleDarkMode(value);
          },
        ),
        SwitchListTile(
          secondary: const Icon(Icons.notifications, color: Color(0xFF4CAF50)),
          title: const Text('Push Notifications'),
          subtitle: const Text('Receive push notifications'),
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
            _toggleNotifications(value);
          },
        ),
        _buildSettingTile(
          icon: Icons.currency_exchange,
          title: 'Currency',
          subtitle: _selectedCurrency,
          onTap: () {
            _showCurrencySettings();
          },
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return _buildSection(
      title: 'Security',
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.fingerprint, color: Color(0xFF4CAF50)),
          title: const Text('Biometric Login'),
          subtitle: const Text('Use fingerprint or face ID'),
          value: _biometricEnabled,
          onChanged: (value) {
            setState(() {
              _biometricEnabled = value;
            });
            _toggleBiometric(value);
          },
        ),
        _buildSettingTile(
          icon: Icons.lock,
          title: 'Change Password',
          subtitle: 'Update your password',
          onTap: () {
            _changePassword();
          },
        ),
        _buildSettingTile(
          icon: Icons.security,
          title: 'Two-Factor Authentication',
          subtitle: 'Add extra security',
          onTap: () {
            _setupTwoFactor();
          },
        ),
        _buildSettingTile(
          icon: Icons.devices,
          title: 'Active Sessions',
          subtitle: 'Manage logged in devices',
          onTap: () {
            _showActiveSessions();
          },
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return _buildSection(
      title: 'Payment',
      children: [
        _buildSettingTile(
          icon: Icons.credit_card,
          title: 'Payment Methods',
          subtitle: 'Manage your cards and accounts',
          onTap: () {
            _managePaymentMethods();
          },
        ),
        _buildSettingTile(
          icon: Icons.account_balance_wallet,
          title: 'Wallet',
          subtitle: 'View your balance and transactions',
          onTap: () {
            _openWallet();
          },
        ),
        _buildSettingTile(
          icon: Icons.receipt_long,
          title: 'Transaction History',
          subtitle: 'View all your transactions',
          onTap: () {
            _viewTransactionHistory();
          },
        ),
        _buildSettingTile(
          icon: Icons.qr_code,
          title: 'QR Code Settings',
          subtitle: 'Configure QR code preferences',
          onTap: () {
            _configureQRSettings();
          },
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return _buildSection(
      title: 'Privacy',
      children: [
        _buildSettingTile(
          icon: Icons.visibility,
          title: 'Profile Visibility',
          subtitle: 'Control who can see your profile',
          onTap: () {
            _manageProfileVisibility();
          },
        ),
        _buildSettingTile(
          icon: Icons.location_on,
          title: 'Location Services',
          subtitle: 'Manage location permissions',
          onTap: () {
            _manageLocationServices();
          },
        ),
        _buildSettingTile(
          icon: Icons.data_usage,
          title: 'Data Usage',
          subtitle: 'Control data collection',
          onTap: () {
            _manageDataUsage();
          },
        ),
        _buildSettingTile(
          icon: Icons.delete_forever,
          title: 'Delete Account',
          subtitle: 'Permanently delete your account',
          onTap: () {
            _deleteAccount();
          },
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _buildSection(
      title: 'Support',
      children: [
        _buildSettingTile(
          icon: Icons.help_outline,
          title: 'Help Center',
          subtitle: 'Get help and support',
          onTap: () {
            _openHelpCenter();
          },
        ),
        _buildSettingTile(
          icon: Icons.contact_support,
          title: 'Contact Support',
          subtitle: 'Get in touch with our team',
          onTap: () {
            _contactSupport();
          },
        ),
        _buildSettingTile(
          icon: Icons.bug_report,
          title: 'Report a Bug',
          subtitle: 'Help us improve the app',
          onTap: () {
            _reportBug();
          },
        ),
        _buildSettingTile(
          icon: Icons.feedback,
          title: 'Send Feedback',
          subtitle: 'Share your thoughts',
          onTap: () {
            _sendFeedback();
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSection(
      title: 'About',
      children: [
        _buildSettingTile(
          icon: Icons.info_outline,
          title: 'App Version',
          subtitle: '1.0.0 (Build 1)',
          onTap: () {
            _showAppInfo();
          },
        ),
        _buildSettingTile(
          icon: Icons.description,
          title: 'Terms of Service',
          subtitle: 'Read our terms and conditions',
          onTap: () {
            _showTermsOfService();
          },
        ),
        _buildSettingTile(
          icon: Icons.privacy_tip,
          title: 'Privacy Policy',
          subtitle: 'Read our privacy policy',
          onTap: () {
            _showPrivacyPolicy();
          },
        ),
        _buildSettingTile(
          icon: Icons.open_in_new,
          title: 'Open Source Licenses',
          subtitle: 'View third-party licenses',
          onTap: () {
            _showOpenSourceLicenses();
          },
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4CAF50)),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  // Settings actions
  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit profile coming soon!')),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Chat Messages'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Payment Notifications'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Product Search Results'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification settings saved')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Spanish'),
              value: 'Spanish',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('French'),
              value: 'French',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Language changed')),
              );
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showCurrencySettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('USD (\$)'),
              value: 'USD',
              groupValue: _selectedCurrency,
              onChanged: (value) {
                setState(() {
                  _selectedCurrency = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('EUR (€)'),
              value: 'EUR',
              groupValue: _selectedCurrency,
              onChanged: (value) {
                setState(() {
                  _selectedCurrency = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('GBP (£)'),
              value: 'GBP',
              groupValue: _selectedCurrency,
              onChanged: (value) {
                setState(() {
                  _selectedCurrency = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Currency changed')),
              );
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _toggleDarkMode(bool value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dark mode ${value ? 'enabled' : 'disabled'}')),
    );
  }

  void _toggleNotifications(bool value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notifications ${value ? 'enabled' : 'disabled'}')),
    );
  }

  void _toggleBiometric(bool value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Biometric login ${value ? 'enabled' : 'disabled'}')),
    );
  }

  void _changePassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Change password coming soon!')),
    );
  }

  void _setupTwoFactor() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Two-factor authentication coming soon!')),
    );
  }

  void _showActiveSessions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Active sessions coming soon!')),
    );
  }

  void _managePaymentMethods() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment methods coming soon!')),
    );
  }

  void _openWallet() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wallet coming soon!')),
    );
  }

  void _viewTransactionHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction history coming soon!')),
    );
  }

  void _configureQRSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR settings coming soon!')),
    );
  }

  void _manageProfileVisibility() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile visibility coming soon!')),
    );
  }

  void _manageLocationServices() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location services coming soon!')),
    );
  }

  void _manageDataUsage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data usage coming soon!')),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to permanently delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion coming soon!')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openHelpCenter() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help center coming soon!')),
    );
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact support coming soon!')),
    );
  }

  void _reportBug() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bug reporting coming soon!')),
    );
  }

  void _sendFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feedback coming soon!')),
    );
  }

  void _showAppInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App Information'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('App Name: Let\'s Talk'),
            SizedBox(height: 8),
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Build: 1'),
            SizedBox(height: 8),
            Text('Platform: Flutter'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms of service coming soon!')),
    );
  }

  void _showPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy policy coming soon!')),
    );
  }

  void _showOpenSourceLicenses() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Open source licenses coming soon!')),
    );
  }
}
