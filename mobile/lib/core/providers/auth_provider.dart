import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = true;
  bool _isAuthenticated = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      final token = await StorageService.getToken();
      if (token != null) {
        _token = token;
        _isAuthenticated = true;
        // Set token in ApiService
        ApiService().setToken(token);
        await _loadUserProfile();
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to manually initialize auth (called after ApiService is ready)
  Future<void> initializeAuth() async {
    await _initializeAuth();
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await ApiService().login(email, password);
      if (response.success && response.data != null) {
        _user = response.data!;
        _token = _user!.token;
        _isAuthenticated = true;

        await StorageService.saveToken(_token!);
        await StorageService.saveUser(_user!.toJson());
        // Set token in ApiService
        ApiService().setToken(_token!);

        return true;
      } else {
        debugPrint('Login failed: ${response.message}');
        return false;
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password, String phone) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await ApiService().register(name, email, password, phone);
      if (response.success && response.data != null) {
        _user = response.data!;
        _token = _user!.token;
        _isAuthenticated = true;

        await StorageService.saveToken(_token!);
        await StorageService.saveUser(_user!.toJson());
        // Set token in ApiService
        ApiService().setToken(_token!);

        return true;
      } else {
        debugPrint('Registration failed: ${response.message}');
        return false;
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await ApiService().logout();
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      _user = null;
      _token = null;
      _isAuthenticated = false;
      
      await StorageService.clearAll();
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final response = await ApiService().getProfile();
      if (response.success && response.data != null) {
        _user = response.data!;
        _isAuthenticated = true;
      } else {
        await logout();
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      await logout();
    }
  }



  // Check if user is already logged in
  Future<bool> checkLoginStatus() async {
    try {
      final token = await StorageService.getToken();
      final userData = await StorageService.getUser();
      
      if (token != null && userData != null) {
        _token = token;
        _user = User.fromJson(userData);
        _isAuthenticated = true;
        // Set token in ApiService
        ApiService().setToken(token);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return false;
    }
  }

  // Update user data locally
  void updateUser(User user) {
    _user = user;
    notifyListeners();
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Phone verification methods
  Future<Map<String, dynamic>> sendPhoneVerification(String phone, String name) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await ApiService().sendPhoneVerification(phone, name);
      if (!response['success']) {
        throw Exception(response['message'] ?? 'Failed to send verification code');
      }
      
      return response;
    } catch (e) {
      debugPrint('Send phone verification error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyOTP(String phone, String name, String otp) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await ApiService().verifyOTP(phone, name, otp);
      if (response['success'] && response['data'] != null) {
        _user = User.fromJson(response['data']['user']);
        _token = response['data']['token'];
        _isAuthenticated = true;

        await StorageService.saveToken(_token!);
        await StorageService.saveUser(_user!.toJson());
        // Set token in ApiService
        ApiService().setToken(_token!);
      } else {
        throw Exception(response['message'] ?? 'Invalid OTP');
      }
    } catch (e) {
      debugPrint('Verify OTP error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendTwoStepCode(String method) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await ApiService().sendTwoStepCode(method);
      if (!response['success']) {
        throw Exception(response['message'] ?? 'Failed to send two-step code');
      }
    } catch (e) {
      debugPrint('Send two-step code error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyTwoStepCode(String code) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await ApiService().verifyTwoStepCode(code);
      if (!response['success']) {
        throw Exception(response['message'] ?? 'Invalid two-step code');
      }
    } catch (e) {
      debugPrint('Verify two-step code error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyLoginCode(String phone, String code) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await ApiService().verifyLoginCode(phone, code);
      if (response.success && response.data != null) {
        _user = response.data!;
        _token = response.data!.token ?? '';
        _isAuthenticated = true;

        await StorageService.saveToken(_token!);
        await StorageService.saveUser(_user!.toJson());
        // Set token in ApiService
        ApiService().setToken(_token!);
      } else {
        throw Exception(response.message ?? 'Invalid login code');
      }
    } catch (e) {
      debugPrint('Verify login code error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
