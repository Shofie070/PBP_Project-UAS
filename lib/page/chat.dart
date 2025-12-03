import 'package:flutter/material.dart';

import '../model/model.dart';
import '../service/chat_service.dart';
import 'chat_detail.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final String userName;
  final String userEmail;

  const ChatPage({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService();
  ChatRoom? _chatRoom;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    try {
      setState(() => _isLoading = true);
      // Automatically get or create the bot chat room
      final room = await _chatService.getOrCreateBotChat(
        widget.userId,
        widget.userName,
        widget.userEmail,
      );
      if (mounted) {
        setState(() {
          _chatRoom = room;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat chat')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_chatRoom == null) {
      return const Scaffold(
        body: Center(child: Text('Gagal memuat chat')),
      );
    }

    // Directly show the chat detail page
    return ChatDetailPage(
      chatRoom: _chatRoom!,
      userId: widget.userId,
      userName: widget.userName,
      onUpdate: () {}, // No-op since we don't have a list to update anymore
    );
  }
}
