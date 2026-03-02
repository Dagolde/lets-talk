import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/contact_provider.dart';
import '../../../../core/models/contact.dart';
import '../widgets/contact_list_item.dart';
import '../widgets/contact_permission_dialog.dart';
import 'contact_invitation_page.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactProvider>().initialize();
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
        title: const Text('Contacts'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContactInvitationPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ContactProvider>().refreshContacts();
            },
          ),
        ],
      ),
      body: Consumer<ContactProvider>(
        builder: (context, contactProvider, child) {
          if (contactProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            );
          }

          if (!contactProvider.hasPermission) {
            return _buildPermissionRequest();
          }

          if (contactProvider.error.isNotEmpty) {
            return _buildErrorWidget(contactProvider);
          }

          return Column(
            children: [
              _buildSearchBar(contactProvider),
              Expanded(
                child: _buildContactsList(contactProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPermissionRequest() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.contacts,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Contact Permission Required',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We need access to your contacts to find friends who use Let\'s Talk.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<ContactProvider>().requestPermission();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(ContactProvider contactProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Error Loading Contacts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            contactProvider.error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              contactProvider.clearError();
              contactProvider.refreshContacts();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ContactProvider contactProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                    contactProvider.clearSearch();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (value) {
          contactProvider.searchContacts(value);
        },
      ),
    );
  }

  Widget _buildContactsList(ContactProvider contactProvider) {
    if (contactProvider.filteredContacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              contactProvider.searchQuery.isNotEmpty
                  ? 'No contacts found for "${contactProvider.searchQuery}"'
                  : 'No contacts found',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Contacts who use Let\'s Talk will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => contactProvider.refreshContacts(),
      child: ListView.builder(
        itemCount: contactProvider.filteredContacts.length,
        itemBuilder: (context, index) {
          final contact = contactProvider.filteredContacts[index];
          return ContactListItem(
            contact: contact,
            onTap: () => _onContactTap(contact),
            onFavoriteToggle: () => _onFavoriteToggle(contact),
          );
        },
      ),
    );
  }

  void _onContactTap(Contact contact) {
    // Navigate to chat or contact details
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {
        'contact': contact,
      },
    );
  }

  void _onFavoriteToggle(Contact contact) {
    if (contact.isFavorite) {
      context.read<ContactProvider>().removeFromFavorites(contact.id);
    } else {
      context.read<ContactProvider>().addToFavorites(contact.id);
    }
  }
}
