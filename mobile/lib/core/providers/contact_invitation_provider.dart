import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../services/contact_service.dart';

class ContactInvitationProvider extends ChangeNotifier {
  final ContactService _contactService = ContactService();

  List<Contact> _allContacts = [];
  List<Contact> _nonLetsTalkContacts = [];
  List<Contact> _selectedContacts = [];
  bool _isLoading = false;
  bool _hasPermission = false;
  String _error = '';
  String _searchQuery = '';

  List<Contact> get allContacts => _allContacts;
  List<Contact> get nonLetsTalkContacts => _nonLetsTalkContacts;
  List<Contact> get selectedContacts => _selectedContacts;
  bool get isLoading => _isLoading;
  bool get hasPermission => _hasPermission;
  String get error => _error;
  String get searchQuery => _searchQuery;

  /// Initialize the invitation provider
  Future<void> initialize() async {
    try {
      _hasPermission = await _contactService.checkPermission();
      if (_hasPermission) {
        await loadAllContacts();
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Request contact permission
  Future<bool> requestPermission() async {
    try {
      _isLoading = true;
      notifyListeners();

      _hasPermission = await _contactService.requestPermission();
      
      if (_hasPermission) {
        await loadAllContacts();
      }

      return _hasPermission;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all device contacts
  Future<void> loadAllContacts() async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      _allContacts = await _contactService.getAllDeviceContactsForInvitation();
      _nonLetsTalkContacts = await _contactService.getNonLetsTalkContacts();
      
      // Apply current search filter
      _applySearchFilter();
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search contacts
  void searchContacts(String query) {
    _searchQuery = query;
    _applySearchFilter();
    notifyListeners();
  }

  /// Apply search filter to contacts
  void _applySearchFilter() {
    if (_searchQuery.isEmpty) {
      // No filter applied
      return;
    } else {
      final lowercaseQuery = _searchQuery.toLowerCase();
      _nonLetsTalkContacts = _nonLetsTalkContacts.where((contact) {
        return contact.displayName.toLowerCase().contains(lowercaseQuery) ||
               contact.phones.any((phone) => phone.number.contains(lowercaseQuery));
      }).toList();
    }
  }

  /// Select a contact for invitation
  void selectContact(Contact contact) {
    if (!_selectedContacts.contains(contact)) {
      _selectedContacts.add(contact);
      notifyListeners();
    }
  }

  /// Deselect a contact
  void deselectContact(Contact contact) {
    _selectedContacts.remove(contact);
    notifyListeners();
  }

  /// Select all contacts
  void selectAllContacts() {
    _selectedContacts = List.from(_nonLetsTalkContacts);
    notifyListeners();
  }

  /// Deselect all contacts
  void deselectAllContacts() {
    _selectedContacts.clear();
    notifyListeners();
  }

  /// Check if a contact is selected
  bool isContactSelected(Contact contact) {
    return _selectedContacts.contains(contact);
  }

  /// Get selected contacts count
  int get selectedCount => _selectedContacts.length;

  /// Send SMS invitation to selected contacts
  Future<List<String>> inviteSelectedContactsViaSMS() async {
    try {
      _isLoading = true;
      notifyListeners();

      final results = await _contactService.bulkInviteContacts(_selectedContacts, 'sms');
      
      // Clear selection after sending invitations
      _selectedContacts.clear();
      
      return results;
    } catch (e) {
      _error = e.toString();
      return ['❌ Error: $e'];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send WhatsApp invitation to selected contacts
  Future<List<String>> inviteSelectedContactsViaWhatsApp() async {
    try {
      _isLoading = true;
      notifyListeners();

      final results = await _contactService.bulkInviteContacts(_selectedContacts, 'whatsapp');
      
      // Clear selection after sending invitations
      _selectedContacts.clear();
      
      return results;
    } catch (e) {
      _error = e.toString();
      return ['❌ Error: $e'];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send invitation to a single contact
  Future<bool> inviteSingleContact(Contact contact, String method) async {
    try {
      final phoneNumber = contact.phones.first.number;
      final contactName = contact.displayName;
      
      bool success = false;
      if (method == 'sms') {
        success = await _contactService.sendSMSInvitation(phoneNumber, contactName);
      } else if (method == 'whatsapp') {
        success = await _contactService.sendWhatsAppInvitation(phoneNumber, contactName);
      }
      
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Refresh contacts
  Future<void> refreshContacts() async {
    await loadAllContacts();
  }

  /// Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _applySearchFilter();
    notifyListeners();
  }

  /// Get contacts grouped by first letter
  Map<String, List<Contact>> getContactsGroupedByLetter() {
    final grouped = <String, List<Contact>>{};
    
    for (final contact in _nonLetsTalkContacts) {
      final firstLetter = contact.displayName.isNotEmpty 
          ? contact.displayName[0].toUpperCase() 
          : '#';
      
      if (!grouped.containsKey(firstLetter)) {
        grouped[firstLetter] = [];
      }
      grouped[firstLetter]!.add(contact);
    }
    
    // Sort each group
    for (final key in grouped.keys) {
      grouped[key]!.sort((a, b) => a.displayName.compareTo(b.displayName));
    }
    
    return grouped;
  }

  /// Get contacts with phone numbers only
  List<Contact> getContactsWithPhoneNumbers() {
    return _nonLetsTalkContacts.where((contact) => contact.phones.isNotEmpty).toList();
  }

  /// Get recent contacts (last 20)
  List<Contact> getRecentContacts() {
    final sortedContacts = List<Contact>.from(_nonLetsTalkContacts);
    // Sort by name for now, you could implement actual recent logic
    sortedContacts.sort((a, b) => a.displayName.compareTo(b.displayName));
    return sortedContacts.take(20).toList();
  }
}
