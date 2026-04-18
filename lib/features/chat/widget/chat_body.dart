import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab_supabase/features/chat/bloc/chat_bloc.dart';
import 'package:lab_supabase/features/chat/widget/send_text_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatBody extends StatefulWidget {
  const ChatBody();

  @override
  State<ChatBody> createState() => ChatBodyState();
}

class ChatBodyState extends State<ChatBody> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl =
      ScrollController(); // scroll listview when new message appears

  // get user message, if blank do nothing
  void send(BuildContext context) {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    context.read<ChatBloc>().add(SendMessage(text));
    _textCtrl.clear();

    // wait a bit and auto scroll chat to latest message
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // get your auth id to know which messages are yours
    final me = Supabase.instance.client.auth.currentUser?.id;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  // Show loading indicator if messages are loading
                  if (state is ChatLoading || state is ChatInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Display erros when failed
                  if (state is ErrorMessage) {
                    return Center(child: Text(state.errorMessage));
                  }
                  // if messages loaded, store in msgs
                  if (state is MessagesLoaded) {
                    final msgs = state.messages;
                    // build scrollable list of chat bubbles
                    return ListView.builder(
                      controller: _scrollCtrl,
                      itemCount: msgs.length,
                      itemBuilder: (context, i) {
                        final m = msgs[i];
                        final isMe = m.senderId == me;
                        final bubbleColor =
                            isMe // message sent by me
                            // my messages green bubble and white text, otherwise, white bubble black text
                            ? const Color.fromRGBO(64, 116, 77, 1)
                            : Colors.white;
                        final textColor = isMe ? Colors.white : Colors.black87;

                        // my messages right, otherwise left
                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: bubbleColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            // Message content & time
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.deletedForAll
                                      ? 'Message deleted'
                                      : m.content,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatTime(m.createdAt),
                                  style: TextStyle(
                                    color: textColor.withOpacity(0.8),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            const SizedBox(height: 10),
            SendTextWidget(controller: _textCtrl, onSend: () => send(context)),
          ],
        ),
      ),
    );
  }

  // Convert date time to HH:MM
  String formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
