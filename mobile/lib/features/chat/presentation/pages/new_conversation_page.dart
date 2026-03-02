import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/contact_provider.dart';
import '../../../../core/providers/chat_provider.dart';
import '../../../../core/models/contact.dart';
import '../../../../core/models/chat.dart';
import '../widgets/contact_list_item.dart';

class NewConversationPage extends StatefulWidget {
  const NewConversationPage({super.key});

  @override
  State<NewConversationPage> createState() => _NewConversationPageState();
}

class _NewConversationPageState extends State<NewConversationPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final contactProvider = context.read<ContactProvider>();
      await contactProvider.loadContacts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load contacts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _startConversation(Contact contact) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final chatProvider = context.read<ChatProvider>();
      
      // Create a new chat with the selected contact
      final result = await chatProvider.createChat(
        'direct',
        [contact.userId],
      );

      if (result.success && result.data != null) {
        if (mounted) {
          // Navigate to the chat conversation
          Navigator.pushReplacementNamed(
            context,
            '/chat-conversation',
            arguments: {'chat': result.data!},
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Failed to start conversation'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting conversation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    final contactProvider = context.read<ContactProvider>();
    contactProvider.searchContacts(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Conversation'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadContacts,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                ),
              ),
            ),
          ),
          
          // Contact List
          Expanded(
            child: Consumer<ContactProvider>(
              builder: (context, contactProvider, child) {
                if (_isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF4CAF50),
                    ),
                  );
                }

                if (contactProvider.error.isNotEmpty) {
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
                          'Error loading contacts',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          contactProvider.error,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadContacts,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (!contactProvider.hasPermission) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.contacts_outlined,
                          size: 64,
                          color: Color(0xFF4CAF50),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Contact Permission Required',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'We need access to your contacts to show you who uses Let\'s Talk.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            final granted = await contactProvider.requestPermission();
                            if (granted) {
                              _loadContacts();
                            }
                          },
                          child: const Text('Grant Permission'),
                        ),
                      ],
                    ),
                  );
                }

                final contacts = contactProvider.filteredContacts;
                
                if (contacts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Color(0xFF4CAF50),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          contactProvider.searchQuery.isNotEmpty
                              ? 'No contacts found'
                              : 'No Let\'s Talk users found',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          contactProvider.searchQuery.isNotEmpty
                              ? 'Try adjusting your search terms'
                              : 'Your contacts who use Let\'s Talk will appear here',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        if (contactProvider.searchQuery.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                            child: const Text('Clear Search'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadContacts,
                  color: const Color(0xFF4CAF50),
                  child: ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return ContactListItem(
                        contact: contact,
                        onTap: () => _startConversation(contact),
                        onFavoriteToggle: () {
                          if (contact.isFavorite) {
                            contactProvider.removeFromFavorites(contact.id);
                          } else {
                            contactProvider.addToFavorites(contact.id);
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
