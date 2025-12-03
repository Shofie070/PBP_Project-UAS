import 'package:flutter/material.dart';

import '../model/model.dart';
import '../service/chat_service.dart';

class ChatDetailPage extends StatefulWidget {
  final ChatRoom chatRoom;
  final String userId;
  final String userName;
  final VoidCallback onUpdate;

  const ChatDetailPage({
    super.key,
    required this.chatRoom,
    required this.userId,
    required this.userName,
    required this.onUpdate,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  late TextEditingController _messageController;
  final ChatService _chatService = ChatService();
  late ChatRoom _currentRoom;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _currentRoom = widget.chatRoom;
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final textToSend =
        _messageController.text.trim(); // Capture text before clearing
    if (textToSend.isEmpty) return;

    setState(() => _isSending = true);

    try {
      await _chatService.sendMessage(
        _currentRoom.id,
        widget.userId,
        widget.userName,
        textToSend,
      );

      _messageController.clear();

      // Reload chat room
      try {
        final updated = await _chatService.getChatRoom(
          widget.userId,
          _currentRoom.id,
        );
        if (updated != null && mounted) {
          setState(() => _currentRoom = updated);
        }
      } catch (e) {
        // Handle error silently
      }

      if (mounted) {
        try {
          if (_currentRoom.id.startsWith('bot_')) {
            // Bot reply (real AI, no artificial delay needed)
            await _chatService.sendBotReply(
              _currentRoom.id,
              textToSend, // Use captured text
            );
          } else {
            // Admin reply simulation
            await Future.delayed(const Duration(seconds: 1));
            await _chatService.sendAdminReply(
              _currentRoom.id,
              'Terima kasih atas pesan Anda. Tim support kami akan segera membantu!',
            );
          }

          final updatedAgain = await _chatService.getChatRoom(
            widget.userId,
            _currentRoom.id,
          );
          if (updatedAgain != null && mounted) {
            setState(() => _currentRoom = updatedAgain);
          }
        } catch (e) {
          // Handle error silently
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim pesan')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }

    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Common Chat UI Content
    Widget chatContent = Column(
      children: [
        // Custom Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade600,
                Colors.blue.shade400,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white.withOpacity(0.2),
                child:
                    const Icon(Icons.smart_toy, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Urban Assistant',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Online',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),

        // Messages Area
        Expanded(
          child: Container(
            color: isDark ? Colors.black : const Color(0xFFF5F7FB),
            child: _currentRoom.messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Mulai percakapan',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: _currentRoom.messages.length,
                    itemBuilder: (context, index) {
                      final message = _currentRoom
                          .messages[_currentRoom.messages.length - 1 - index];
                      final isMe = !message.isFromAdmin;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: isMe
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isMe) ...[
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.blue.shade100,
                                child: Icon(Icons.smart_toy,
                                    size: 16, color: Colors.blue.shade700),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? Colors.blue.shade600
                                      : (isDark
                                          ? Colors.grey[800]
                                          : Colors.white),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                                    bottomRight: Radius.circular(isMe ? 4 : 16),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  message.message,
                                  style: TextStyle(
                                    color: isMe
                                        ? Colors.white
                                        : (isDark
                                            ? Colors.white
                                            : Colors.black87),
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),

        // Input Area
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : const Color(0xFFF5F7FB),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _messageController,
                    enabled: !_isSending,
                    decoration: const InputDecoration(
                      hintText: 'Tulis pesan...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(fontSize: 14),
                    minLines: 1,
                    maxLines: 3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _isSending ? null : _sendMessage,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade500,
                        Colors.blue.shade700,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      body: SafeArea(child: chatContent),
    );
  }
}
