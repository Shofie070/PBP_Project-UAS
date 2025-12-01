import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/model.dart';

class ChatService {
  static const String _chatRoomsKey = 'chat_rooms';

  // Get all chat rooms for current user
  Future<List<ChatRoom>> getChatRooms(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_chatRoomsKey) ?? [];
    
    final List<ChatRoom> rooms = [];
    for (final item in data) {
      try {
        final json = jsonDecode(item);
        final room = ChatRoom.fromJson(json);
        if (room.userId == userId) {
          rooms.add(room);
        }
      } catch (_) {}
    }
    
    // Sort by last message time (newest first)
    rooms.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    return rooms;
  }

  // Get specific chat room
  Future<ChatRoom?> getChatRoom(String userId, String roomId) async {
    final rooms = await getChatRooms(userId);
    try {
      return rooms.firstWhere((room) => room.id == roomId);
    } catch (_) {
      return null;
    }
  }

  // Create or get admin chat room for user
  Future<ChatRoom> getOrCreateAdminChat(String userId, String userName, String userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_chatRoomsKey) ?? [];
    
    // Check if admin chat already exists
    final List<ChatRoom> rooms = [];
    for (final item in data) {
      try {
        final json = jsonDecode(item);
        final room = ChatRoom.fromJson(json);
        if (room.userId == userId) {
          rooms.add(room);
        }
      } catch (_) {}
    }

    // Find existing admin chat
    try {
      return rooms.firstWhere((room) => room.id.startsWith('admin_'));
    } catch (_) {
      // Create new admin chat room
      final roomId = 'admin_${DateTime.now().millisecondsSinceEpoch}';
      final newRoom = ChatRoom(
        id: roomId,
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        messages: [],
        createdAt: DateTime.now(),
        lastMessageAt: DateTime.now(),
      );

      // Save new room
      await saveChatRoom(newRoom);
      return newRoom;
    }
  }

  // Save or update chat room
  Future<void> saveChatRoom(ChatRoom room) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_chatRoomsKey) ?? [];
    
    // Remove old version of this room if exists
    data.removeWhere((item) {
      try {
        final json = jsonDecode(item);
        return json['id'] == room.id;
      } catch (_) {
        return false;
      }
    });

    // Add updated room
    data.add(jsonEncode(room.toJson()));
    await prefs.setStringList(_chatRoomsKey, data);
  }

  // Send message to admin chat
  Future<void> sendMessage(
    String roomId,
    String senderId,
    String senderName,
    String message,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_chatRoomsKey) ?? [];

    final updatedData = data.map((item) {
      try {
        final json = jsonDecode(item);
        if (json['id'] == roomId) {
          final room = ChatRoom.fromJson(json);
          
          // Create new message
          final newMessage = ChatMessage(
            id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
            senderId: senderId,
            senderName: senderName,
            message: message,
            timestamp: DateTime.now(),
            isFromAdmin: false,
          );

          // Add message to room
          room.messages.add(newMessage);

          // Update last message time
          final updatedRoom = ChatRoom(
            id: room.id,
            userId: room.userId,
            userName: room.userName,
            userEmail: room.userEmail,
            messages: room.messages,
            createdAt: room.createdAt,
            lastMessageAt: DateTime.now(),
            isActive: room.isActive,
          );

          return jsonEncode(updatedRoom.toJson());
        }
      } catch (_) {}
      return item;
    }).toList();

    await prefs.setStringList(_chatRoomsKey, updatedData);
  }

  // Send reply from admin (simulate admin response)
  Future<void> sendAdminReply(
    String roomId,
    String replyMessage,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_chatRoomsKey) ?? [];

    final updatedData = data.map((item) {
      try {
        final json = jsonDecode(item);
        if (json['id'] == roomId) {
          final room = ChatRoom.fromJson(json);
          
          // Create admin message
          final adminMessage = ChatMessage(
            id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
            senderId: 'admin',
            senderName: 'Admin',
            message: replyMessage,
            timestamp: DateTime.now(),
            isFromAdmin: true,
          );

          // Add message to room
          room.messages.add(adminMessage);

          // Update last message time
          final updatedRoom = ChatRoom(
            id: room.id,
            userId: room.userId,
            userName: room.userName,
            userEmail: room.userEmail,
            messages: room.messages,
            createdAt: room.createdAt,
            lastMessageAt: DateTime.now(),
            isActive: room.isActive,
          );

          return jsonEncode(updatedRoom.toJson());
        }
      } catch (_) {}
      return item;
    }).toList();

    await prefs.setStringList(_chatRoomsKey, updatedData);
  }

  // Delete chat room
  Future<void> deleteChatRoom(String roomId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_chatRoomsKey) ?? [];

    data.removeWhere((item) {
      try {
        final json = jsonDecode(item);
        return json['id'] == roomId;
      } catch (_) {
        return false;
      }
    });

    await prefs.setStringList(_chatRoomsKey, data);
  }

  // Clear all chats
  Future<void> clearAllChats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chatRoomsKey);
  }
}
