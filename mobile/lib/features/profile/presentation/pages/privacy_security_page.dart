import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/api_service.dart';

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  bool _isLoading = false;
  bool _readReceipts = true;
  bool _typingIndicators = true;
  bool _profilePhotoVisible = true;
  bool _lastSeenVisible = true;
  bool _aboutVisible = true;
  bool _groupsVisible = true;
  bool _twoFactorEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  Future<void> _loadPrivacySettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService().getProfile();
      if (response.success && response.data != null) {
        final user = response.data!;
        setState(() {
          _readReceipts = user.readReceipts ?? true;
          _typingIndicators = user.typingIndicators ?? true;
          _profilePhotoVisible = user.profilePhotoVisible ?? true;
          _lastSeenVisible = user.lastSeenVisible ?? true;
          _aboutVisible = user.aboutVisible ?? true;
          _groupsVisible = user.groupsVisible ?? true;
          _twoFactorEnabled = user.twoFactorEnabled ?? false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading privacy settings: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePrivacySettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = {
        'read_receipts': _readReceipts,
        'typing_indicators': _typingIndicators,
        'profile_photo_visible': _profilePhotoVisible,
        'last_seen_visible': _lastSeenVisible,
        'about_visible': _aboutVisible,
        'groups_visible': _groupsVisible,
      };

      final response = await ApiService().updateProfile(userData);
      
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Privacy settings updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Failed to update privacy settings')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating privacy settings: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleTwoFactor() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService().toggleTwoFactor(!_twoFactorEnabled);
      
      if (response['success']) {
        setState(() {
          _twoFactorEnabled = !_twoFactorEnabled;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_twoFactorEnabled 
              ? 'Two-factor authentication enabled!' 
              : 'Two-factor authentication disabled!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to toggle two-factor authentication')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error toggling two-factor authentication: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _updatePrivacySettings,
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Privacy Settings Section
                  _buildPrivacySection(),
                  const SizedBox(height: 16),
                  
                  // Security Settings Section
                  _buildSecuritySection(),
                  const SizedBox(height: 16),
                  
                  // Account Security Section
                  _buildAccountSecuritySection(),
                ],
              ),
            ),
    );
  }

  Widget _buildPrivacySection() {
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
              'Privacy Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Read Receipts'),
            subtitle: const Text('Show when messages are read'),
            value: _readReceipts,
            onChanged: (value) => setState(() => _readReceipts = value),
            activeColor: const Color(0xFF4CAF50),
          ),
          SwitchListTile(
            title: const Text('Typing Indicators'),
            subtitle: const Text('Show when someone is typing'),
            value: _typingIndicators,
            onChanged: (value) => setState(() => _typingIndicators = value),
            activeColor: const Color(0xFF4CAF50),
          ),
          SwitchListTile(
            title: const Text('Profile Photo Visible'),
            subtitle: const Text('Show your profile photo to others'),
            value: _profilePhotoVisible,
            onChanged: (value) => setState(() => _profilePhotoVisible = value),
            activeColor: const Color(0xFF4CAF50),
          ),
          SwitchListTile(
            title: const Text('Last Seen Visible'),
            subtitle: const Text('Show when you were last online'),
            value: _lastSeenVisible,
            onChanged: (value) => setState(() => _lastSeenVisible = value),
            activeColor: const Color(0xFF4CAF50),
          ),
          SwitchListTile(
            title: const Text('About Visible'),
            subtitle: const Text('Show your bio to others'),
            value: _aboutVisible,
            onChanged: (value) => setState(() => _aboutVisible = value),
            activeColor: const Color(0xFF4CAF50),
          ),
          SwitchListTile(
            title: const Text('Groups Visible'),
            subtitle: const Text('Show your groups to others'),
            value: _groupsVisible,
            onChanged: (value) => setState(() => _groupsVisible = value),
            activeColor: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
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
              'Security Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lock, color: Color(0xFF4CAF50)),
            title: const Text('Change Password'),
            subtitle: const Text('Update your account password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to change password page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Change password coming soon!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.devices, color: Color(0xFF4CAF50)),
            title: const Text('Active Sessions'),
            subtitle: const Text('Manage your active sessions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to active sessions page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Active sessions coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSecuritySection() {
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
              'Account Security',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Two-Factor Authentication'),
            subtitle: const Text('Add an extra layer of security'),
            value: _twoFactorEnabled,
            onChanged: (value) => _toggleTwoFactor(),
            activeColor: const Color(0xFF4CAF50),
          ),
          ListTile(
            leading: const Icon(Icons.security, color: Color(0xFF4CAF50)),
            title: const Text('Login Activity'),
            subtitle: const Text('Review your recent login activity'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to login activity page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Login activity coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }
}
