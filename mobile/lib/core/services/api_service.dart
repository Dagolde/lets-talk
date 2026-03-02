import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/payment.dart';
import '../models/contact.dart';
import '../models/qr_code.dart';
import '../models/product_search.dart';
import '../models/notification.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _authToken;

  Future<void> initialize() async {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Load stored token first
    await _loadStoredToken();

    // Add interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        
        if (ApiConfig.enableLogging) {
          print('🌐 API Request: ${options.method} ${options.path}');
          print('📤 Request Data: ${options.data}');
          print('🔑 Auth Token: ${_authToken != null ? 'Present' : 'Missing'}');
        }
        
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (ApiConfig.enableLogging) {
          print('✅ API Response: ${response.statusCode} ${response.requestOptions.path}');
          print('📥 Response Data: ${response.data}');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (ApiConfig.enableLogging) {
          print('❌ API Error: ${error.response?.statusCode} ${error.requestOptions.path}');
          print('🚨 Error Message: ${error.message}');
        }
        
        // Handle 401 errors (unauthorized)
        if (error.response?.statusCode == 401) {
          _handleUnauthorized();
        }
        
        handler.next(error);
      },
    ));
  }

  // Authentication Methods
  Future<ApiResponse<User>> login(String email, String password) async {
    try {
      // First send login code
      final sendCodeResponse = await _dio.post('/send-login-code', data: {
        'email': email,
      });
      
      if (sendCodeResponse.data['success']) {
        // Return success with message to enter code
        return ApiResponse.success(null, message: 'Login code sent to your email');
      } else {
        return ApiResponse.error(sendCodeResponse.data['message'] ?? 'Failed to send login code');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<User>> verifyLoginCode(String phone, String code) async {
    try {
      final response = await _dio.post('/verify-login-code', data: {
        'phone': phone,
        'code': code,
      });
      
      if (response.data['success']) {
        _authToken = response.data['data']['token'];
        await _saveToken(_authToken!);
        
        if (ApiConfig.enableLogging) {
          print('🔑 Token saved after login: ${_authToken != null ? 'Present' : 'Missing'}');
        }
        
        return ApiResponse.success(User.fromJson(response.data['data']['user']));
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Invalid login code');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<User>> register(String name, String email, String password, String phone) async {
    try {
      final response = await _dio.post('/verify-phone-and-register', data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'phone': phone,
      });
      
      if (response.data['success']) {
        _authToken = response.data['data']['token'];
        await _saveToken(_authToken!);
        return ApiResponse.success(User.fromJson(response.data['data']['user']));
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<void>> logout() async {
    try {
      // Only attempt logout if we have a token
      if (_authToken != null) {
        await _dio.post('/logout');
      }
      
      // Clear token regardless of API call success
      _authToken = null;
      await _removeToken();
      return ApiResponse.success(null);
    } on DioException catch (e) {
      // Even if logout API fails, clear local token
      _authToken = null;
      await _removeToken();
      
      // If it's a 401 error, that's expected (token already invalid)
      if (e.response?.statusCode == 401) {
        return ApiResponse.success(null);
      }
      
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<User>> getProfile() async {
    try {
      final response = await _dio.get('/user');
      return ApiResponse.success(User.fromJson(response.data['data']));
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<User>> updateProfile(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.put('/user', data: userData);
      
      if (response.data['success']) {
        return ApiResponse.success(User.fromJson(response.data['data']));
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to update profile');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<User>> updateAvatar(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(imageFile.path),
      });
      
      final response = await _dio.post('/user/avatar', data: formData);
      
      if (response.data['success']) {
        return ApiResponse.success(User.fromJson(response.data['data']));
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to update avatar');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<Map<String, dynamic>> toggleTwoFactor(bool enable) async {
    try {
      final endpoint = enable ? '/user/enable-two-factor' : '/user/disable-two-factor';
      final response = await _dio.post(endpoint);
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
      };
    }
  }

  Future<Map<String, dynamic>> getPaymentMethods() async {
    try {
      final response = await _dio.get('/user/payment-methods');
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
      };
    }
  }

  Future<Map<String, dynamic>> addPaymentMethod(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/user/payment-methods', data: data);
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
      };
    }
  }

  Future<Map<String, dynamic>> removePaymentMethod(String methodId) async {
    try {
      final response = await _dio.delete('/user/payment-methods/$methodId');
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
      };
    }
  }

  Future<Map<String, dynamic>> getTransactionHistory() async {
    try {
      final response = await _dio.get('/user/transactions');
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
      };
    }
  }

  // Phone verification methods
  Future<Map<String, dynamic>> sendPhoneVerification(String phone, String name) async {
    try {
      final response = await _dio.post('/send-phone-verification', data: {
        'phone': phone,
        'name': name,
      });
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
      };
    }
  }

  Future<Map<String, dynamic>> verifyOTP(String phone, String name, String otp) async {
    try {
      final response = await _dio.post('/verify-phone-and-register', data: {
        'phone': phone,
        'name': name,
        'otp': otp,
      });
      
      // If successful, store the token
      if (response.data['success'] && response.data['data']?['token'] != null) {
        _authToken = response.data['data']['token'];
        await _saveToken(_authToken!);
      }
      
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
      };
    }
  }

  Future<Map<String, dynamic>> sendTwoStepCode(String method) async {
    try {
      final response = await _dio.post('/user/send-two-step-code', data: {
        'method': method,
      });
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
      };
    }
  }

  Future<Map<String, dynamic>> verifyTwoStepCode(String code) async {
    try {
      final response = await _dio.post('/user/verify-two-factor', data: {
        'code': code,
      });
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
      };
    }
  }

  // Chat Methods
  Future<ApiResponse<List<Chat>>> getChats() async {
    try {
      final response = await _dio.get('/chats');
      final List<dynamic> chatsData = response.data['data'];
      final chats = chatsData.map((json) => Chat.fromJson(json)).toList();
      return ApiResponse.success(chats);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<Chat>> createChat(String type, List<int> participantIds, {String? name}) async {
    try {
      final response = await _dio.post('/chats', data: {
        'type': type,
        'participants': participantIds,
        if (name != null) 'name': name,
      });
      return ApiResponse.success(Chat.fromJson(response.data['data']));
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<List<Message>>> getMessages(int chatId) async {
    try {
      final response = await _dio.get('/chats/$chatId/messages');
      final List<dynamic> messagesData = response.data['data']['data'];
      final messages = messagesData.map((json) => Message.fromJson(json)).toList();
      return ApiResponse.success(messages);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<Message>> sendMessage(int chatId, String content, String type, {File? file}) async {
    try {
      FormData formData = FormData.fromMap({
        'content': content,
        'type': type,
      });
      
      if (file != null) {
        formData.files.add(MapEntry(
          'file',
          await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
        ));
      }
      
      final response = await _dio.post('/chats/$chatId/messages', data: formData);
      return ApiResponse.success(Message.fromJson(response.data['data']));
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  // Payment Methods
  Future<ApiResponse<List<Payment>>> getPayments() async {
    try {
      final response = await _dio.get('/payments');
      final List<dynamic> paymentsData = response.data['data']['data'];
      final payments = paymentsData.map((json) => Payment.fromJson(json)).toList();
      return ApiResponse.success(payments);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<Payment>> createPayment(int recipientId, double amount, String currency, String gateway, String type) async {
    try {
      final response = await _dio.post('/payments', data: {
        'recipient_id': recipientId,
        'amount': amount,
        'currency': currency,
        'gateway': gateway,
        'type': type,
      });
      return ApiResponse.success(Payment.fromJson(response.data['data']));
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> initializePayment(String gateway, double amount, String currency) async {
    try {
      final response = await _dio.post('/payments/$gateway/initialize', data: {
        'amount': amount,
        'currency': currency,
      });
      return ApiResponse.success(response.data['data']);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  // QR Code Methods
  Future<ApiResponse<List<QRCode>>> getQRCodes() async {
    try {
      final response = await _dio.get('/qr-codes');
      final List<dynamic> qrCodesData = response.data['data']['data'];
      final qrCodes = qrCodesData.map((json) => QRCode.fromJson(json)).toList();
      return ApiResponse.success(qrCodes);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<QRCode>> createQRCode(String type, String title, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/qr-codes', data: {
        'type': type,
        'title': title,
        'data': data,
      });
      return ApiResponse.success(QRCode.fromJson(response.data['data']));
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<QRCode>> scanQRCode(String code) async {
    try {
      final response = await _dio.post('/qr-codes/scan', data: {
        'code': code,
      });
      return ApiResponse.success(QRCode.fromJson(response.data['data']));
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  // Contact Methods
  Future<ApiResponse<List<Contact>>> getContacts() async {
    try {
      final response = await _dio.get('/contacts');
      final List<dynamic> contactsData = response.data['data']['data'];
      final contacts = contactsData.map((json) => Contact.fromJson(json)).toList();
      return ApiResponse.success(contacts);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<Contact>> addContact(String name, String phone, {String? email}) async {
    try {
      final response = await _dio.post('/contacts', data: {
        'name': name,
        'phone': phone,
        if (email != null) 'email': email,
      });
      return ApiResponse.success(Contact.fromJson(response.data['data']));
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<List<Contact>>> findLetsTalkUsers(List<String> phoneNumbers) async {
    try {
      final response = await _dio.post('/contacts/find-users', data: {
        'phone_numbers': phoneNumbers,
      });
      final List<dynamic> contactsData = response.data['data'];
      final contacts = contactsData.map((json) => Contact.fromJson(json)).toList();
      return ApiResponse.success(contacts);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<void>> addContactToFavorites(int contactId) async {
    try {
      await _dio.post('/contacts/$contactId/favorite');
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<void>> removeContactFromFavorites(int contactId) async {
    try {
      await _dio.delete('/contacts/$contactId/favorite');
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  // Product Search Methods
  Future<ApiResponse<ProductSearchResult>> searchProducts(String? query, {String? category, double? priceMin, double? priceMax}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (query != null && query.isNotEmpty) {
        queryParams['query'] = query;
      }
      if (category != null) {
        queryParams['category'] = category;
      }
      if (priceMin != null) {
        queryParams['price_min'] = priceMin;
      }
      if (priceMax != null) {
        queryParams['price_max'] = priceMax;
      }
      
      final response = await _dio.get('/product-search', queryParameters: queryParams);
      return ApiResponse.success(ProductSearchResult.fromJson(response.data['data']));
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<ProductSearchResult>> searchProductsByImage(File image, {String? category}) async {
    try {
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(image.path, filename: image.path.split('/').last),
        if (category != null) 'category': category,
      });
      
      final response = await _dio.post('/product-search/upload', data: formData);
      return ApiResponse.success(ProductSearchResult.fromJson(response.data['data']));
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<List<String>>> getProductSuggestions(String query) async {
    try {
      final response = await _dio.get('/product-search/suggestions', queryParameters: {
        'query': query,
      });
      
      if (response.data['success']) {
        final suggestions = List<String>.from(response.data['data'] ?? []);
        return ApiResponse.success(suggestions);
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to get suggestions');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  // Notification Methods
  Future<ApiResponse<List<AppNotification>>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications');
      final List<dynamic> notificationsData = response.data['data']['data'];
      final notifications = notificationsData.map((json) => AppNotification.fromJson(json)).toList();
      return ApiResponse.success(notifications);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<void>> markNotificationAsRead(int notificationId) async {
    try {
      await _dio.post('/notifications/$notificationId/read');
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  // User Management Methods
  Future<Map<String, dynamic>> getUsers() async {
    try {
      final response = await _dio.get('/users');
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
      };
    }
  }

  // File Upload Methods
  Future<ApiResponse<String>> uploadFile(File file, {String? description}) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
        if (description != null) 'description': description,
      });
      
      final response = await _dio.post('/files/upload', data: formData);
      return ApiResponse.success(response.data['data']['url']);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  // Utility Methods
  Future<void> loadStoredToken() async {
    _authToken = await _getToken();
  }

  Future<void> _loadStoredToken() async {
    try {
      _authToken = await _getToken();
      if (ApiConfig.enableLogging) {
        print('🔑 Loaded stored token: ${_authToken != null ? 'Present' : 'Missing'}');
      }
    } catch (e) {
      print('❌ Error loading stored token: $e');
      _authToken = null;
    }
  }

  bool get isAuthenticated => _authToken != null && _authToken!.isNotEmpty;
  
  // Method to check token status
  String get tokenStatus {
    if (_authToken == null) return 'No token';
    if (_authToken!.isEmpty) return 'Empty token';
    return 'Token present (${_authToken!.substring(0, 10)}...)';
  }

  // Method to set token from external source (like AuthProvider)
  void setToken(String token) {
    _authToken = token;
    if (ApiConfig.enableLogging) {
      print('🔑 Token set in ApiService: ${token.isNotEmpty ? 'Present' : 'Empty'}');
    }
    // Also save to storage
    _saveToken(token);
  }

  void _handleUnauthorized() {
    _authToken = null;
    _removeToken();
    // You can add navigation logic here to redirect to login
  }

  // Storage helper methods
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  String _handleDioError(DioException error) {
    if (error.response?.data != null && error.response?.data['message'] != null) {
      return error.response!.data['message'];
    }
    return error.message ?? 'Network error occurred';
  }
}
