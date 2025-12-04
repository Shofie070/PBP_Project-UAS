import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isFromAdmin;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.isFromAdmin = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isFromAdmin: json['isFromAdmin'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isFromAdmin': isFromAdmin,
    };
  }

  @override
  List<Object?> get props =>
      [id, senderId, senderName, message, timestamp, isFromAdmin];
}

class ChatRoom extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final bool isActive;

  const ChatRoom({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.messages,
    required this.createdAt,
    required this.lastMessageAt,
    this.isActive = true,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastMessageAt: DateTime.parse(json['lastMessageAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'messages': messages.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        userEmail,
        messages,
        createdAt,
        lastMessageAt,
        isActive
      ];
}
