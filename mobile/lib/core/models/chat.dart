import 'user.dart';
import 'message.dart';

class Chat {
  final int id;
  final String? name;
  final String type; // 'direct' or 'group'
  final String? description;
  final String? avatar;
  final int createdBy;
  final bool isActive;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatParticipant> participants;
  final Message? lastMessage;

  Chat({
    required this.id,
    this.name,
    required this.type,
    this.description,
    this.avatar,
    required this.createdBy,
    required this.isActive,
    this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
    required this.participants,
    this.lastMessage,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      description: json['description'],
      avatar: json['avatar'],
      createdBy: json['created_by'],
      isActive: json['is_active'] ?? true,
      lastMessageAt: json['last_message_at'] != null 
          ? DateTime.parse(json['last_message_at']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      participants: json['participants'] != null
          ? (json['participants'] as List)
              .map((p) => ChatParticipant.fromJson(p))
              .toList()
          : [],
      lastMessage: json['last_message'] != null 
          ? Message.fromJson(json['last_message']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'avatar': avatar,
      'created_by': createdBy,
      'is_active': isActive,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'participants': participants.map((p) => p.toJson()).toList(),
      'last_message': lastMessage?.toJson(),
    };
  }

  String get displayName {
    if (type == 'direct' && participants.length == 2) {
      // For direct chats, show the other participant's name
      return participants.firstWhere((p) => p.user.id != createdBy).user.name;
    }
    return name ?? 'Group Chat';
  }

  String get displayAvatar {
    if (avatar != null && avatar!.isNotEmpty) {
      return avatar!;
    }
    if (type == 'direct' && participants.length == 2) {
      // For direct chats, show the other participant's avatar
      return participants.firstWhere((p) => p.user.id != createdBy).user.avatar ?? '';
    }
    return '';
  }

  bool get isDirectChat => type == 'direct';
  bool get isGroupChat => type == 'group';

  @override
  String toString() {
    return 'Chat(id: $id, name: $name, type: $type, participants: ${participants.length})';
  }
}

class ChatParticipant {
  final int id;
  final int chatId;
  final User user;
  final String role; // 'admin', 'member', 'moderator'
  final DateTime joinedAt;
  final DateTime? leftAt;

  ChatParticipant({
    required this.id,
    required this.chatId,
    required this.user,
    required this.role,
    required this.joinedAt,
    this.leftAt,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      id: json['id'],
      chatId: json['chat_id'],
      user: User.fromJson(json['user']),
      role: json['role'],
      joinedAt: DateTime.parse(json['joined_at']),
      leftAt: json['left_at'] != null ? DateTime.parse(json['left_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'user': user.toJson(),
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
      'left_at': leftAt?.toIso8601String(),
    };
  }

  bool get isActive => leftAt == null;
  bool get isAdmin => role == 'admin';
  bool get isModerator => role == 'moderator';

  @override
  String toString() {
    return 'ChatParticipant(user: ${user.name}, role: $role)';
  }
}
