import 'package:flutter/material.dart';
import '../../../../core/models/contact.dart';

class ContactListItem extends StatelessWidget {
  final Contact contact;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const ContactListItem({
    super.key,
    required this.contact,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFF4CAF50),
          backgroundImage: contact.avatar != null
              ? NetworkImage(contact.avatar!)
              : null,
          child: contact.avatar == null
              ? const Icon(Icons.person, color: Colors.white)
              : null,
        ),
        title: Text(
          contact.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (contact.email != null)
              Text(
                contact.email!,
                style: const TextStyle(color: Colors.grey),
              ),
            Text(
              contact.phone,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onFavoriteToggle != null)
              IconButton(
                icon: Icon(
                  contact.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: contact.isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: onFavoriteToggle,
              ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                _handleContactAction(context, value);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'chat',
                  child: Row(
                    children: [
                      Icon(Icons.chat, color: Color(0xFF4CAF50)),
                      SizedBox(width: 8),
                      Text('Start Chat'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'call',
                  child: Row(
                    children: [
                      Icon(Icons.call, color: Color(0xFF4CAF50)),
                      SizedBox(width: 8),
                      Text('Call'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'video_call',
                  child: Row(
                    children: [
                      Icon(Icons.videocam, color: Color(0xFF4CAF50)),
                      SizedBox(width: 8),
                      Text('Video Call'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'send_money',
                  child: Row(
                    children: [
                      Icon(Icons.send, color: Color(0xFF4CAF50)),
                      SizedBox(width: 8),
                      Text('Send Money'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'share_contact',
                  child: Row(
                    children: [
                      Icon(Icons.share, color: Color(0xFF4CAF50)),
                      SizedBox(width: 8),
                      Text('Share Contact'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  void _handleContactAction(BuildContext context, String action) {
    switch (action) {
      case 'chat':
        Navigator.pushNamed(
          context,
          '/chat',
          arguments: {'contact': contact},
        );
        break;
      case 'call':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Calling ${contact.name}...')),
        );
        break;
      case 'video_call':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Starting video call with ${contact.name}...')),
        );
        break;
      case 'send_money':
        Navigator.pushNamed(
          context,
          '/send-money',
          arguments: {'contact': contact},
        );
        break;
      case 'share_contact':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sharing ${contact.name}\'s contact...')),
        );
        break;
    }
  }
}
