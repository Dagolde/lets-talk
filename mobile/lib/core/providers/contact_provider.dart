import 'package:flutter/foundation.dart';
import '../models/contact.dart';
import '../services/contact_service.dart';
import '../services/api_service.dart';

class ContactProvider extends ChangeNotifier {
  final ContactService _contactService = ContactService();
  final ApiService _apiService = ApiService();

  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  bool _isLoading = false;
  bool _hasPermission = false;
  String _searchQuery = '';
  String _error = '';

  List<Contact> get contacts => _contacts;
  List<Contact> get filteredContacts => _filteredContacts;
  bool get isLoading => _isLoading;
  bool get hasPermission => _hasPermission;
  String get searchQuery => _searchQuery;
  String get error => _error;

  /// Initialize contact provider
  Future<void> initialize() async {
    try {
      _hasPermission = await _contactService.checkPermission();
      if (_hasPermission) {
        await loadContacts();
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
        await loadContacts();
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

  /// Load contacts from device and sync with Let's Talk users
  Future<void> loadContacts() async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      // Load device contacts
      await _contactService.loadDeviceContacts();
      
      // Extract phone numbers
      final phoneNumbers = _contactService.extractPhoneNumbers();
      
      // Find Let's Talk users
      final letsTalkUsers = await _findLetsTalkUsers(phoneNumbers);
      
      // Match contacts with Let's Talk users
      _contacts = _matchContactsWithUsers(letsTalkUsers);
      
      // Apply current search filter
      _applySearchFilter();
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Find Let's Talk users by phone numbers
  Future<List<Contact>> _findLetsTalkUsers(List<String> phoneNumbers) async {
    try {
      // Debug: Check if ApiService is authenticated
      print('🔍 ContactProvider: Checking authentication status...');
      print('🔑 ApiService isAuthenticated: ${_apiService.isAuthenticated}');
      print('🔑 ApiService tokenStatus: ${_apiService.tokenStatus}');
      
      // Make API call to check which phone numbers are registered
      final response = await _apiService.findLetsTalkUsers(phoneNumbers);
      
      if (response.success && response.data != null) {
        print('✅ Found ${response.data!.length} Let\'s Talk users');
        return response.data!;
      } else {
        print('❌ Failed to find Let\'s Talk users: ${response.message}');
        return [];
      }
      
    } catch (e) {
      print('❌ Error finding Let\'s Talk users: $e');
      return [];
    }
  }

  /// Match device contacts with Let's Talk users
  List<Contact> _matchContactsWithUsers(List<Contact> letsTalkUsers) {
    final matchedContacts = <Contact>[];
    final deviceContacts = _contactService.deviceContacts;
    
    for (final deviceContact in deviceContacts) {
      for (final phone in deviceContact.phones) {
        final cleanNumber = _cleanPhoneNumber(phone.number);
        
        // Find matching Let's Talk user
        final matchingUser = letsTalkUsers.firstWhere(
          (user) => _cleanPhoneNumber(user.phone) == cleanNumber,
          orElse: () => Contact(
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

  /// Clean phone number by removing non-digit characters
  String _cleanPhoneNumber(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
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
      _filteredContacts = List.from(_contacts);
    } else {
      final lowercaseQuery = _searchQuery.toLowerCase();
      _filteredContacts = _contacts.where((contact) {
        return contact.name.toLowerCase().contains(lowercaseQuery) ||
               contact.phone.contains(lowercaseQuery) ||
               (contact.email?.toLowerCase().contains(lowercaseQuery) ?? false);
      }).toList();
    }
  }

  /// Get favorite contacts
  List<Contact> getFavoriteContacts() {
    return _contacts.where((contact) => contact.isFavorite).toList();
  }

  /// Get recent contacts (last 10)
  List<Contact> getRecentContacts() {
    final sortedContacts = List<Contact>.from(_contacts);
    sortedContacts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sortedContacts.take(10).toList();
  }

  /// Add contact to favorites
  Future<void> addToFavorites(int contactId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.addContactToFavorites(contactId);
      
      if (response.success) {
        // Update local contact
        final index = _contacts.indexWhere((contact) => contact.id == contactId);
        if (index != -1) {
          _contacts[index] = Contact(
            id: _contacts[index].id,
            userId: _contacts[index].userId,
            name: _contacts[index].name,
            phone: _contacts[index].phone,
            email: _contacts[index].email,
            avatar: _contacts[index].avatar,
            isFavorite: true,
            createdAt: _contacts[index].createdAt,
            updatedAt: DateTime.now(),
          );
          _applySearchFilter();
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Remove contact from favorites
  Future<void> removeFromFavorites(int contactId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.removeContactFromFavorites(contactId);
      
      if (response.success) {
        // Update local contact
        final index = _contacts.indexWhere((contact) => contact.id == contactId);
        if (index != -1) {
          _contacts[index] = Contact(
            id: _contacts[index].id,
            userId: _contacts[index].userId,
            name: _contacts[index].name,
            phone: _contacts[index].phone,
            email: _contacts[index].email,
            avatar: _contacts[index].avatar,
            isFavorite: false,
            createdAt: _contacts[index].createdAt,
            updatedAt: DateTime.now(),
          );
          _applySearchFilter();
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh contacts
  Future<void> refreshContacts() async {
    await loadContacts();
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
}
