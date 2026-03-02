import 'package:flutter/foundation.dart';
import '../models/payment.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class PaymentProvider extends ChangeNotifier {
  List<Payment> _payments = [];
  bool _isLoading = false;
  String? _error;
  User? _currentUser;

  List<Payment> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get currentUser => _currentUser;

  Future<void> loadPayments() async {
    _setLoading(true);
    try {
      final response = await ApiService().getPayments();
      if (response.success && response.data != null) {
        _payments = response.data!;
        _error = null;
      } else {
        _error = response.message ?? 'Failed to load payments';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<Payment?> createPayment(int recipientId, double amount, String currency, String gateway, String type) async {
    _setLoading(true);
    try {
      final response = await ApiService().createPayment(recipientId, amount, currency, gateway, type);
      if (response.success && response.data != null) {
        _payments.add(response.data!);
        _error = null;
        return response.data;
      } else {
        _error = response.message ?? 'Failed to create payment';
        return null;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> initializePayment(String gateway, double amount, String currency) async {
    _setLoading(true);
    try {
      final response = await ApiService().initializePayment(gateway, amount, currency);
      if (response.success && response.data != null) {
        _error = null;
        return response.data;
      } else {
        _error = response.message ?? 'Failed to initialize payment';
        return null;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }



  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
}
