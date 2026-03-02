import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../qr/presentation/pages/qr_generator_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../wallet/presentation/pages/wallet_page.dart';
import '../../../profile/presentation/pages/edit_profile_page.dart';
import '../../../profile/presentation/pages/privacy_security_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFF4CAF50),
                        backgroundImage: user.avatar != null
                            ? NetworkImage(user.avatar!)
                            : null,
                        child: user.avatar == null
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.email,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      if (user.phone != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          user.phone!,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Menu Items
                _buildMenuSection(
                  title: 'Account',
                  items: [
                    _buildMenuItem(
                      icon: Icons.edit,
                      title: 'Edit Profile',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfilePage(),
                          ),
                        );
                      },
                    ),
                                                _buildMenuItem(
                              icon: Icons.qr_code,
                              title: 'My QR Code',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const QRGeneratorPage(qrType: 'profile'),
                                  ),
                                );
                              },
                            ),
                    _buildMenuItem(
                      icon: Icons.security,
                      title: 'Privacy & Security',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PrivacySecurityPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                _buildMenuSection(
                  title: 'Payments',
                  items: [
                    _buildMenuItem(
                      icon: Icons.account_balance_wallet,
                      title: 'Wallet',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WalletPage(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.credit_card,
                      title: 'Payment Methods',
                      onTap: () {
                        // TODO: Navigate to payment methods
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Payment methods coming soon!')),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.receipt_long,
                      title: 'Transaction History',
                      onTap: () {
                        // TODO: Navigate to transaction history
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Transaction history coming soon!')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                _buildMenuSection(
                  title: 'Support',
                  items: [
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () {
                        // TODO: Navigate to help
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Help & support coming soon!')),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.info_outline,
                      title: 'About',
                      onTap: () {
                        // TODO: Show about dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('About coming soon!')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await authProvider.logout();
                        // Navigate to login page after successful logout
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/phone-verification',
                            (route) => false,
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Logout failed: ${e.toString()}')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<Widget> items,
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
          ...items,
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF4CAF50),
      ),
      title: Text(title),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
