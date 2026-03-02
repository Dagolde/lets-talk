import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRService {
  static final Dio _dio = Dio();
  static const String _baseUrl = 'http://localhost:8000/api';

  // Initialize QR service
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
        print('QR Service Error: ${error.message}');
        handler.next(error);
      },
    ));
  }

  // Generate QR code data
  static String generateQRData({
    required String type,
    required Map<String, dynamic> data,
  }) {
    final qrData = {
      'type': type,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    return jsonEncode(qrData);
  }

  // Generate payment QR code
  static String generatePaymentQR({
    required double amount,
    required String currency,
    required String description,
    String? recipientId,
  }) {
    return generateQRData(
      type: 'payment',
      data: {
        'amount': amount,
        'currency': currency,
        'description': description,
        if (recipientId != null) 'recipient_id': recipientId,
      },
    );
  }

  // Generate contact QR code
  static String generateContactQR({
    required String userId,
    required String name,
    String? email,
    String? phone,
  }) {
    return generateQRData(
      type: 'contact',
      data: {
        'user_id': userId,
        'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
      },
    );
  }

  // Generate group invite QR code
  static String generateGroupInviteQR({
    required String groupId,
    required String groupName,
    String? inviteCode,
  }) {
    return generateQRData(
      type: 'group_invite',
      data: {
        'group_id': groupId,
        'group_name': groupName,
        if (inviteCode != null) 'invite_code': inviteCode,
      },
    );
  }

  // Generate profile QR code
  static String generateProfileQR({
    required String userId,
    required String name,
    String? avatar,
  }) {
    return generateQRData(
      type: 'profile',
      data: {
        'user_id': userId,
        'name': name,
        if (avatar != null) 'avatar': avatar,
      },
    );
  }

  // Parse QR code data
  static Map<String, dynamic>? parseQRData(String qrData) {
    try {
      final data = jsonDecode(qrData);
      return data;
    } catch (e) {
      print('Failed to parse QR data: $e');
      return null;
    }
  }

  // Validate QR code data
  static bool isValidQRData(Map<String, dynamic> data) {
    return data.containsKey('type') && 
           data.containsKey('data') && 
           data.containsKey('timestamp');
  }

  // Check if QR code is expired
  static bool isQRExpired(Map<String, dynamic> data, {Duration maxAge = const Duration(hours: 24)}) {
    final timestamp = data['timestamp'] as int;
    final qrTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    return now.difference(qrTime) > maxAge;
  }

  // Create QR code on server
  static Future<Map<String, dynamic>> createQRCode({
    required String type,
    required Map<String, dynamic> data,
    Duration? expiration,
    int? maxUsage,
  }) async {
    try {
      final response = await _dio.post('/qr-codes', data: {
        'type': type,
        'data': data,
        if (expiration != null) 'expiration': expiration.inSeconds,
        if (maxUsage != null) 'max_usage': maxUsage,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to create QR code: $e');
    }
  }

  // Get QR code details
  static Future<Map<String, dynamic>> getQRCodeDetails(String qrCodeId) async {
    try {
      final response = await _dio.get('/qr-codes/$qrCodeId');
      return response.data;
    } catch (e) {
      throw Exception('Failed to get QR code details: $e');
    }
  }

  // Update QR code
  static Future<Map<String, dynamic>> updateQRCode({
    required String qrCodeId,
    Map<String, dynamic>? data,
    bool? isActive,
    Duration? expiration,
    int? maxUsage,
  }) async {
    try {
      final response = await _dio.put('/qr-codes/$qrCodeId', data: {
        if (data != null) 'data': data,
        if (isActive != null) 'is_active': isActive,
        if (expiration != null) 'expiration': expiration.inSeconds,
        if (maxUsage != null) 'max_usage': maxUsage,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to update QR code: $e');
    }
  }

  // Delete QR code
  static Future<void> deleteQRCode(String qrCodeId) async {
    try {
      await _dio.delete('/qr-codes/$qrCodeId');
    } catch (e) {
      throw Exception('Failed to delete QR code: $e');
    }
  }

  // Get user's QR codes
  static Future<List<Map<String, dynamic>>> getUserQRCodes({
    String? type,
    bool? isActive,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get('/qr-codes/user', queryParameters: {
        if (type != null) 'type': type,
        if (isActive != null) 'is_active': isActive,
        'page': page,
        'limit': limit,
      });

      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get user QR codes: $e');
    }
  }

  // Scan QR code
  static Future<Map<String, dynamic>> scanQRCode({
    required String qrData,
    required String scanType,
  }) async {
    try {
      final response = await _dio.post('/qr-codes/scan', data: {
        'qr_data': qrData,
        'scan_type': scanType,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to scan QR code: $e');
    }
  }

  // Get MobileScanner controller
  static MobileScannerController getScannerController() {
    return MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  // Process scanned QR code
  static Future<Map<String, dynamic>> processScannedQR({
    required Map<String, dynamic> qrData,
    required String scanType,
  }) async {
    try {
      final type = qrData['type'] as String;
      final data = qrData['data'] as Map<String, dynamic>;

      switch (type) {
        case 'payment':
          return await _processPaymentQR(data, scanType);
        case 'contact':
          return await _processContactQR(data, scanType);
        case 'group_invite':
          return await _processGroupInviteQR(data, scanType);
        case 'profile':
          return await _processProfileQR(data, scanType);
        default:
          throw Exception('Unknown QR code type: $type');
      }
    } catch (e) {
      throw Exception('Failed to process scanned QR: $e');
    }
  }

  // Process payment QR code
  static Future<Map<String, dynamic>> _processPaymentQR(
    Map<String, dynamic> data,
    String scanType,
  ) async {
    try {
      final response = await _dio.post('/payments/qr/process', data: {
        'amount': data['amount'],
        'currency': data['currency'],
        'description': data['description'],
        if (data.containsKey('recipient_id')) 'recipient_id': data['recipient_id'],
        'scan_type': scanType,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to process payment QR: $e');
    }
  }

  // Process contact QR code
  static Future<Map<String, dynamic>> _processContactQR(
    Map<String, dynamic> data,
    String scanType,
  ) async {
    try {
      final response = await _dio.post('/contacts/qr/process', data: {
        'user_id': data['user_id'],
        'name': data['name'],
        if (data.containsKey('email')) 'email': data['email'],
        if (data.containsKey('phone')) 'phone': data['phone'],
        'scan_type': scanType,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to process contact QR: $e');
    }
  }

  // Process group invite QR code
  static Future<Map<String, dynamic>> _processGroupInviteQR(
    Map<String, dynamic> data,
    String scanType,
  ) async {
    try {
      final response = await _dio.post('/groups/qr/join', data: {
        'group_id': data['group_id'],
        'group_name': data['group_name'],
        if (data.containsKey('invite_code')) 'invite_code': data['invite_code'],
        'scan_type': scanType,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to process group invite QR: $e');
    }
  }

  // Process profile QR code
  static Future<Map<String, dynamic>> _processProfileQR(
    Map<String, dynamic> data,
    String scanType,
  ) async {
    try {
      final response = await _dio.post('/users/qr/profile', data: {
        'user_id': data['user_id'],
        'name': data['name'],
        if (data.containsKey('avatar')) 'avatar': data['avatar'],
        'scan_type': scanType,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to process profile QR: $e');
    }
  }

  // Get QR code statistics
  static Future<Map<String, dynamic>> getQRCodeStatistics({
    String? type,
    Duration? period,
  }) async {
    try {
      final response = await _dio.get('/qr-codes/statistics', queryParameters: {
        if (type != null) 'type': type,
        if (period != null) 'period': period.inSeconds,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to get QR code statistics: $e');
    }
  }

  // Get QR code scan history
  static Future<List<Map<String, dynamic>>> getQRCodeScanHistory({
    String? qrCodeId,
    String? scanType,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get('/qr-codes/scans', queryParameters: {
        if (qrCodeId != null) 'qr_code_id': qrCodeId,
        if (scanType != null) 'scan_type': scanType,
        'page': page,
        'limit': limit,
      });

      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get QR code scan history: $e');
    }
  }

  // Share QR code
  static Future<Map<String, dynamic>> shareQRCode({
    required String qrCodeId,
    required List<String> platforms,
    String? message,
  }) async {
    try {
      final response = await _dio.post('/qr-codes/$qrCodeId/share', data: {
        'platforms': platforms,
        if (message != null) 'message': message,
      });

      return response.data;
    } catch (e) {
      throw Exception('Failed to share QR code: $e');
    }
  }

  // Download QR code image
  static Future<Uint8List> downloadQRCodeImage(String qrCodeId) async {
    try {
      final response = await _dio.get(
        '/qr-codes/$qrCodeId/image',
        options: Options(responseType: ResponseType.bytes),
      );

      return Uint8List.fromList(response.data);
    } catch (e) {
      throw Exception('Failed to download QR code image: $e');
    }
  }

  // Generate QR code widget
  static QrImageView generateQRWidget({
    required String data,
    double size = 200,
    Color? backgroundColor,
    Color? foregroundColor,
    int errorCorrectionLevel = QrErrorCorrectLevel.M,
  }) {
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
      backgroundColor: backgroundColor ?? const Color(0xFFFFFFFF),
      foregroundColor: foregroundColor ?? const Color(0xFF000000),
      errorCorrectionLevel: errorCorrectionLevel,
    );
  }

  // Validate QR code format
  static bool isValidQRFormat(String data) {
    try {
      final parsed = parseQRData(data);
      if (parsed == null) return false;
      
      return isValidQRData(parsed) && !isQRExpired(parsed);
    } catch (e) {
      return false;
    }
  }

  // Get QR code type
  static String? getQRCodeType(String data) {
    try {
      final parsed = parseQRData(data);
      return parsed?['type'] as String?;
    } catch (e) {
      return null;
    }
  }

  // Get QR code data
  static Map<String, dynamic>? getQRCodeData(String data) {
    try {
      final parsed = parseQRData(data);
      return parsed?['data'] as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }
}
