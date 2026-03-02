import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../../../core/providers/contact_invitation_provider.dart';

class ContactInvitationPage extends StatefulWidget {
  const ContactInvitationPage({super.key});

  @override
  State<ContactInvitationPage> createState() => _ContactInvitationPageState();
}

class _ContactInvitationPageState extends State<ContactInvitationPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactInvitationProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite Friends'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          Consumer<ContactInvitationProvider>(
            builder: (context, provider, child) {
              if (provider.selectedCount > 0) {
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    if (value == 'sms') {
                      await _inviteViaSMS(provider);
                    } else if (value == 'whatsapp') {
                      await _inviteViaWhatsApp(provider);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'sms',
                      child: Row(
                        children: [
                          Icon(Icons.sms, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Invite via SMS'),
                        ],
                      ),
                    ),
                                         const PopupMenuItem(
                       value: 'whatsapp',
                       child: Row(
                         children: [
                           Icon(Icons.message, color: Colors.green),
                           SizedBox(width: 8),
                           Text('Invite via WhatsApp'),
                         ],
                       ),
                     ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<ContactInvitationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            );
          }

          if (!provider.hasPermission) {
            return _buildPermissionRequest(provider);
          }

          if (provider.error.isNotEmpty) {
            return _buildErrorState(provider);
          }

          if (provider.nonLetsTalkContacts.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              _buildSearchBar(provider),
              _buildSelectionBar(provider),
              Expanded(
                child: _buildContactsList(provider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<ContactInvitationProvider>(
        builder: (context, provider, child) {
          if (provider.selectedCount > 0) {
            return FloatingActionButton.extended(
              onPressed: () => _showInvitationOptions(context, provider),
              backgroundColor: const Color(0xFF4CAF50),
              icon: const Icon(Icons.send, color: Colors.white),
              label: Text(
                'Invite ${provider.selectedCount}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPermissionRequest(ContactInvitationProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.contacts,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'Contact Permission Required',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'To invite your friends to Let\'s Talk, we need access to your contacts.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => provider.requestPermission(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Grant Permission',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ContactInvitationProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error: ${provider.error}',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              provider.clearError();
              provider.initialize();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          const Text(
            'All Your Contacts Are Already Using Let\'s Talk!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Great job! It looks like all your contacts are already part of the Let\'s Talk community.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ContactInvitationProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search contacts...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    provider.clearSearch();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: provider.searchContacts,
      ),
    );
  }

  Widget _buildSelectionBar(ContactInvitationProvider provider) {
    if (provider.selectedCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF4CAF50).withOpacity(0.1),
      child: Row(
        children: [
          Text(
            '${provider.selectedCount} selected',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: provider.selectAllContacts,
            child: const Text('Select All'),
          ),
          TextButton(
            onPressed: provider.deselectAllContacts,
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList(ContactInvitationProvider provider) {
    final groupedContacts = provider.getContactsGroupedByLetter();
    final sortedKeys = groupedContacts.keys.toList()..sort();

    return ListView.builder(
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final letter = sortedKeys[index];
        final contacts = groupedContacts[letter]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[100],
              child: Text(
                letter,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            ...contacts.map((contact) => _buildContactTile(contact, provider)),
          ],
        );
      },
    );
  }

  Widget _buildContactTile(Contact contact, ContactInvitationProvider provider) {
    final isSelected = provider.isContactSelected(contact);
    final phoneNumber = contact.phones.isNotEmpty ? contact.phones.first.number : '';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF4CAF50),
        child: Text(
          contact.displayName.isNotEmpty 
              ? contact.displayName[0].toUpperCase() 
              : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        contact.displayName,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: phoneNumber.isNotEmpty ? Text(phoneNumber) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected)
            const Icon(
              Icons.check_circle,
              color: Color(0xFF4CAF50),
            ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'sms') {
                await _inviteSingleContact(contact, 'sms', provider);
              } else if (value == 'whatsapp') {
                await _inviteSingleContact(contact, 'whatsapp', provider);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sms',
                child: Row(
                  children: [
                    Icon(Icons.sms, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Send SMS'),
                  ],
                ),
              ),
                             const PopupMenuItem(
                 value: 'whatsapp',
                 child: Row(
                   children: [
                     Icon(Icons.message, color: Colors.green),
                     SizedBox(width: 8),
                     Text('Send WhatsApp'),
                   ],
                 ),
               ),
            ],
          ),
        ],
      ),
      onTap: () {
        if (isSelected) {
          provider.deselectContact(contact);
        } else {
          provider.selectContact(contact);
        }
      },
    );
  }

  void _showInvitationOptions(BuildContext context, ContactInvitationProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Invite ${provider.selectedCount} contacts',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _inviteViaSMS(provider);
                    },
                    icon: const Icon(Icons.sms, color: Colors.white),
                    label: const Text('SMS', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _inviteViaWhatsApp(provider);
                    },
                                         icon: const Icon(Icons.message, color: Colors.white),
                    label: const Text('WhatsApp', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _inviteViaSMS(ContactInvitationProvider provider) async {
    final results = await provider.inviteSelectedContactsViaSMS();
    _showInvitationResults(results, 'SMS');
  }

  Future<void> _inviteViaWhatsApp(ContactInvitationProvider provider) async {
    final results = await provider.inviteSelectedContactsViaWhatsApp();
    _showInvitationResults(results, 'WhatsApp');
  }

  Future<void> _inviteSingleContact(Contact contact, String method, ContactInvitationProvider provider) async {
    final success = await provider.inviteSingleContact(contact, method);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invitation sent to ${contact.displayName} via $method'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send invitation to ${contact.displayName}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showInvitationResults(List<String> results, String method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$method Invitation Results'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              final isSuccess = result.startsWith('✅');
              
              return ListTile(
                leading: Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
                title: Text(
                  result.substring(2), // Remove the emoji
                  style: TextStyle(
                    color: isSuccess ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
