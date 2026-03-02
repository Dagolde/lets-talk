import 'dart:io';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../models/contact.dart' as app_contact;

class ContactService {
  static final ContactService _instance = ContactService._internal();
  factory ContactService() => _instance;
  ContactService._internal();

  bool _hasPermission = false;
  List<Contact> _deviceContacts = [];
  List<app_contact.Contact> _appContacts = [];

  bool get hasPermission => _hasPermission;
  List<Contact> get deviceContacts => _deviceContacts;
  List<app_contact.Contact> get appContacts => _appContacts;

  /// Request contact permissions
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.contacts.request();
      _hasPermission = status.isGranted;
      return _hasPermission;
    } else if (Platform.isIOS) {
      final status = await FlutterContacts.requestPermission();
      _hasPermission = status;
      return _hasPermission;
    }
    return false;
  }

  /// Check if contact permission is granted
  Future<bool> checkPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.contacts.status;
      _hasPermission = status.isGranted;
      return _hasPermission;
    } else if (Platform.isIOS) {
      final status = await FlutterContacts.requestPermission();
      _hasPermission = status;
      return _hasPermission;
    }
    return false;
  }

  /// Load all device contacts
  Future<List<Contact>> loadDeviceContacts() async {
    if (!await checkPermission()) {
      throw Exception('Contact permission not granted');
    }

    try {
      _deviceContacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );
      return _deviceContacts;
    } catch (e) {
      throw Exception('Failed to load contacts: $e');
    }
  }

  /// Get contacts that have phone numbers
  List<Contact> getContactsWithPhoneNumbers() {
    return _deviceContacts.where((contact) {
      return contact.phones.isNotEmpty;
    }).toList();
  }

  /// Extract phone numbers from contacts
  List<String> extractPhoneNumbers() {
    final phoneNumbers = <String>[];
    
    for (final contact in _deviceContacts) {
      for (final phone in contact.phones) {
        // Clean phone number (remove spaces, dashes, etc.)
        final cleanNumber = _cleanPhoneNumber(phone.number);
        if (cleanNumber.isNotEmpty) {
          phoneNumbers.add(cleanNumber);
        }
      }
    }
    
    return phoneNumbers;
  }

  /// Clean phone number by removing non-digit characters
  String _cleanPhoneNumber(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
  }

  /// Find contacts that use Let's Talk by checking phone numbers
  Future<List<app_contact.Contact>> findLetsTalkUsers(List<String> phoneNumbers) async {
    // This would typically make an API call to check which phone numbers
    // are registered with Let's Talk. For now, we'll return an empty list
    // and implement the API call later.
    return [];
  }

  /// Sync contacts with Let's Talk users
  Future<List<app_contact.Contact>> syncContacts() async {
    try {
      // Load device contacts
      await loadDeviceContacts();
      
      // Extract phone numbers
      final phoneNumbers = extractPhoneNumbers();
      
      // Find Let's Talk users
      final letsTalkUsers = await findLetsTalkUsers(phoneNumbers);
      
      // Match device contacts with Let's Talk users
      _appContacts = _matchContactsWithUsers(letsTalkUsers);
      
      return _appContacts;
    } catch (e) {
      throw Exception('Failed to sync contacts: $e');
    }
  }

  /// Match device contacts with Let's Talk users
  List<app_contact.Contact> _matchContactsWithUsers(List<app_contact.Contact> letsTalkUsers) {
    final matchedContacts = <app_contact.Contact>[];
    
    for (final deviceContact in _deviceContacts) {
      for (final phone in deviceContact.phones) {
        final cleanNumber = _cleanPhoneNumber(phone.number);
        
                 // Find matching Let's Talk user
         final matchingUser = letsTalkUsers.firstWhere(
           (user) => _cleanPhoneNumber(user.phone) == cleanNumber,
           orElse: () => app_contact.Contact(
             id: 0,
             userId: 0,
             name: deviceContact.displayName,
             phone: cleanNumber,
             email: deviceContact.emails.isNotEmpty ? deviceContact.emails.first.address : null,
             avatar: null,
             isFavorite: false,
             createdAt: DateTime.now(),
             updatedAt: DateTime.now(),
           ),
         );
        
        if (matchingUser.id > 0) {
          matchedContacts.add(matchingUser);
        }
      }
    }
    
    return matchedContacts;
  }

  /// Add a contact to favorites
  Future<void> addToFavorites(int contactId) async {
    // This would make an API call to add contact to favorites
    // Implementation depends on your backend API
  }

  /// Remove a contact from favorites
  Future<void> removeFromFavorites(int contactId) async {
    // This would make an API call to remove contact from favorites
    // Implementation depends on your backend API
  }

  /// Search contacts by name or phone number
  List<app_contact.Contact> searchContacts(String query) {
    if (query.isEmpty) return _appContacts;
    
    final lowercaseQuery = query.toLowerCase();
    return _appContacts.where((contact) {
      return contact.name.toLowerCase().contains(lowercaseQuery) ||
             contact.phone.contains(lowercaseQuery) ||
             (contact.email?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  /// Get favorite contacts
  List<app_contact.Contact> getFavoriteContacts() {
    return _appContacts.where((contact) => contact.isFavorite).toList();
  }

  /// Get recent contacts (last 10)
  List<app_contact.Contact> getRecentContacts() {
    final sortedContacts = List<app_contact.Contact>.from(_appContacts);
    sortedContacts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sortedContacts.take(10).toList();
  }

  /// Clear cached contacts
  void clearCache() {
    _deviceContacts.clear();
    _appContacts.clear();
  }

  /// Send SMS invitation to a contact
  Future<bool> sendSMSInvitation(String phoneNumber, String contactName) async {
    try {
      final message = _generateInvitationMessage(contactName);
      
      // Clean phone number for SMS (keep original format but remove spaces)
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
      final uri = Uri.parse('sms:$cleanNumber?body=${Uri.encodeComponent(message)}');
      
      print('🔗 SMS URI: $uri');
      print('📱 Phone number: $cleanNumber');
      
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched) {
          throw Exception('Failed to launch SMS app');
        }
        return true;
      } else {
        throw Exception('Could not launch SMS app - URL not supported');
      }
    } catch (e) {
      print('❌ SMS invitation error: $e');
      throw Exception('Failed to send SMS invitation: $e');
    }
  }

  /// Send WhatsApp invitation to a contact
  Future<bool> sendWhatsAppInvitation(String phoneNumber, String contactName) async {
    try {
      final message = _generateInvitationMessage(contactName);
      
      // Clean and format phone number for WhatsApp
      final cleanNumber = _formatPhoneForWhatsApp(phoneNumber);
      
      // Try multiple WhatsApp URL formats
      final uris = [
        Uri.parse('https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}'),
        Uri.parse('whatsapp://send?phone=$cleanNumber&text=${Uri.encodeComponent(message)}'),
        Uri.parse('https://api.whatsapp.com/send?phone=$cleanNumber&text=${Uri.encodeComponent(message)}'),
        Uri.parse('whatsapp://send?text=${Uri.encodeComponent(message)}'), // Just open WhatsApp
      ];
      
      print('🔗 WhatsApp URIs to try:');
      for (int i = 0; i < uris.length; i++) {
        print('  ${i + 1}. ${uris[i]}');
      }
      print('📱 Original number: $phoneNumber');
      print('📱 Formatted number: $cleanNumber');
      
      // Try each URI format
      for (final uri in uris) {
        try {
          if (await canLaunchUrl(uri)) {
            print('✅ Can launch: $uri');
            final launched = await launchUrl(
              uri, 
              mode: LaunchMode.externalApplication,
            );
            if (launched) {
              print('✅ Successfully launched WhatsApp');
              return true;
            } else {
              print('❌ Failed to launch: $uri');
            }
          } else {
            print('❌ Cannot launch: $uri');
          }
        } catch (e) {
          print('❌ Error with URI $uri: $e');
        }
      }
      
      // If all URIs fail, try opening in browser
      final webUri = Uri.parse('https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}');
      print('🌐 Trying to open in browser: $webUri');
      
      if (await canLaunchUrl(webUri)) {
        final launched = await launchUrl(webUri, mode: LaunchMode.externalApplication);
        if (launched) {
          print('✅ Opened WhatsApp Web in browser');
          return true;
        }
      }
      
      // If all methods fail, try sharing the message
      print('📤 Trying share method as fallback');
      try {
        final shareMessage = 'Hi $contactName! 👋\n\nI\'m using Let\'s Talk - a great messaging app! Join me and let\'s stay connected.\n\nDownload Let\'s Talk: https://lets-talk.app/download\n\nSee you there! 🚀';
        await Share.share(shareMessage, subject: 'Join Let\'s Talk!');
        print('✅ Shared message successfully');
        return true;
      } catch (shareError) {
        print('❌ Share method also failed: $shareError');
        throw Exception('Could not launch WhatsApp - no supported method found');
      }
    } catch (e) {
      print('❌ WhatsApp invitation error: $e');
      throw Exception('Failed to send WhatsApp invitation: $e');
    }
  }

  /// Format phone number for WhatsApp (remove all non-digits and ensure proper format)
  String _formatPhoneForWhatsApp(String phoneNumber) {
    // Remove all non-digit characters
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    print('🔧 Phone formatting steps:');
    print('  Original: $phoneNumber');
    print('  After removing non-digits: $cleanNumber');
    
    // Remove leading zeros
    while (cleanNumber.startsWith('0')) {
      cleanNumber = cleanNumber.substring(1);
      print('  After removing leading 0: $cleanNumber');
    }
    
    // Handle different number formats
    if (cleanNumber.length == 10) {
      // Nigerian number without country code, add 234
      cleanNumber = '234$cleanNumber';
      print('  Added country code (10 digits): $cleanNumber');
    } else if (cleanNumber.length == 11 && cleanNumber.startsWith('0')) {
      // Nigerian number with leading 0, replace with 234
      cleanNumber = '234${cleanNumber.substring(1)}';
      print('  Replaced leading 0 with country code: $cleanNumber');
    } else if (cleanNumber.length == 12 && cleanNumber.startsWith('234')) {
      // Already has Nigerian country code
      print('  Already has country code: $cleanNumber');
    } else if (cleanNumber.length == 11 && !cleanNumber.startsWith('0')) {
      // Nigerian number without leading 0, add country code
      cleanNumber = '234$cleanNumber';
      print('  Added country code (11 digits): $cleanNumber');
    } else if (cleanNumber.length >= 10 && cleanNumber.length <= 15) {
      // Assume it's already properly formatted
      print('  Assuming already formatted: $cleanNumber');
    } else {
      // Unknown format, try to make it work
      print('  Unknown format, using as is: $cleanNumber');
    }
    
    print('  Final formatted number: $cleanNumber');
    return cleanNumber;
  }

  /// Generate invitation message
  String _generateInvitationMessage(String contactName) {
    return 'Hi $contactName! 👋\n\nI\'m using Let\'s Talk - a great messaging app! Join me and let\'s stay connected.\n\nDownload Let\'s Talk: https://lets-talk.app/download\n\nSee you there! 🚀';
  }

  /// Get all device contacts for invitation
  Future<List<Contact>> getAllDeviceContactsForInvitation() async {
    if (!await checkPermission()) {
      throw Exception('Contact permission not granted');
    }

    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false, // Don't need photos for invitation list
      );
      
      // Filter contacts that have phone numbers
      return contacts.where((contact) => contact.phones.isNotEmpty).toList();
    } catch (e) {
      throw Exception('Failed to load contacts for invitation: $e');
    }
  }

  /// Get contacts that are not using Let's Talk
  Future<List<Contact>> getNonLetsTalkContacts() async {
    try {
      final allContacts = await getAllDeviceContactsForInvitation();
      final phoneNumbers = <String>[];
      
      // Extract phone numbers from all contacts
      for (final contact in allContacts) {
        for (final phone in contact.phones) {
          final cleanNumber = _cleanPhoneNumber(phone.number);
          if (cleanNumber.isNotEmpty) {
            phoneNumbers.add(cleanNumber);
          }
        }
      }
      
      // Check which phone numbers are using Let's Talk
      final letsTalkUsers = await findLetsTalkUsers(phoneNumbers);
      final letsTalkPhoneNumbers = letsTalkUsers.map((user) => _cleanPhoneNumber(user.phone)).toSet();
      
      // Return contacts that are not using Let's Talk
      return allContacts.where((contact) {
        for (final phone in contact.phones) {
          final cleanNumber = _cleanPhoneNumber(phone.number);
          if (!letsTalkPhoneNumbers.contains(cleanNumber)) {
            return true;
          }
        }
        return false;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get non-LetsTalk contacts: $e');
    }
  }

  /// Bulk invite contacts via SMS
  Future<List<String>> bulkInviteContacts(List<Contact> contacts, String invitationMethod) async {
    final results = <String>[];
    
    for (final contact in contacts) {
      try {
        final phoneNumber = contact.phones.first.number;
        final contactName = contact.displayName;
        
        bool success = false;
        if (invitationMethod == 'sms') {
          success = await sendSMSInvitation(phoneNumber, contactName);
        } else if (invitationMethod == 'whatsapp') {
          success = await sendWhatsAppInvitation(phoneNumber, contactName);
        }
        
        if (success) {
          results.add('✅ Invited ${contactName} via $invitationMethod');
        } else {
          results.add('❌ Failed to invite ${contactName} via $invitationMethod');
        }
      } catch (e) {
        results.add('❌ Error inviting ${contact.displayName}: $e');
      }
    }
    
    return results;
  }
}
