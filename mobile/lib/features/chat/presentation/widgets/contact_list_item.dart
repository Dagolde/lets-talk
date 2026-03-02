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
            const Icon(
              Icons.chat_bubble_outline,
              color: Color(0xFF4CAF50),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
