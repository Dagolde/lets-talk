import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../models/api_response.dart';
import '../services/api_service.dart';

class ChatProvider extends ChangeNotifier {
  List<Chat> _chats = [];
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;
  User? _currentUser;

  List<Chat> get chats => _chats;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get currentUser => _currentUser;

  Future<void> loadChats() async {
    _setLoading(true);
    try {
      final response = await ApiService().getChats();
      if (response.success && response.data != null) {
        _chats = response.data!;
        _error = null;
      } else {
        _error = response.message ?? 'Failed to load chats';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMessages(int chatId) async {
    _setLoading(true);
    try {
      final response = await ApiService().getMessages(chatId);
      if (response.success && response.data != null) {
        _messages = response.data!;
        _error = null;
      } else {
        _error = response.message ?? 'Failed to load messages';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendMessage(int chatId, String content, String type, {File? file}) async {
    try {
      final response = await ApiService().sendMessage(chatId, content, type, file: file);
      if (response.success && response.data != null) {
        // Add the new message to the list
        _messages.add(response.data!);
        notifyListeners();
      } else {
        _error = response.message ?? 'Failed to send message';
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<ApiResponse<Chat>> createChat(String type, List<int> participantIds, {String? name}) async {
    _setLoading(true);
    try {
      final response = await ApiService().createChat(type, participantIds, name: name);
      if (response.success && response.data != null) {
        _chats.add(response.data!);
        _error = null;
      } else {
        _error = response.message ?? 'Failed to create chat';
      }
      return response;
    } catch (e) {
      _error = e.toString();
      return ApiResponse.error(_error!);
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
}
