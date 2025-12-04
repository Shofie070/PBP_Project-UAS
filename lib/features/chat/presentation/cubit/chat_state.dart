import 'package:equatable/equatable.dart';
import '../../../../model/model.dart';

enum ChatStatus { initial, loading, success, failure, sending }

class ChatState extends Equatable {
  final ChatStatus status;
  final ChatRoom? chatRoom;
  final String? errorMessage;

  const ChatState({
    this.status = ChatStatus.initial,
    this.chatRoom,
    this.errorMessage,
  });

  ChatState copyWith({
    ChatStatus? status,
    ChatRoom? chatRoom,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      chatRoom: chatRoom ?? this.chatRoom,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, chatRoom, errorMessage];
}
