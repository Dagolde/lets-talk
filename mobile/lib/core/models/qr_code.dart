class QRCode {
  final int id;
  final int userId;
  final String type; // 'profile', 'payment', 'contact', 'website'
  final String title;
  final Map<String, dynamic> data;
  final String code;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  QRCode({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.data,
    required this.code,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QRCode.fromJson(Map<String, dynamic> json) {
    return QRCode(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'],
      title: json['title'],
      data: json['data'] ?? {},
      code: json['code'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'data': data,
      'code': code,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isProfileQR => type == 'profile';
  bool get isPaymentQR => type == 'payment';
  bool get isContactQR => type == 'contact';
  bool get isWebsiteQR => type == 'website';

  @override
  String toString() {
    return 'QRCode(id: $id, type: $type, title: $title)';
  }
}
