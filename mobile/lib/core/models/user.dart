class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String? bio;
  final bool isVerified;
  final bool isActive;
  final bool? readReceipts;
  final bool? typingIndicators;
  final bool? profilePhotoVisible;
  final bool? lastSeenVisible;
  final bool? aboutVisible;
  final bool? groupsVisible;
  final bool? twoFactorEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? token; // Add token field for authentication

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.bio,
    required this.isVerified,
    required this.isActive,
    this.readReceipts,
    this.typingIndicators,
    this.profilePhotoVisible,
    this.lastSeenVisible,
    this.aboutVisible,
    this.groupsVisible,
    this.twoFactorEnabled,
    required this.createdAt,
    required this.updatedAt,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      avatar: json['avatar'],
      bio: json['bio'],
      isVerified: json['email_verified_at'] != null,
      isActive: json['is_active'] ?? true,
      readReceipts: json['read_receipts'],
      typingIndicators: json['typing_indicators'],
      profilePhotoVisible: json['profile_photo_visible'],
      lastSeenVisible: json['last_seen_visible'],
      aboutVisible: json['about_visible'],
      groupsVisible: json['groups_visible'],
      twoFactorEnabled: json['two_factor_enabled'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'bio': bio,
      'email_verified_at': isVerified ? updatedAt.toIso8601String() : null,
      'is_active': isActive,
      'read_receipts': readReceipts,
      'typing_indicators': typingIndicators,
      'profile_photo_visible': profilePhotoVisible,
      'last_seen_visible': lastSeenVisible,
      'about_visible': aboutVisible,
      'groups_visible': groupsVisible,
      'two_factor_enabled': twoFactorEnabled,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'token': token,
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    String? bio,
    bool? isVerified,
    bool? isActive,
    bool? readReceipts,
    bool? typingIndicators,
    bool? profilePhotoVisible,
    bool? lastSeenVisible,
    bool? aboutVisible,
    bool? groupsVisible,
    bool? twoFactorEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      readReceipts: readReceipts ?? this.readReceipts,
      typingIndicators: typingIndicators ?? this.typingIndicators,
      profilePhotoVisible: profilePhotoVisible ?? this.profilePhotoVisible,
      lastSeenVisible: lastSeenVisible ?? this.lastSeenVisible,
      aboutVisible: aboutVisible ?? this.aboutVisible,
      groupsVisible: groupsVisible ?? this.groupsVisible,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      token: token ?? this.token,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
