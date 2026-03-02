class Contact {
  final int id;
  final int userId;
  final String name;
  final String phone;
  final String? email;
  final String? avatar;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  Contact({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    this.email,
    this.avatar,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      avatar: json['avatar'],
      isFavorite: json['is_favorite'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'phone': phone,
      'email': email,
      'avatar': avatar,
      'is_favorite': isFavorite,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Contact(id: $id, name: $name, phone: $phone)';
  }
}
