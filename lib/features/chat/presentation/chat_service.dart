import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../model/model.dart';
import '../../../service/api_service.dart';

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
  Future<ChatRoom> getOrCreateAdminChat(
      String userId, String userName, String userEmail) async {
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

  // Create or get bot chat room for user
  Future<ChatRoom> getOrCreateBotChat(
      String userId, String userName, String userEmail) async {
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

    // Find existing bot chat
    try {
      return rooms.firstWhere((room) => room.id.startsWith('bot_'));
    } catch (_) {
      // Create new bot chat room
      final roomId = 'bot_${DateTime.now().millisecondsSinceEpoch}';
      final newRoom = ChatRoom(
        id: roomId,
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        messages: [
          ChatMessage(
            id: 'msg_welcome_${DateTime.now().millisecondsSinceEpoch}',
            senderId: 'bot',
            senderName: 'Smart Bot',
            message:
                'Halo! Saya Smart Bot. Ada yang bisa saya bantu? Ketik "menu" untuk melihat bantuan.',
            timestamp: DateTime.now(),
            isFromAdmin: true,
          ),
        ],
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

  // Send reply from bot
  Future<void> sendBotReply(
    String roomId,
    String userMessage,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_chatRoomsKey) ?? [];

    String replyMessage = '';

    try {
      // Groq API Configuration
      // TODO: Replace with valid Groq API Key
      const apiKey = 'YOUR_GROQ_API_KEY_HERE';
      if (apiKey == 'YOUR_GROQ_API_KEY_HERE' || apiKey.isEmpty) {
        replyMessage =
            'Mohon maaf, API Key Groq belum dikonfigurasi. Silakan tambahkan API Key Anda di chat_service.dart.';
      } else {
        final url =
            Uri.parse('https://api.groq.com/openai/v1/chat/completions');
        final headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        };

        // Fetch product data
        final apiService = ApiService();
        final products = await apiService.getDashboardProducts();

        String productContext = 'Daftar Produk Tersedia:\n';
        if (products.isEmpty) {
          productContext += '- Belum ada data produk.\n';
        } else {
          for (var p in products) {
            productContext +=
                '- ${p.name} (${p.category}): Rp ${p.price.toStringAsFixed(0)}\n';
          }
        }

        final body = jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'system',
              'content': 'Kamu adalah asisten virtual untuk aplikasi "Urban Wear". '
                  'Tugasmu adalah membantu pengguna terkait fashion, pakaian, dan produk kami. '
                  'Jawablah dengan sopan, ramah, dan menggunakan Bahasa Indonesia yang baik. '
                  'Gunakan data produk berikut untuk menjawab pertanyaan tentang ketersediaan dan harga:\n\n'
                  '$productContext\n\n'
                  'Jika pengguna bertanya tentang produk yang TIDAK ada di daftar ini, katakan bahwa kami tidak menjualnya saat ini.'
            },
            {
              'role': 'user',
              'content': userMessage,
            }
          ],
          'temperature': 0.7,
        });

        final response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          replyMessage = jsonResponse['choices'][0]['message']['content'];
        } else {
          replyMessage = 'Error (${response.statusCode}): ${response.body}';
        }
      }
    } catch (e) {
      replyMessage = 'Maaf, terjadi kesalahan pada sistem AI: $e';
    }

    final updatedData = data.map((item) {
      try {
        final json = jsonDecode(item);
        if (json['id'] == roomId) {
          final room = ChatRoom.fromJson(json);

          // Create bot message
          final botMessage = ChatMessage(
            id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
            senderId: 'bot',
            senderName: 'Smart Bot',
            message: replyMessage,
            timestamp: DateTime.now(),
            isFromAdmin: true,
          );

          // Add message to room
          room.messages.add(botMessage);

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
