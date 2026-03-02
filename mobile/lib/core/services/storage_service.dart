import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const String _tokenKey = 'token';
  static const String _userKey = 'user';
  static const String _settingsKey = 'settings';
  static const String _themeKey = 'theme';
  static const String _languageKey = 'language';

  static late Box _box;

  static Future<void> initialize() async {
    _box = await Hive.openBox('lets_talk_storage');
  }

  // Token management
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // User management
  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      try {
        return Map<String, dynamic>.from(jsonDecode(userJson));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<void> removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Settings management
  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings));
  }

  static Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);
    if (settingsJson != null) {
      try {
        return Map<String, dynamic>.from(jsonDecode(settingsJson));
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  // Theme management
  static Future<void> saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }

  static Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'system';
  }

  // Language management
  static Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en';
  }

  // Chat data management
  static Future<void> saveConversations(List<Map<String, dynamic>> conversations) async {
    await _box.put('conversations', conversations);
  }

  static Future<List<Map<String, dynamic>>> getConversations() async {
    final data = _box.get('conversations');
    if (data != null) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  static Future<void> saveMessages(int conversationId, List<Map<String, dynamic>> messages) async {
    await _box.put('messages_$conversationId', messages);
  }

  static Future<List<Map<String, dynamic>>> getMessages(int conversationId) async {
    final data = _box.get('messages_$conversationId');
    if (data != null) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  static Future<void> addMessage(int conversationId, Map<String, dynamic> message) async {
    final messages = await getMessages(conversationId);
    messages.add(message);
    await saveMessages(conversationId, messages);
  }

  // Payment data management
  static Future<void> savePayments(List<Map<String, dynamic>> payments) async {
    await _box.put('payments', payments);
  }

  static Future<List<Map<String, dynamic>>> getPayments() async {
    final data = _box.get('payments');
    if (data != null) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  // Product search history
  static Future<void> saveProductSearches(List<Map<String, dynamic>> searches) async {
    await _box.put('product_searches', searches);
  }

  static Future<List<Map<String, dynamic>>> getProductSearches() async {
    final data = _box.get('product_searches');
    if (data != null) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  // QR codes
  static Future<void> saveQRCodes(List<Map<String, dynamic>> qrCodes) async {
    await _box.put('qr_codes', qrCodes);
  }

  static Future<List<Map<String, dynamic>>> getQRCodes() async {
    final data = _box.get('qr_codes');
    if (data != null) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  // Contacts
  static Future<void> saveContacts(List<Map<String, dynamic>> contacts) async {
    await _box.put('contacts', contacts);
  }

  static Future<List<Map<String, dynamic>>> getContacts() async {
    final data = _box.get('contacts');
    if (data != null) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  // Cache management
  static Future<void> clearCache() async {
    await _box.clear();
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _box.clear();
  }

  // File paths
  static Future<String> getDocumentsPath() async {
    return _box.path ?? '';
  }

  // App data
  static Future<void> saveAppData(String key, dynamic value) async {
    await _box.put(key, value);
  }

  static Future<dynamic> getAppData(String key) async {
    return _box.get(key);
  }

  static Future<void> removeAppData(String key) async {
    await _box.delete(key);
  }

  // Migration helpers
  static Future<void> migrateFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    for (final key in keys) {
      if (key.startsWith('app_')) {
        final value = prefs.get(key);
        if (value != null) {
          await saveAppData(key, value);
        }
      }
    }
  }
}
