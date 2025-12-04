import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/chat_cubit.dart';
import 'chat_detail_page.dart';

class ChatPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit()..initChat(userId, userName, userEmail),
      child: ChatDetailPage(
        userId: userId,
        userName: userName,
      ),
    );
  }
}
