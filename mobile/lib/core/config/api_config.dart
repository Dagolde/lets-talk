class ApiConfig {
  // Environment configuration
  static const String environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
  
  // Base URLs for different environments
  static const Map<String, String> baseUrls = {
    'development': 'http://192.168.1.106:8000/api',
    'staging': 'https://staging-api.letstalk.com/api',
    'production': 'https://api.letstalk.com/api',
  };
  
  // Get the appropriate base URL for the current environment
  static String get baseUrl => baseUrls[environment] ?? baseUrls['development']!;
  
  // API timeout configurations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // Retry configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // WebSocket configuration
  static String get wsUrl {
    final baseUrl = ApiConfig.baseUrl.replaceFirst('/api', '');
    return baseUrl.replaceFirst('http', 'ws');
  }
  
  // File upload configuration
  static const int maxFileSize = 100 * 1024 * 1024; // 100MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> allowedVideoTypes = ['mp4', 'avi', 'mov', 'mkv'];
  static const List<String> allowedAudioTypes = ['mp3', 'wav', 'aac', 'm4a'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx', 'txt'];
  
  // Payment gateway configuration
  static const Map<String, bool> paymentGateways = {
    'stripe': true,
    'paystack': true,
    'flutterwave': true,
    'internal': true,
  };
  
  // Debug configuration
  static const bool enableLogging = true;
  static const bool enableMockData = false;
}
