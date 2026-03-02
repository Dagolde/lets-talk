import 'user.dart';

class Message {
  final int id;
  final int chatId;
  final int senderId;
  final String? content;
  final String type; // 'text', 'image', 'video', 'audio', 'file', 'location', 'contact', 'payment'
  final String? filePath;
  final String? fileName;
  final int? fileSize;
  final String? fileType;
  final Map<String, dynamic>? locationData;
  final Map<String, dynamic>? contactData;
  final Map<String, dynamic>? paymentData;
  final int? replyToId;
  final Message? replyTo;
  final bool isEdited;
  final DateTime? editedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User sender;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.content,
    required this.type,
    this.filePath,
    this.fileName,
    this.fileSize,
    this.fileType,
    this.locationData,
    this.contactData,
    this.paymentData,
    this.replyToId,
    this.replyTo,
    required this.isEdited,
    this.editedAt,
    required this.isDeleted,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.sender,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      chatId: json['chat_id'],
      senderId: json['sender_id'],
      content: json['content'],
      type: json['type'],
      filePath: json['file_path'],
      fileName: json['file_name'],
      fileSize: json['file_size'],
      fileType: json['file_type'],
      locationData: json['location_data'],
      contactData: json['contact_data'],
      paymentData: json['payment_data'],
      replyToId: json['reply_to_id'],
      replyTo: json['reply_to'] != null ? Message.fromJson(json['reply_to']) : null,
      isEdited: json['is_edited'] ?? false,
      editedAt: json['edited_at'] != null ? DateTime.parse(json['edited_at']) : null,
      isDeleted: json['is_deleted'] ?? false,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      sender: User.fromJson(json['sender']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
      'type': type,
      'file_path': filePath,
      'file_name': fileName,
      'file_size': fileSize,
      'file_type': fileType,
      'location_data': locationData,
      'contact_data': contactData,
      'payment_data': paymentData,
      'reply_to_id': replyToId,
      'reply_to': replyTo?.toJson(),
      'is_edited': isEdited,
      'edited_at': editedAt?.toIso8601String(),
      'is_deleted': isDeleted,
      'deleted_at': deletedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sender': sender.toJson(),
    };
  }

  bool get isTextMessage => type == 'text';
  bool get isImageMessage => type == 'image';
  bool get isVideoMessage => type == 'video';
  bool get isAudioMessage => type == 'audio';
  bool get isFileMessage => type == 'file';
  bool get isLocationMessage => type == 'location';
  bool get isContactMessage => type == 'contact';
  bool get isPaymentMessage => type == 'payment';

  String get displayContent {
    if (isDeleted) return 'This message was deleted';
    if (isTextMessage) return content ?? '';
    if (isImageMessage) return '📷 Image';
    if (isVideoMessage) return '🎥 Video';
    if (isAudioMessage) return '🎵 Audio';
    if (isFileMessage) return '📎 File: ${fileName ?? 'Unknown'}';
    if (isLocationMessage) return '📍 Location';
    if (isContactMessage) return '👤 Contact';
    if (isPaymentMessage) return '💳 Payment';
    return 'Unknown message type';
  }

  String get fileUrl {
    if (filePath != null && filePath!.isNotEmpty) {
      return 'http://127.0.0.1:8000/storage/$filePath';
    }
    return '';
  }

  @override
  String toString() {
    return 'Message(id: $id, type: $type, content: $content)';
  }
}
