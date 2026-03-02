import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../services/storage_service.dart';

class WebSocketService {
  static WebSocketChannel? _channel;
  static bool _isConnected = false;
  static String? _userId;
  static Function(Map<String, dynamic>)? _onMessageReceived;
  static Function()? _onConnected;
  static Function()? _onDisconnected;

  static bool get isConnected => _isConnected;

  static Future<void> initialize() async {
    // Get user token for authentication
    final token = await StorageService.getToken();
    if (token != null) {
      await connect(token);
    }
  }

  static Future<void> connect(String token) async {
    try {
      final uri = Uri.parse('ws://localhost:6001/app/lets-talk?token=$token');
      _channel = WebSocketChannel.connect(uri);
      
      _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onDone: () {
          _handleDisconnection();
        },
        onError: (error) {
          print('WebSocket error: $error');
          _handleDisconnection();
        },
      );

      _isConnected = true;
      _onConnected?.call();
      print('WebSocket connected');
    } catch (e) {
      print('Failed to connect to WebSocket: $e');
      _isConnected = false;
    }
  }

  static void disconnect() {
    _channel?.sink.close(status.goingAway);
    _channel = null;
    _isConnected = false;
    _onDisconnected?.call();
  }

  static void _handleMessage(dynamic message) {
    try {
      if (message is String) {
        final data = json.decode(message);
        _onMessageReceived?.call(data);
      } else if (message is Map<String, dynamic>) {
        _onMessageReceived?.call(message);
      }
    } catch (e) {
      print('Error parsing WebSocket message: $e');
    }
  }

  static void _handleDisconnection() {
    _isConnected = false;
    _onDisconnected?.call();
    print('WebSocket disconnected');
  }

  static void sendMessage(Map<String, dynamic> data) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(json.encode(data));
    } else {
      print('WebSocket is not connected');
    }
  }

  static void sendTyping(String conversationId, bool isTyping) {
    sendMessage({
      'event': 'typing',
      'conversation_id': conversationId,
      'is_typing': isTyping,
    });
  }

  static void sendMessageSeen(String conversationId, String messageId) {
    sendMessage({
      'event': 'message_seen',
      'conversation_id': conversationId,
      'message_id': messageId,
    });
  }

  static void joinConversation(String conversationId) {
    sendMessage({
      'event': 'join_conversation',
      'conversation_id': conversationId,
    });
  }

  static void leaveConversation(String conversationId) {
    sendMessage({
      'event': 'leave_conversation',
      'conversation_id': conversationId,
    });
  }

  static void setMessageHandler(Function(Map<String, dynamic>) handler) {
    _onMessageReceived = handler;
  }

  static void setConnectionHandlers({
    Function()? onConnected,
    Function()? onDisconnected,
  }) {
    _onConnected = onConnected;
    _onDisconnected = onDisconnected;
  }

  static void subscribeToUser(String userId) {
    sendMessage({
      'event': 'subscribe_to_user',
      'user_id': userId,
    });
  }

  static void unsubscribeFromUser(String userId) {
    sendMessage({
      'event': 'unsubscribe_from_user',
      'user_id': userId,
    });
  }
}
