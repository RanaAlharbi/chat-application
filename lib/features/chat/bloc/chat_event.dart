part of 'chat_bloc.dart';

@immutable
sealed class ChatEvent {}

// Start a private (DM) chat
class StartPrivateChat extends ChatEvent {
  final String chatPartnerUserId;
  StartPrivateChat(this.chatPartnerUserId);
}

// Send a message in the current private chat
class SendMessage extends ChatEvent {
  final String message; // The text that the user types
  SendMessage(this.message);
}

// Why not add recieve message? will add maybe
