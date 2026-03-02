class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errors,
  });

  factory ApiResponse.success(T? data, {String? message}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error(String message, {Map<String, dynamic>? errors}) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
    );
  }

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    if (json['success'] == true) {
      return ApiResponse.success(fromJson(json['data']));
    } else {
      return ApiResponse.error(
        json['message'] ?? 'Unknown error',
        errors: json['errors'],
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (data != null) 'data': data,
      if (message != null) 'message': message,
      if (errors != null) 'errors': errors,
    };
  }
}
