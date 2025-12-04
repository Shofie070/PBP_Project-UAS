import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';

class ChatDetailPage extends StatefulWidget {
  final String userId;
  final String userName;

  const ChatDetailPage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage(BuildContext context) {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      context
          .read<ChatCubit>()
          .sendMessage(widget.userId, widget.userName, text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(builder: (context, constraints) {
      final isDesktop = constraints.maxWidth > 900;
      double responsiveSize(double mobileSp, double desktopPx) =>
          isDesktop ? desktopPx : mobileSp.sp;

      return BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state.status == ChatStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Error')),
            );
          }
        },
        builder: (context, state) {
          if (state.status == ChatStatus.loading && state.chatRoom == null) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }

          if (state.chatRoom == null) {
            return const Scaffold(
                body: Center(child: Text('Gagal memuat chat')));
          }

          final chatRoom = state.chatRoom!;
          final isSending = state.status == ChatStatus.sending;

          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  // Custom Header
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 16 : 4.w,
                        vertical: isDesktop ? 12 : 1.5.h),
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
                          radius: isDesktop ? 16 : 4.w,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Icon(Icons.smart_toy,
                              color: Colors.white,
                              size: responsiveSize(14, 18)),
                        ),
                        SizedBox(width: isDesktop ? 12 : 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Urban Assistant',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: responsiveSize(12, 16),
                                ),
                              ),
                              Text(
                                'Online',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: responsiveSize(9, 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close,
                              color: Colors.white,
                              size: responsiveSize(16, 20)),
                          onPressed: () => context.pop(),
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
                      child: chatRoom.messages.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    size: responsiveSize(40, 60),
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: isDesktop ? 16 : 2.h),
                                  Text(
                                    'Mulai percakapan',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                      fontSize: responsiveSize(11, 14),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              reverse: true,
                              padding: EdgeInsets.all(isDesktop ? 16 : 4.w),
                              itemCount: chatRoom.messages.length,
                              itemBuilder: (context, index) {
                                final message = chatRoom.messages[
                                    chatRoom.messages.length - 1 - index];
                                final isMe = !message.isFromAdmin;

                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: isDesktop ? 4 : 0.5.h),
                                  child: Row(
                                    mainAxisAlignment: isMe
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (!isMe) ...[
                                        CircleAvatar(
                                          radius: isDesktop ? 14 : 3.5.w,
                                          backgroundColor: Colors.blue.shade100,
                                          child: Icon(Icons.smart_toy,
                                              size: responsiveSize(12, 16),
                                              color: Colors.blue.shade700),
                                        ),
                                        SizedBox(width: isDesktop ? 8 : 2.w),
                                      ],
                                      Flexible(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isDesktop ? 16 : 4.w,
                                            vertical: isDesktop ? 10 : 1.2.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isMe
                                                ? Colors.blue.shade600
                                                : (isDark
                                                    ? Colors.grey[800]
                                                    : Colors.white),
                                            borderRadius: BorderRadius.only(
                                              topLeft:
                                                  const Radius.circular(16),
                                              topRight:
                                                  const Radius.circular(16),
                                              bottomLeft: Radius.circular(
                                                  isMe ? 16 : 4),
                                              bottomRight: Radius.circular(
                                                  isMe ? 4 : 16),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
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
                                              fontSize: responsiveSize(11, 14),
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
                    padding: EdgeInsets.all(isDesktop ? 12 : 3.w),
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
                              color: isDark
                                  ? Colors.grey[900]
                                  : const Color(0xFFF5F7FB),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: TextField(
                              controller: _messageController,
                              enabled: !isSending,
                              decoration: InputDecoration(
                                hintText: 'Tulis pesan...',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: isDesktop ? 16 : 4.w,
                                  vertical: isDesktop ? 12 : 1.5.h,
                                ),
                              ),
                              style:
                                  TextStyle(fontSize: responsiveSize(11, 14)),
                              minLines: 1,
                              maxLines: 3,
                            ),
                          ),
                        ),
                        SizedBox(width: isDesktop ? 8 : 2.w),
                        GestureDetector(
                          onTap: isSending ? null : () => _sendMessage(context),
                          child: Container(
                            width: isDesktop ? 44 : 11.w,
                            height: isDesktop ? 44 : 11.w,
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
                              child: isSending
                                  ? SizedBox(
                                      width: isDesktop ? 20 : 5.w,
                                      height: isDesktop ? 20 : 5.w,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      Icons.send_rounded,
                                      color: Colors.white,
                                      size: responsiveSize(16, 20),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
