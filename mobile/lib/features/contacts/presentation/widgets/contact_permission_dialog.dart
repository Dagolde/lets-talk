import 'package:flutter/material.dart';

class ContactPermissionDialog extends StatelessWidget {
  final VoidCallback? onGrantPermission;
  final VoidCallback? onDenyPermission;

  const ContactPermissionDialog({
    super.key,
    this.onGrantPermission,
    this.onDenyPermission,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(
            Icons.contacts,
            color: Color(0xFF4CAF50),
          ),
          SizedBox(width: 8),
          Text('Contact Permission'),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Let\'s Talk needs access to your contacts to:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text('• Find friends who use Let\'s Talk'),
          Text('• Show contact names in chats'),
          Text('• Enable quick contact selection'),
          SizedBox(height: 12),
          Text(
            'Your contacts are only used locally and are not shared with our servers.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDenyPermission?.call();
          },
          child: const Text('Not Now'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onGrantPermission?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
          ),
          child: const Text('Grant Permission'),
        ),
      ],
    );
  }
}
