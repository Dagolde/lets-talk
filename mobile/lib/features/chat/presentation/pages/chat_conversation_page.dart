import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/chat_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/websocket_service.dart';
import '../../../../core/models/chat.dart';
import '../../../../core/models/message.dart';
import 'dart:convert';

class ChatConversationPage extends StatefulWidget {
  final Chat chat;

  const ChatConversationPage({
    super.key,
    required this.chat,
  });

  @override
  State<ChatConversationPage> createState() => _ChatConversationPageState();
}

class _ChatConversationPageState extends State<ChatConversationPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _setupWebSocket();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    WebSocketService.leaveConversation(widget.chat.id.toString());
    super.dispose();
  }

  void _loadMessages() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadMessages(widget.chat.id);
    });
  }

  void _setupWebSocket() {
    WebSocketService.joinConversation(widget.chat.id.toString());
    WebSocketService.setMessageHandler(_handleWebSocketMessage);
  }

  void _handleWebSocketMessage(Map<String, dynamic> data) {
    if (data['event'] == 'new_message' && 
        data['conversation_id'].toString() == widget.chat.id.toString()) {
      _loadMessages();
    } else if (data['event'] == 'typing' && 
               data['conversation_id'].toString() == widget.chat.id.toString()) {
      setState(() {
        _isTyping = data['is_typing'] ?? false;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final chatProvider = context.read<ChatProvider>();
    final message = _messageController.text.trim();
    _messageController.clear();

    try {
      await chatProvider.sendMessage(
        widget.chat.id,
        message,
        'text',
      );
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: ${e.toString()}')),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onTypingChanged(bool isTyping) {
    WebSocketService.sendTyping(widget.chat.id.toString(), isTyping);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().user;
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF4CAF50),
              backgroundImage: widget.chat.displayAvatar.isNotEmpty
                  ? NetworkImage(widget.chat.displayAvatar)
                  : null,
              child: widget.chat.displayAvatar.isEmpty
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chat.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_isTyping)
                    const Text(
                      'typing...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showConversationOptions(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                if (chatProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                    ),
                  );
                }

                if (chatProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${chatProvider.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            chatProvider.clearError();
                            _loadMessages();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (chatProvider.messages.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start the conversation!',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.messages[index];
                    final isOwnMessage = message.senderId == currentUser?.id;

                    return _buildMessageBubble(message, isOwnMessage);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isOwnMessage) {
    final currentUser = context.read<AuthProvider>().user;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isOwnMessage 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (!isOwnMessage) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF4CAF50),
              backgroundImage: message.sender.avatar != null
                  ? NetworkImage(message.sender.avatar!)
                  : null,
              child: message.sender.avatar == null
                  ? const Icon(Icons.person, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isOwnMessage 
                    ? const Color(0xFF4CAF50)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isOwnMessage)
                    Text(
                      message.sender.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isOwnMessage ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  if (message.content != null)
                    Text(
                      message.content!,
                      style: TextStyle(
                        color: isOwnMessage ? Colors.white : Colors.black87,
                      ),
                    ),
                  if (message.filePath != null)
                    _buildMediaContent(message),
                  const SizedBox(height: 4),
                  Text(
                    _formatMessageTime(message.createdAt.toIso8601String()),
                    style: TextStyle(
                      fontSize: 10,
                      color: isOwnMessage ? Colors.white70 : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isOwnMessage) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF4CAF50),
              backgroundImage: currentUser?.avatar != null
                  ? NetworkImage(currentUser!.avatar!)
                  : null,
              child: currentUser?.avatar == null
                  ? const Icon(Icons.person, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMediaContent(Message message) {
    final mediaType = message.type;
    final mediaUrl = message.filePath;

    switch (mediaType) {
      case 'image':
        return Container(
          margin: const EdgeInsets.only(top: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              mediaUrl!,
              width: 200,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 150,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                );
              },
            ),
          ),
        );
      case 'video':
        return Container(
          margin: const EdgeInsets.only(top: 8),
          width: 200,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.play_circle_outline, 
                        size: 50, color: Colors.white),
              Positioned(
                bottom: 8,
                right: 8,
                child: Text(
                  '0:00', // TODO: Add duration to Message model
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      case 'audio':
        return Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.play_arrow, color: Color(0xFF4CAF50)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Audio Message',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '0:00', // TODO: Add duration to Message model
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file, color: Color(0xFF4CAF50)),
            onPressed: () {
              _showAttachmentOptions(context);
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Color(0xFFF5F5F5),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) {
                _onTypingChanged(value.isNotEmpty);
              },
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMessageTime(String? timeString) {
    if (timeString == null) return '';
    
    try {
      final dateTime = DateTime.parse(timeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'now';
      }
    } catch (e) {
      return 'recent';
    }
  }

  void _showConversationOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.qr_code, color: Color(0xFF4CAF50)),
              title: const Text('Share QR Code'),
              onTap: () {
                Navigator.pop(context);
                _showQRCode(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Color(0xFF4CAF50)),
              title: const Text('View Participants'),
              onTap: () {
                Navigator.pop(context);
                _showParticipants(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Color(0xFF4CAF50)),
              title: const Text('Mute Notifications'),
              onTap: () {
                Navigator.pop(context);
                _toggleMuteNotifications();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Conversation'),
              onTap: () {
                Navigator.pop(context);
                _deleteConversation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF4CAF50)),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF4CAF50)),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Color(0xFF4CAF50)),
              title: const Text('Video'),
              onTap: () {
                Navigator.pop(context);
                _recordVideo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.mic, color: Color(0xFF4CAF50)),
              title: const Text('Audio'),
              onTap: () {
                Navigator.pop(context);
                _recordAudio();
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Color(0xFF4CAF50)),
              title: const Text('Location'),
              onTap: () {
                Navigator.pop(context);
                _shareLocation();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showQRCode(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conversation QR Code'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code, size: 100, color: Color(0xFF4CAF50)),
            SizedBox(height: 16),
            Text('Scan this QR code to join the conversation'),
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

  void _showParticipants(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Participants'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Participant list coming soon...'),
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

  void _toggleMuteNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mute notifications coming soon!')),
    );
  }

  void _deleteConversation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: const Text('Are you sure you want to delete this conversation? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Conversation deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _takePhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Camera functionality coming soon!')),
    );
  }

  void _pickImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gallery functionality coming soon!')),
    );
  }

  void _recordVideo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video recording coming soon!')),
    );
  }

  void _recordAudio() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Audio recording coming soon!')),
    );
  }

  void _shareLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location sharing coming soon!')),
    );
  }
}
