import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
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
  List<ChatRoom> _chatRooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }

  Future<void> _loadChatRooms() async {
    try {
      setState(() => _isLoading = true);
      _chatRooms = await _chatService.getChatRooms(widget.userId);
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _startChat() async {
    try {
      final room = await _chatService.getOrCreateAdminChat(
        widget.userId,
        widget.userName,
        widget.userEmail,
      );
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(
              chatRoom: room,
              userId: widget.userId,
              userName: widget.userName,
              onUpdate: _loadChatRooms,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat chat')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _chatRooms.isEmpty ? 'Chat dengan Admin' : 'Pesan (${_chatRooms.length})',
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chatRooms.isEmpty
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
                        'Belum ada chat',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Mulai percakapan dengan admin',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[400],
                        ),
                      ),
                      SizedBox(height: 3.h),
                      ElevatedButton.icon(
                        onPressed: _startChat,
                        icon: const Icon(Icons.message),
                        label: const Text('Mulai Chat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.w,
                            vertical: 1.5.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(2.w),
                  itemCount: _chatRooms.length,
                  itemBuilder: (context, index) {
                    final room = _chatRooms[index];
                    final lastMessage = room.messages.isNotEmpty
                        ? room.messages.last.message
                        : 'Belum ada pesan';
                    // Format lastTime without intl to avoid locale init errors
                    String lastTime = '';
                    try {
                      final dt = room.lastMessageAt;
                      const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
                      final day = dt.day.toString().padLeft(2, '0');
                      final month = months[dt.month - 1];
                      final hour = dt.hour.toString().padLeft(2, '0');
                      final minute = dt.minute.toString().padLeft(2, '0');
                      lastTime = '$day $month, $hour:$minute';
                    } catch (_) {
                      lastTime = '';
                    }

                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        leading: SizedBox(
                          width: 40,
                          height: 40,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.blue,
                            child: const Text(
                              'A',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        title: const Text(
                          'Admin Support',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              lastTime,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (room.messages.isNotEmpty && !room.messages.last.isFromAdmin)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${room.messages.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatDetailPage(
                                chatRoom: room,
                                userId: widget.userId,
                                userName: widget.userName,
                                onUpdate: _loadChatRooms,
                              ),
                            ),
                          );
                          _loadChatRooms();
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: _chatRooms.isNotEmpty
          ? FloatingActionButton(
              onPressed: _startChat,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.message),
            )
          : null,
    );
  }
}
