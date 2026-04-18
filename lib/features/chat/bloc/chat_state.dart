part of 'chat_bloc.dart';

@immutable
sealed class ChatState {}

final class ChatInitial extends ChatState {}

// Before Messages are ready
final class ChatLoading extends ChatState {}

// When messages are ready
final class MessagesLoaded extends ChatState {
  final List<Chat> messages; // Entire list of chat items
  MessagesLoaded({required this.messages});
}

// When an error occurs return the error message
final class ErrorMessage extends ChatState {
  final String errorMessage;
  ErrorMessage({required this.errorMessage});
}

// Chat Model that represents one chat messgae
class Chat {
  final String id; // Message PK
  final String senderId;
  final String?
  recieverId; // Nullable because when we use for groups later, it wont have a single reciever
  final String? groupId; // unused in private chat, only in group chat
  final String content;
  final DateTime createdAt;
  final bool deletedForAll; // true if deleted

  Chat({
    required this.id,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.recieverId,
    this.groupId,
    this.deletedForAll = false, // default false
  });

  // factory constructor to build a chat deom supabase row (map)
  factory Chat.fromJson(Map<String, dynamic> json) {
    final reciever = json['reciever_id'] as String?;
    final timeStamp = json['created_at'];
    // return built chat
    return Chat(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      recieverId: reciever,
      groupId: json['group_id'] as String?,
      content: json['content'] as String,
      deletedForAll: (json['deleted_for_all'] as bool?) ?? false,
      createdAt: timeStamp is String
          ? DateTime.parse(timeStamp)
          : DateTime.parse(timeStamp.toString()),
    );
  }
}
