import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/product_search.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class ProductSearchProvider extends ChangeNotifier {
  List<ProductSearchResult> _searchHistory = [];
  ProductSearchResult? _currentSearch;
  bool _isLoading = false;
  String? _error;
  User? _currentUser;

  List<ProductSearchResult> get searchHistory => _searchHistory;
  ProductSearchResult? get currentSearch => _currentSearch;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get currentUser => _currentUser;

  Future<void> loadSearchHistory() async {
    _setLoading(true);
    try {
      // Start with empty search history
      // In a real app, this would call the API to get actual search history
      _searchHistory = [];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<ProductSearchResult?> searchProduct(String query, {String? category, double? priceMin, double? priceMax}) async {
    _setLoading(true);
    try {
      final response = await ApiService().searchProducts(query, category: category, priceMin: priceMin, priceMax: priceMax);
      if (response.success && response.data != null) {
        _currentSearch = response.data!;
        _error = null;
        return response.data;
      } else {
        _error = response.message ?? 'Failed to search products';
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

  Future<ProductSearchResult?> searchProductByImage(File image, {String? category}) async {
    _setLoading(true);
    try {
      final response = await ApiService().searchProductsByImage(image, category: category);
      if (response.success && response.data != null) {
        _currentSearch = response.data!;
        _error = null;
        return response.data;
      } else {
        _error = response.message ?? 'Failed to search products by image';
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

  void clearCurrentSearch() {
    _currentSearch = null;
    notifyListeners();
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
