import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SupabaseClient
  supabase; // supabase client instance to make queries inside the bloc
  // Live stream subscription listens to real - time updates
  StreamSubscription<List<Map<String, dynamic>>>? messagesSubscription;
  // temp list stores all messages in memory to avoid refetching
  final List<Chat> messageCache = [];
  // Sender and Reciever IDs
  String? recipientId;
  String? currentUserId;

  ChatBloc({required this.supabase}) : super(ChatInitial()) {
    // Event StartPrivateChat handled by startPrivateChatMethod
    on<StartPrivateChat>(startPrivateChatMethod);
    // Event SendMessage handled by sendMessageMethod
    on<SendMessage>(sendMessageMethod);
  }

  FutureOr<void> startPrivateChatMethod(
    StartPrivateChat event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading()); // Show loading indicator while messages are loading
    await messagesSubscription
        ?.cancel(); // cancel old chat subscription ro avoid double listening
    messagesSubscription = null;
    // remove all previously stores messages before adding new ones (avoid duplicate messages)
    messageCache.clear();
    recipientId = event.chatPartnerUserId;
    // Get current user's ID .. if null, they're not logged in
    final authId = supabase.auth.currentUser?.id;
    if (authId == null) {
      emit(ErrorMessage(errorMessage: "Not authenticated"));
      return;
    }

    // query for row of data or null
    final recordResults = await supabase
        .from('users') // from this table
        .select('id') // column to retrieve from the table
        .eq('auth_id', authId) // match user record for whoever is logged in
        .maybeSingle(); // return row if found, null otherwise

    currentUserId = recordResults?['id'] as String?;
    if (currentUserId == null || recipientId == null) {
      emit(ErrorMessage(errorMessage: "User mapping failed"));
      return;
    }

    final me = currentUserId!;
    final reciever = recipientId!;

    // Get all messages from DB
    try {
      final initialRows = await supabase
          .from('messages')
          .select()
          .order(
            'created_at',
            ascending: true,
          ); // order messages from oldest to newest

      final initialMessages =
          (initialRows as List) // Supabase response = list of rows
              .where((messages) {
                final row = messages as Map<String, dynamic>;
                final sentFromMe = row['sender_id'] as String?; // I sent it
                final sentToMe =
                    (row['receiver_id'] ?? row['reciever_id'])
                        as String?; // or they sent it
                return (sentFromMe == me && sentToMe == reciever) ||
                    (sentFromMe == reciever && sentToMe == me);
              })
              // convert each row to Chat object
              .map(
                (messages) => Chat.fromJson(messages as Map<String, dynamic>),
              )
              .toList()
            ..sort(
              (a, b) => a.createdAt.compareTo(b.createdAt),
            ); // appear in correct order by timestamp

      messageCache
        ..clear()
        ..addAll(initialMessages);

      emit(MessagesLoaded(messages: List<Chat>.from(messageCache)));
    } catch (e) {
      emit(ErrorMessage(errorMessage: e.toString()));
    }

    // create real time stream for messages table in DB
    final stream = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true);
    // listen & update UI
    emit.forEach<List<Map<String, dynamic>>>(
      stream,
      onData: (rows) {
        // Filter here since .or() isn’t supported for streams
        final filtered =
            rows
                .where((row) {
                  final sent = row['sender_id'] as String?;
                  final recieved =
                      (row['receiver_id'] ?? row['reciever_id']) as String?;
                  // Include BOTH directions (me→peer OR peer→me)
                  return (sent == me && recieved == reciever) ||
                      (sent == reciever && recieved == me);
                })
                .map((row) => Chat.fromJson(row))
                .toList()
              ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

        messageCache
          ..clear()
          ..addAll(filtered);

        return MessagesLoaded(messages: List<Chat>.from(messageCache));
      },
      onError: (error, _) => ErrorMessage(errorMessage: error.toString()),
    );
  }

  // handler for SendMessage event
  FutureOr<void> sendMessageMethod(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    final me = currentUserId;
    final chatBuddy = recipientId;
    if (me == null) {
      emit(ErrorMessage(errorMessage: "Not authenticated"));
      return;
    }
    if (chatBuddy == null || chatBuddy.isEmpty) {
      emit(ErrorMessage(errorMessage: "Invalid chat partner id"));
      return;
    }
    // trim white spaces, ignore if empty
    final text = event.message.trim();
    if (text.isEmpty) return;

    try {
      // try to insert new row in messages table
      await supabase.from('messages').insert({
        'sender_id': me,
        'reciever_id': chatBuddy,
        'content': text,
      });
    } catch (e) {
      emit(ErrorMessage(errorMessage: 'Cannot send message: $e'));
    }
  }

  @override
  Future<void> close() async {
    await messagesSubscription?.cancel();
    return super.close();
  }
}
