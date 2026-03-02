import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactsService {
  static final Dio _dio = Dio();
  static const String _baseUrl = 'http://localhost:8000/api';

  // Initialize contacts service
  static Future<void> initialize() async {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    
    // Add interceptors for authentication
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        print('Contacts Service Error: ${error.message}');
        handler.next(error);
      },
    ));
  }

  // Get user's contacts
  static Future<List<Map<String, dynamic>>> getContacts({
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      if (!await FlutterContacts.requestPermission()) {
        throw Exception('Permission denied');
      }
      
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );
      
      List<Map<String, dynamic>> contactsList = [];
      for (final contact in contacts) {
        contactsList.add({
          'id': contact.id,
          'name': contact.displayName,
          'phones': contact.phones.map((p) => p.number).toList(),
          'emails': contact.emails.map((e) => e.address).toList(),
          'photo': contact.photo,
        });
      }
      
      // Apply search filter if provided
      if (search != null && search.isNotEmpty) {
        contactsList = contactsList.where((contact) =>
          contact['name'].toString().toLowerCase().contains(search.toLowerCase()) ||
          contact['phones'].any((phone) => phone.toString().contains(search))
        ).toList();
      }
      
      // Apply pagination
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      if (startIndex < contactsList.length) {
        contactsList = contactsList.sublist(
          startIndex,
          endIndex > contactsList.length ? contactsList.length : endIndex,
        );
      } else {
        contactsList = [];
      }
      
      return contactsList;
    } catch (e) {
      throw Exception('Failed to get contacts: $e');
    }
  }

  // Get contact details
  static Future<Map<String, dynamic>> getContactDetails(String contactId) async {
    try {
      final response = await _dio.get('/contacts/$contactId');
      return response.data;
    } catch (e) {
      throw Exception('Failed to get contact details: $e');
    }
  }

  // Add new contact
  static Future<Map<String, dynamic>> addContact({
    required String name,
    required String phone,
    String? email,
    String? avatar,
    String? notes,
  }) async {
    try {
      final response = await _dio.post('/contacts', data: {
        'name': name,
        'phone': phone,
        if (email != null) 'email': email,
        if (avatar != null) 'avatar': avatar,
        if (notes != null) 'notes': notes,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to add contact: $e');
    }
  }

  // Update contact
  static Future<Map<String, dynamic>> updateContact({
    required String contactId,
    String? name,
    String? phone,
    String? email,
    String? avatar,
    String? notes,
  }) async {
    try {
      final response = await _dio.put('/contacts/$contactId', data: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (avatar != null) 'avatar': avatar,
        if (notes != null) 'notes': notes,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to update contact: $e');
    }
  }

  // Delete contact
  static Future<void> deleteContact(String contactId) async {
    try {
      await _dio.delete('/contacts/$contactId');
    } catch (e) {
      throw Exception('Failed to delete contact: $e');
    }
  }

  // Search contacts
  static Future<List<Map<String, dynamic>>> searchContacts({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get('/contacts/search', queryParameters: {
        'query': query,
        'page': page,
        'limit': limit,
      });

      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      throw Exception('Failed to search contacts: $e');
    }
  }

  // Import contacts from device
  static Future<List<Map<String, dynamic>>> importDeviceContacts() async {
    try {
      final response = await _dio.post('/contacts/import-device');
      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      throw Exception('Failed to import device contacts: $e');
    }
  }

  // Export contacts
  static Future<String> exportContacts({
    String format = 'json',
    List<String>? contactIds,
  }) async {
    try {
      final response = await _dio.post('/contacts/export', data: {
        'format': format,
        if (contactIds != null) 'contact_ids': contactIds,
      });

      return response.data['download_url'];
    } catch (e) {
      throw Exception('Failed to export contacts: $e');
    }
  }

  // Sync contacts with server
  static Future<Map<String, dynamic>> syncContacts() async {
    try {
      final response = await _dio.post('/contacts/sync');
      return response.data;
    } catch (e) {
      throw Exception('Failed to sync contacts: $e');
    }
  }

  // Get contact suggestions
  static Future<List<Map<String, dynamic>>> getContactSuggestions({
    required String query,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get('/contacts/suggestions', queryParameters: {
        'query': query,
        'limit': limit,
      });

      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get contact suggestions: $e');
    }
  }

  // Add contact to favorites
  static Future<void> addToFavorites(String contactId) async {
    try {
      await _dio.post('/contacts/$contactId/favorite');
    } catch (e) {
      throw Exception('Failed to add contact to favorites: $e');
    }
  }

  // Remove contact from favorites
  static Future<void> removeFromFavorites(String contactId) async {
    try {
      await _dio.delete('/contacts/$contactId/favorite');
    } catch (e) {
      throw Exception('Failed to remove contact from favorites: $e');
    }
  }

  // Get favorite contacts
  static Future<List<Map<String, dynamic>>> getFavoriteContacts() async {
    try {
      final response = await _dio.get('/contacts/favorites');
      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get favorite contacts: $e');
    }
  }

  // Block contact
  static Future<void> blockContact(String contactId) async {
    try {
      await _dio.post('/contacts/$contactId/block');
    } catch (e) {
      throw Exception('Failed to block contact: $e');
    }
  }

  // Unblock contact
  static Future<void> unblockContact(String contactId) async {
    try {
      await _dio.delete('/contacts/$contactId/block');
    } catch (e) {
      throw Exception('Failed to unblock contact: $e');
    }
  }

  // Get blocked contacts
  static Future<List<Map<String, dynamic>>> getBlockedContacts() async {
    try {
      final response = await _dio.get('/contacts/blocked');
      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get blocked contacts: $e');
    }
  }

  // Share contact
  static Future<Map<String, dynamic>> shareContact({
    required String contactId,
    required List<String> recipientIds,
    String? message,
  }) async {
    try {
      final response = await _dio.post('/contacts/$contactId/share', data: {
        'recipient_ids': recipientIds,
        if (message != null) 'message': message,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to share contact: $e');
    }
  }

  // Get contact activity
  static Future<List<Map<String, dynamic>>> getContactActivity({
    required String contactId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get('/contacts/$contactId/activity', queryParameters: {
        'page': page,
        'limit': limit,
      });

      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get contact activity: $e');
    }
  }

  // Merge duplicate contacts
  static Future<Map<String, dynamic>> mergeContacts({
    required List<String> contactIds,
    required String primaryContactId,
  }) async {
    try {
      final response = await _dio.post('/contacts/merge', data: {
        'contact_ids': contactIds,
        'primary_contact_id': primaryContactId,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to merge contacts: $e');
    }
  }

  // Get contact statistics
  static Future<Map<String, dynamic>> getContactStatistics() async {
    try {
      final response = await _dio.get('/contacts/statistics');
      return response.data;
    } catch (e) {
      throw Exception('Failed to get contact statistics: $e');
    }
  }

  // Validate phone number
  static bool isValidPhoneNumber(String phone) {
    // Basic phone number validation
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    return phoneRegex.hasMatch(phone) && phone.length >= 7;
  }

  // Validate email
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Format phone number
  static String formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Basic formatting for common patterns
    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    } else if (digits.length == 11 && digits.startsWith('1')) {
      return '+1 (${digits.substring(1, 4)}) ${digits.substring(4, 7)}-${digits.substring(7)}';
    }
    
    return phone;
  }

  // Get contact initials
  static String getContactInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '';
    
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }
    
    return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'.toUpperCase();
  }

  // Sort contacts by name
  static List<Map<String, dynamic>> sortContactsByName(List<Map<String, dynamic>> contacts) {
    contacts.sort((a, b) {
      final nameA = (a['name'] as String).toLowerCase();
      final nameB = (b['name'] as String).toLowerCase();
      return nameA.compareTo(nameB);
    });
    return contacts;
  }

  // Group contacts by first letter
  static Map<String, List<Map<String, dynamic>>> groupContactsByLetter(List<Map<String, dynamic>> contacts) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    
    for (final contact in contacts) {
      final name = contact['name'] as String;
      final firstLetter = name.substring(0, 1).toUpperCase();
      
      if (!grouped.containsKey(firstLetter)) {
        grouped[firstLetter] = [];
      }
      grouped[firstLetter]!.add(contact);
    }
    
    return grouped;
  }

  // Search contacts locally
  static List<Map<String, dynamic>> searchContactsLocally({
    required List<Map<String, dynamic>> contacts,
    required String query,
  }) {
    final lowercaseQuery = query.toLowerCase();
    
    return contacts.where((contact) {
      final name = (contact['name'] as String).toLowerCase();
      final phone = (contact['phone'] as String).toLowerCase();
      final email = (contact['email'] as String?)?.toLowerCase() ?? '';
      
      return name.contains(lowercaseQuery) ||
             phone.contains(lowercaseQuery) ||
             email.contains(lowercaseQuery);
    }).toList();
  }

  // Get contact avatar URL
  static String? getContactAvatarUrl(Map<String, dynamic> contact) {
    final avatar = contact['avatar'];
    if (avatar == null || avatar.toString().isEmpty) {
      return null;
    }
    
    if (avatar.toString().startsWith('http')) {
      return avatar.toString();
    }
    
    return '$_baseUrl/storage/$avatar';
  }

  // Check if contact is online
  static bool isContactOnline(Map<String, dynamic> contact) {
    final lastSeen = contact['last_seen_at'];
    if (lastSeen == null) return false;
    
    final lastSeenTime = DateTime.parse(lastSeen);
    final now = DateTime.now();
    final difference = now.difference(lastSeenTime);
    
    return difference.inMinutes < 5;
  }

  // Get contact status
  static String getContactStatus(Map<String, dynamic> contact) {
    if (isContactOnline(contact)) {
      return 'online';
    }
    
    final lastSeen = contact['last_seen_at'];
    if (lastSeen == null) {
      return 'unknown';
    }
    
    final lastSeenTime = DateTime.parse(lastSeen);
    final now = DateTime.now();
    final difference = now.difference(lastSeenTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
