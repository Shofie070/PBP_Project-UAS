import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
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
    if (_messageController.text.trim().isEmpty) return;

    setState(() => _isSending = true);

    try {
      await _chatService.sendMessage(
        _currentRoom.id,
        widget.userId,
        widget.userName,
        _messageController.text.trim(),
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

      // Simulate admin reply after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        try {
          await _chatService.sendAdminReply(
            _currentRoom.id,
            'Terima kasih atas pesan Anda. Tim support kami akan segera membantu!',
          );

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
    final screenWidth = MediaQuery.of(context).size.width;
    

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () async {
            try {
              // Try to pop normally. maybePop returns false if there's nothing to pop.
              final didPop = await Navigator.maybePop(context);
              if (!didPop) {
                // Fallback: navigate to DashboardPage so we don't trigger a rebuild
                // of a page that may use uninitialized locale data.
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      appBar: AppBar(title: const Text('Beranda')),
                      body: const Center(child: Text('Halaman beranda')),
                    ),
                  ),
                );
              }
            } catch (e) {
              // If something unexpected happens, show a brief message and
              // navigate to the Dashboard as a safe fallback.
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal kembali: ${e.toString()}')),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      appBar: AppBar(title: const Text('Beranda')),
                      body: const Center(child: Text('Halaman beranda')),
                    ),
                  ),
                );
              }
            }
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                'A',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Admin Support',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Online',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _currentRoom.messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Mulai percakapan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    padding: EdgeInsets.all(2.w),
                    itemCount: _currentRoom.messages.length,
                    itemBuilder: (context, index) {
                      final message =
                          _currentRoom.messages[_currentRoom.messages.length - 1 - index];
                      final hour = message.timestamp.hour.toString().padLeft(2, '0');
                      final minute = message.timestamp.minute.toString().padLeft(2, '0');
                      final time = '$hour:$minute';

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                          child: Align(
                            alignment: message.isFromAdmin ? Alignment.centerLeft : Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: message.isFromAdmin
                                  ? MainAxisAlignment.start
                                  : MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (message.isFromAdmin)
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.blue.shade100,
                                    child: Text(
                                      'A',
                                      style: TextStyle(
                                        color: Colors.blue.shade600,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 8,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: message.isFromAdmin
                                        ? CrossAxisAlignment.start
                                        : CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        constraints: BoxConstraints(
                                          maxWidth: screenWidth * 0.65,
                                        ),
                                        decoration: BoxDecoration(
                                          color: message.isFromAdmin
                                              ? Colors.grey[100]
                                              : Colors.blue,
                                          borderRadius: BorderRadius.only(
                                            topLeft: const Radius.circular(12),
                                            topRight: const Radius.circular(12),
                                            bottomLeft: Radius.circular(message.isFromAdmin ? 0 : 12),
                                            bottomRight: Radius.circular(message.isFromAdmin ? 12 : 0),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.05),
                                              blurRadius: 3,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          message.message,
                                          style: TextStyle(
                                            fontSize: 6.5.sp,
                                            color: message.isFromAdmin
                                                ? Colors.black87
                                                : Colors.white,
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: message.isFromAdmin ? 0 : 4,
                                        ),
                                        child: Text(
                                          time,
                                          style: TextStyle(
                                            fontSize: 5.sp,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!message.isFromAdmin) const SizedBox(width: 6),
                              ],
                            ),
                            ),
                          );
                    },
                  ),
          ),
          // Message input - sama ukuran dengan search bar di dashboard
          Container(
              height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  width: 0.5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 1,
                    enabled: !_isSending,
                    textAlignVertical: TextAlignVertical.center,
                      style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Tulis pesan...',
                      hintStyle: TextStyle(
                          fontSize: 12,
                        color: Colors.grey[400],
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                          width: 0.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                          width: 0.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Colors.blue.shade300,
                          width: 1,
                        ),
                      ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                      isDense: true,
                    ),
                  ),
                ),
                  const SizedBox(width: 10),
                GestureDetector(
                  onTap: _isSending ? null : _sendMessage,
                  child: Container(
                      width: 40,
                      height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade400,
                          Colors.blue.shade600,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isSending
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withOpacity(0.8),
                                ),
                              ),
                            )
                          : Icon(
                              Icons.send_rounded,
                                size: 18,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
