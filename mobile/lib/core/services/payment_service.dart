import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PaymentGateway {
  stripe,
  paystack,
  flutterwave,
  paypal,
}

class PaymentService {
  static final Dio _dio = Dio();
  static const String _baseUrl = 'http://localhost:8000/api';

  // Payment Gateway Configuration
  static const Map<PaymentGateway, Map<String, String>> _gatewayConfigs = {
    PaymentGateway.stripe: {
      'name': 'Stripe',
      'publicKey': 'pk_test_your_stripe_public_key',
      'secretKey': 'sk_test_your_stripe_secret_key',
    },
    PaymentGateway.paystack: {
      'name': 'Paystack',
      'publicKey': 'pk_test_your_paystack_public_key',
      'secretKey': 'sk_test_your_paystack_secret_key',
    },
    PaymentGateway.flutterwave: {
      'name': 'Flutterwave',
      'publicKey': 'FLWPUBK_your_flutterwave_public_key',
      'secretKey': 'FLWSECK_your_flutterwave_secret_key',
    },
    PaymentGateway.paypal: {
      'name': 'PayPal',
      'publicKey': 'your_paypal_client_id',
      'secretKey': 'your_paypal_secret',
    },
  };

  // Initialize payment service
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
        print('Payment Service Error: ${error.message}');
        handler.next(error);
      },
    ));
  }

  // Get available payment gateways
  static List<PaymentGateway> getAvailableGateways() {
    return PaymentGateway.values;
  }

  // Get gateway configuration
  static Map<String, String> getGatewayConfig(PaymentGateway gateway) {
    return _gatewayConfigs[gateway] ?? {};
  }

  // Create payment intent
  static Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    required PaymentGateway gateway,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _dio.post('/payments/create-intent', data: {
        'amount': (amount * 100).round(), // Convert to cents
        'currency': currency,
        'gateway': gateway.name,
        'description': description,
        'metadata': metadata,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to create payment intent: $e');
    }
  }

  // Process payment with Stripe
  static Future<Map<String, dynamic>> processStripePayment({
    required String paymentIntentId,
    required String paymentMethodId,
  }) async {
    try {
      final response = await _dio.post('/payments/stripe/confirm', data: {
        'payment_intent_id': paymentIntentId,
        'payment_method_id': paymentMethodId,
      });

      return response.data;
    } catch (e) {
      throw Exception('Stripe payment failed: $e');
    }
  }

  // Process payment with Paystack
  static Future<Map<String, dynamic>> processPaystackPayment({
    required String reference,
    required String authorizationCode,
  }) async {
    try {
      final response = await _dio.post('/payments/paystack/verify', data: {
        'reference': reference,
        'authorization_code': authorizationCode,
      });

      return response.data;
    } catch (e) {
      throw Exception('Paystack payment failed: $e');
    }
  }

  // Process payment with Flutterwave
  static Future<Map<String, dynamic>> processFlutterwavePayment({
    required String transactionId,
    required String reference,
  }) async {
    try {
      final response = await _dio.post('/payments/flutterwave/verify', data: {
        'transaction_id': transactionId,
        'reference': reference,
      });

      return response.data;
    } catch (e) {
      throw Exception('Flutterwave payment failed: $e');
    }
  }

  // Process payment with PayPal
  static Future<Map<String, dynamic>> processPayPalPayment({
    required String orderId,
    required String payerId,
  }) async {
    try {
      final response = await _dio.post('/payments/paypal/capture', data: {
        'order_id': orderId,
        'payer_id': payerId,
      });

      return response.data;
    } catch (e) {
      throw Exception('PayPal payment failed: $e');
    }
  }

  // Get payment methods for user
  static Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    try {
      final response = await _dio.get('/payments/methods');
      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get payment methods: $e');
    }
  }

  // Add payment method
  static Future<Map<String, dynamic>> addPaymentMethod({
    required PaymentGateway gateway,
    required Map<String, dynamic> paymentData,
  }) async {
    try {
      final response = await _dio.post('/payments/methods', data: {
        'gateway': gateway.name,
        'payment_data': paymentData,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to add payment method: $e');
    }
  }

  // Remove payment method
  static Future<void> removePaymentMethod(String methodId) async {
    try {
      await _dio.delete('/payments/methods/$methodId');
    } catch (e) {
      throw Exception('Failed to remove payment method: $e');
    }
  }

  // Set default payment method
  static Future<void> setDefaultPaymentMethod(String methodId) async {
    try {
      await _dio.patch('/payments/methods/$methodId/default');
    } catch (e) {
      throw Exception('Failed to set default payment method: $e');
    }
  }

  // Get transaction history
  static Future<List<Map<String, dynamic>>> getTransactionHistory({
    int page = 1,
    int limit = 20,
    String? status,
    String? gateway,
  }) async {
    try {
      final response = await _dio.get('/payments/transactions', queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
        if (gateway != null) 'gateway': gateway,
      });

      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get transaction history: $e');
    }
  }

  // Get transaction details
  static Future<Map<String, dynamic>> getTransactionDetails(String transactionId) async {
    try {
      final response = await _dio.get('/payments/transactions/$transactionId');
      return response.data;
    } catch (e) {
      throw Exception('Failed to get transaction details: $e');
    }
  }

  // Request refund
  static Future<Map<String, dynamic>> requestRefund({
    required String transactionId,
    required double amount,
    required String reason,
  }) async {
    try {
      final response = await _dio.post('/payments/refunds', data: {
        'transaction_id': transactionId,
        'amount': (amount * 100).round(),
        'reason': reason,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to request refund: $e');
    }
  }

  // Get refund history
  static Future<List<Map<String, dynamic>>> getRefundHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get('/payments/refunds', queryParameters: {
        'page': page,
        'limit': limit,
      });

      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get refund history: $e');
    }
  }

  // Create QR payment
  static Future<Map<String, dynamic>> createQRPayment({
    required double amount,
    required String currency,
    required PaymentGateway gateway,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _dio.post('/payments/qr/create', data: {
        'amount': (amount * 100).round(),
        'currency': currency,
        'gateway': gateway.name,
        'description': description,
        'metadata': metadata,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to create QR payment: $e');
    }
  }

  // Scan QR payment
  static Future<Map<String, dynamic>> scanQRPayment({
    required String qrCode,
    required PaymentGateway gateway,
  }) async {
    try {
      final response = await _dio.post('/payments/qr/scan', data: {
        'qr_code': qrCode,
        'gateway': gateway.name,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to scan QR payment: $e');
    }
  }

  // Send money to another user
  static Future<Map<String, dynamic>> sendMoney({
    required String recipientId,
    required double amount,
    required String currency,
    required String description,
    PaymentGateway? gateway,
  }) async {
    try {
      final response = await _dio.post('/payments/send', data: {
        'recipient_id': recipientId,
        'amount': (amount * 100).round(),
        'currency': currency,
        'description': description,
        if (gateway != null) 'gateway': gateway.name,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to send money: $e');
    }
  }

  // Request money from another user
  static Future<Map<String, dynamic>> requestMoney({
    required String senderId,
    required double amount,
    required String currency,
    required String description,
  }) async {
    try {
      final response = await _dio.post('/payments/request', data: {
        'sender_id': senderId,
        'amount': (amount * 100).round(),
        'currency': currency,
        'description': description,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to request money: $e');
    }
  }

  // Get wallet balance
  static Future<Map<String, dynamic>> getWalletBalance() async {
    try {
      final response = await _dio.get('/payments/wallet/balance');
      return response.data;
    } catch (e) {
      throw Exception('Failed to get wallet balance: $e');
    }
  }

  // Add money to wallet
  static Future<Map<String, dynamic>> addMoneyToWallet({
    required double amount,
    required String currency,
    required PaymentGateway gateway,
  }) async {
    try {
      final response = await _dio.post('/payments/wallet/add', data: {
        'amount': (amount * 100).round(),
        'currency': currency,
        'gateway': gateway.name,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to add money to wallet: $e');
    }
  }

  // Withdraw money from wallet
  static Future<Map<String, dynamic>> withdrawFromWallet({
    required double amount,
    required String currency,
    required String bankAccountId,
  }) async {
    try {
      final response = await _dio.post('/payments/wallet/withdraw', data: {
        'amount': (amount * 100).round(),
        'currency': currency,
        'bank_account_id': bankAccountId,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to withdraw from wallet: $e');
    }
  }

  // Get bank accounts
  static Future<List<Map<String, dynamic>>> getBankAccounts() async {
    try {
      final response = await _dio.get('/payments/bank-accounts');
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
    required String bankName,
  }) async {
    try {
      final response = await _dio.post('/payments/bank-accounts', data: {
        'account_number': accountNumber,
        'account_name': accountName,
        'bank_code': bankCode,
        'bank_name': bankName,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to add bank account: $e');
    }
  }

  // Remove bank account
  static Future<void> removeBankAccount(String accountId) async {
    try {
      await _dio.delete('/payments/bank-accounts/$accountId');
    } catch (e) {
      throw Exception('Failed to remove bank account: $e');
    }
  }

  // Get supported banks (for Paystack/Flutterwave)
  static Future<List<Map<String, dynamic>>> getSupportedBanks({
    required PaymentGateway gateway,
  }) async {
    try {
      final response = await _dio.get('/payments/banks', queryParameters: {
        'gateway': gateway.name,
      });

      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get supported banks: $e');
    }
  }

  // Verify bank account
  static Future<Map<String, dynamic>> verifyBankAccount({
    required String accountNumber,
    required String bankCode,
    required PaymentGateway gateway,
  }) async {
    try {
      final response = await _dio.post('/payments/verify-bank-account', data: {
        'account_number': accountNumber,
        'bank_code': bankCode,
        'gateway': gateway.name,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to verify bank account: $e');
    }
  }

  // Get payment statistics
  static Future<Map<String, dynamic>> getPaymentStatistics({
    String? period,
    PaymentGateway? gateway,
  }) async {
    try {
      final response = await _dio.get('/payments/statistics', queryParameters: {
        if (period != null) 'period': period,
        if (gateway != null) 'gateway': gateway.name,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to get payment statistics: $e');
    }
  }
}
