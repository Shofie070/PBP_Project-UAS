import 'package:flutter_bloc/flutter_bloc.dart';

import '../chat_service.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatService _chatService = ChatService();

  ChatCubit() : super(const ChatState());

  Future<void> initChat(
      String userId, String userName, String userEmail) async {
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      final room =
          await _chatService.getOrCreateBotChat(userId, userName, userEmail);
      emit(state.copyWith(status: ChatStatus.success, chatRoom: room));
    } catch (e) {
      emit(state.copyWith(
          status: ChatStatus.failure, errorMessage: 'Gagal memuat chat'));
    }
  }

  Future<void> sendMessage(String userId, String userName, String text) async {
    if (state.chatRoom == null) return;
    final roomId = state.chatRoom!.id;

    emit(state.copyWith(status: ChatStatus.sending));
    try {
      await _chatService.sendMessage(roomId, userId, userName, text);

      // Reload
      final updated = await _chatService.getChatRoom(userId, roomId);
      if (updated != null) {
        emit(state.copyWith(status: ChatStatus.success, chatRoom: updated));
      }

      // Simulate reply
      if (roomId.startsWith('bot_')) {
        await _chatService.sendBotReply(roomId, text);
      } else {
        await Future.delayed(const Duration(seconds: 1));
        await _chatService.sendAdminReply(roomId,
            'Terima kasih atas pesan Anda. Tim support kami akan segera membantu!');
      }

      final updatedAgain = await _chatService.getChatRoom(userId, roomId);
      if (updatedAgain != null) {
        emit(
            state.copyWith(status: ChatStatus.success, chatRoom: updatedAgain));
      }
    } catch (e) {
      emit(state.copyWith(
          status: ChatStatus.failure, errorMessage: 'Gagal mengirim pesan'));
      // Revert to success to show previous messages? Or keep failure?
      // Usually we want to show the error but keep the chat visible.
      // But status failure might hide the chat if UI checks status.
      // Better to have a separate error field and keep status success or use a transient error state.
      // For now, I'll emit success with error message? No, that's confusing.
      // I'll emit failure, but UI should handle failure by showing snackbar and keeping content if chatRoom is not null.
    }
  }
}
