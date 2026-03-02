import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletService {
  static final Dio _dio = Dio();
  static const String _baseUrl = 'http://localhost:8000/api';

  // Initialize wallet service
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
        print('Wallet Service Error: ${error.message}');
        handler.next(error);
      },
    ));
  }

  // Get wallet balance
  static Future<Map<String, dynamic>> getWalletBalance() async {
    try {
      final response = await _dio.get('/wallet/balance');
      return response.data;
    } catch (e) {
      throw Exception('Failed to get wallet balance: $e');
    }
  }

  // Add money to wallet
  static Future<Map<String, dynamic>> addMoney({
    required double amount,
    required String currency,
    required String paymentMethod,
    String? description,
  }) async {
    try {
      final response = await _dio.post('/wallet/add-money', data: {
        'amount': amount,
        'currency': currency,
        'payment_method': paymentMethod,
        if (description != null) 'description': description,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to add money: $e');
    }
  }

  // Withdraw money from wallet
  static Future<Map<String, dynamic>> withdrawMoney({
    required double amount,
    required String currency,
    required String withdrawalMethod,
    String? accountDetails,
    String? description,
  }) async {
    try {
      final response = await _dio.post('/wallet/withdraw', data: {
        'amount': amount,
        'currency': currency,
        'withdrawal_method': withdrawalMethod,
        if (accountDetails != null) 'account_details': accountDetails,
        if (description != null) 'description': description,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to withdraw money: $e');
    }
  }

  // Get transaction history
  static Future<List<Map<String, dynamic>>> getTransactionHistory({
    String? type,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get('/wallet/transactions', queryParameters: {
        if (type != null) 'type': type,
        if (status != null) 'status': status,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        'page': page,
        'limit': limit,
      });

      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get transaction history: $e');
    }
  }

  // Get transaction details
  static Future<Map<String, dynamic>> getTransactionDetails(String transactionId) async {
    try {
      final response = await _dio.get('/wallet/transactions/$transactionId');
      return response.data;
    } catch (e) {
      throw Exception('Failed to get transaction details: $e');
    }
  }

  // Get payment methods
  static Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    try {
      final response = await _dio.get('/wallet/payment-methods');
      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get payment methods: $e');
    }
  }

  // Add payment method
  static Future<Map<String, dynamic>> addPaymentMethod({
    required String type,
    required Map<String, dynamic> details,
    bool setAsDefault = false,
  }) async {
    try {
      final response = await _dio.post('/wallet/payment-methods', data: {
        'type': type,
        'details': details,
        'set_as_default': setAsDefault,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to add payment method: $e');
    }
  }

  // Update payment method
  static Future<Map<String, dynamic>> updatePaymentMethod({
    required String paymentMethodId,
    Map<String, dynamic>? details,
    bool? setAsDefault,
  }) async {
    try {
      final response = await _dio.put('/wallet/payment-methods/$paymentMethodId', data: {
        if (details != null) 'details': details,
        if (setAsDefault != null) 'set_as_default': setAsDefault,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to update payment method: $e');
    }
  }

  // Remove payment method
  static Future<void> removePaymentMethod(String paymentMethodId) async {
    try {
      await _dio.delete('/wallet/payment-methods/$paymentMethodId');
    } catch (e) {
      throw Exception('Failed to remove payment method: $e');
    }
  }

  // Set default payment method
  static Future<void> setDefaultPaymentMethod(String paymentMethodId) async {
    try {
      await _dio.post('/wallet/payment-methods/$paymentMethodId/default');
    } catch (e) {
      throw Exception('Failed to set default payment method: $e');
    }
  }

  // Get bank accounts
  static Future<List<Map<String, dynamic>>> getBankAccounts() async {
    try {
      final response = await _dio.get('/wallet/bank-accounts');
      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get bank accounts: $e');
    }
  }

  // Add bank account
  static Future<Map<String, dynamic>> addBankAccount({
    required String accountNumber,
    required String accountName,
    required String bankCode,
    String? routingNumber,
  }) async {
    try {
      final response = await _dio.post('/wallet/bank-accounts', data: {
        'account_number': accountNumber,
        'account_name': accountName,
        'bank_code': bankCode,
        if (routingNumber != null) 'routing_number': routingNumber,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to add bank account: $e');
    }
  }

  // Remove bank account
  static Future<void> removeBankAccount(String bankAccountId) async {
    try {
      await _dio.delete('/wallet/bank-accounts/$bankAccountId');
    } catch (e) {
      throw Exception('Failed to remove bank account: $e');
    }
  }

  // Verify bank account
  static Future<Map<String, dynamic>> verifyBankAccount(String bankAccountId) async {
    try {
      final response = await _dio.post('/wallet/bank-accounts/$bankAccountId/verify');
      return response.data;
    } catch (e) {
      throw Exception('Failed to verify bank account: $e');
    }
  }

  // Get supported banks
  static Future<List<Map<String, dynamic>>> getSupportedBanks({
    String? country,
  }) async {
    try {
      final response = await _dio.get('/wallet/supported-banks', queryParameters: {
        if (country != null) 'country': country,
      });

      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get supported banks: $e');
    }
  }

  // Get wallet statistics
  static Future<Map<String, dynamic>> getWalletStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _dio.get('/wallet/statistics', queryParameters: {
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to get wallet statistics: $e');
    }
  }

  // Get wallet limits
  static Future<Map<String, dynamic>> getWalletLimits() async {
    try {
      final response = await _dio.get('/wallet/limits');
      return response.data;
    } catch (e) {
      throw Exception('Failed to get wallet limits: $e');
    }
  }

  // Request limit increase
  static Future<Map<String, dynamic>> requestLimitIncrease({
    required String limitType,
    required double requestedAmount,
    String? reason,
  }) async {
    try {
      final response = await _dio.post('/wallet/limit-increase', data: {
        'limit_type': limitType,
        'requested_amount': requestedAmount,
        if (reason != null) 'reason': reason,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to request limit increase: $e');
    }
  }

  // Get wallet settings
  static Future<Map<String, dynamic>> getWalletSettings() async {
    try {
      final response = await _dio.get('/wallet/settings');
      return response.data;
    } catch (e) {
      throw Exception('Failed to get wallet settings: $e');
    }
  }

  // Update wallet settings
  static Future<Map<String, dynamic>> updateWalletSettings({
    String? defaultCurrency,
    bool? autoTopUp,
    double? autoTopUpAmount,
    String? autoTopUpThreshold,
    bool? transactionNotifications,
    bool? balanceNotifications,
  }) async {
    try {
      final response = await _dio.put('/wallet/settings', data: {
        if (defaultCurrency != null) 'default_currency': defaultCurrency,
        if (autoTopUp != null) 'auto_top_up': autoTopUp,
        if (autoTopUpAmount != null) 'auto_top_up_amount': autoTopUpAmount,
        if (autoTopUpThreshold != null) 'auto_top_up_threshold': autoTopUpThreshold,
        if (transactionNotifications != null) 'transaction_notifications': transactionNotifications,
        if (balanceNotifications != null) 'balance_notifications': balanceNotifications,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to update wallet settings: $e');
    }
  }

  // Generate wallet statement
  static Future<String> generateStatement({
    DateTime? startDate,
    DateTime? endDate,
    String format = 'pdf',
  }) async {
    try {
      final response = await _dio.post('/wallet/statement', data: {
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        'format': format,
      });

      return response.data['download_url'];
    } catch (e) {
      throw Exception('Failed to generate statement: $e');
    }
  }

  // Get wallet activity
  static Future<List<Map<String, dynamic>>> getWalletActivity({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get('/wallet/activity', queryParameters: {
        'page': page,
        'limit': limit,
      });

      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get wallet activity: $e');
    }
  }

  // Lock wallet
  static Future<void> lockWallet({
    String? reason,
    Duration? duration,
  }) async {
    try {
      await _dio.post('/wallet/lock', data: {
        if (reason != null) 'reason': reason,
        if (duration != null) 'duration': duration.inSeconds,
      });
    } catch (e) {
      throw Exception('Failed to lock wallet: $e');
    }
  }

  // Unlock wallet
  static Future<void> unlockWallet({
    required String pin,
    String? reason,
  }) async {
    try {
      await _dio.post('/wallet/unlock', data: {
        'pin': pin,
        if (reason != null) 'reason': reason,
      });
    } catch (e) {
      throw Exception('Failed to unlock wallet: $e');
    }
  }

  // Get wallet security settings
  static Future<Map<String, dynamic>> getWalletSecuritySettings() async {
    try {
      final response = await _dio.get('/wallet/security');
      return response.data;
    } catch (e) {
      throw Exception('Failed to get wallet security settings: $e');
    }
  }

  // Update wallet security settings
  static Future<Map<String, dynamic>> updateWalletSecuritySettings({
    bool? requirePinForTransactions,
    bool? requirePinForSettings,
    bool? biometricEnabled,
    int? sessionTimeout,
  }) async {
    try {
      final response = await _dio.put('/wallet/security', data: {
        if (requirePinForTransactions != null) 'require_pin_for_transactions': requirePinForTransactions,
        if (requirePinForSettings != null) 'require_pin_for_settings': requirePinForSettings,
        if (biometricEnabled != null) 'biometric_enabled': biometricEnabled,
        if (sessionTimeout != null) 'session_timeout': sessionTimeout,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to update wallet security settings: $e');
    }
  }

  // Change wallet PIN
  static Future<void> changeWalletPin({
    required String currentPin,
    required String newPin,
  }) async {
    try {
      await _dio.post('/wallet/change-pin', data: {
        'current_pin': currentPin,
        'new_pin': newPin,
      });
    } catch (e) {
      throw Exception('Failed to change wallet PIN: $e');
    }
  }

  // Reset wallet PIN
  static Future<Map<String, dynamic>> resetWalletPin({
    required String email,
    required String phone,
  }) async {
    try {
      final response = await _dio.post('/wallet/reset-pin', data: {
        'email': email,
        'phone': phone,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to reset wallet PIN: $e');
    }
  }

  // Validate wallet PIN
  static Future<bool> validateWalletPin(String pin) async {
    try {
      await _dio.post('/wallet/validate-pin', data: {
        'pin': pin,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Format currency
  static String formatCurrency(double amount, String currency) {
    // Basic currency formatting
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$${amount.toStringAsFixed(2)}';
      case 'EUR':
        return '€${amount.toStringAsFixed(2)}';
      case 'GBP':
        return '£${amount.toStringAsFixed(2)}';
      case 'NGN':
        return '₦${amount.toStringAsFixed(2)}';
      default:
        return '${amount.toStringAsFixed(2)} $currency';
    }
  }

  // Parse currency amount
  static double parseCurrencyAmount(String amount, String currency) {
    // Remove currency symbols and parse
    final cleanAmount = amount.replaceAll(RegExp(r'[^\d.,]'), '');
    return double.tryParse(cleanAmount) ?? 0.0;
  }

  // Validate amount
  static bool isValidAmount(double amount) {
    return amount > 0 && amount <= double.maxFinite;
  }

  // Get transaction type display name
  static String getTransactionTypeDisplayName(String type) {
    switch (type.toLowerCase()) {
      case 'credit':
        return 'Credit';
      case 'debit':
        return 'Debit';
      case 'transfer':
        return 'Transfer';
      case 'payment':
        return 'Payment';
      case 'refund':
        return 'Refund';
      case 'withdrawal':
        return 'Withdrawal';
      case 'deposit':
        return 'Deposit';
      default:
        return type;
    }
  }

  // Get transaction status display name
  static String getTransactionStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      case 'cancelled':
        return 'Cancelled';
      case 'processing':
        return 'Processing';
      default:
        return status;
    }
  }

  // Get transaction status color
  static String getTransactionStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return '#4CAF50';
      case 'pending':
        return '#FF9800';
      case 'processing':
        return '#2196F3';
      case 'failed':
        return '#F44336';
      case 'cancelled':
        return '#9E9E9E';
      default:
        return '#000000';
    }
  }
}
