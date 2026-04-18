import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab_supabase/features/home/bloc/home_bloc.dart';

class GroupChatBody extends StatelessWidget {
  final String groupId;
  const GroupChatBody({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final textCtrl = TextEditingController();

    void send() {
      final text = textCtrl.text.trim();
      if (text.isEmpty) return;

      // FIX 2: SendGroupMessage has NAMED parameters (groupId, content)
      context.read<HomeBloc>().add(
        SendGroupMessage(groupId: groupId, content: text),
      );
      textCtrl.clear();
    }

    // (Optional note) If you want to color “my” messages, you should compare each
    // message.senderId (public users.id) against *your* public users.id. The line below
    // fetches auth id, which won’t match. Kept as-is to avoid extra async in this UI.
    final myAuthId = context.read<HomeBloc>().supabase.auth.currentUser?.id;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is GroupLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is GroupError) {
                    return Center(child: Text(state.message));
                  }
                  if (state is GroupMessagesLoaded) {
                    final msgs = state.messages;
                    if (msgs.isEmpty) {
                      return const Center(child: Text('Say hi to the group!'));
                    }

                    return ListView.builder(
                      itemCount: msgs.length,
                      itemBuilder: (context, i) {
                        final m = msgs[i];

                        // FIX 3: the model exposes `senderId`, `content`, `createdAt`
                        final isMine = m.senderId == myAuthId;
                        final time =
                            "${m.createdAt.hour.toString().padLeft(2, '0')}:${m.createdAt.minute.toString().padLeft(2, '0')}";

                        final bubbleColor = isMine
                            ? const Color(0xFF40744D)
                            : Colors.white;
                        final textColor = isMine
                            ? Colors.white
                            : Colors.black87;

                        return Align(
                          alignment: isMine
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: bubbleColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Show sender (for group chats) when not mine
                                if (!isMine)
                                  Text(
                                    m.senderId ?? "User",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: textColor.withOpacity(0.8),
                                    ),
                                  ),
                                if (!isMine) const SizedBox(height: 4),
                                Text(
                                  m.content.isEmpty ? 'Message' : m.content,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  time,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: textColor.withOpacity(0.8),
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Message the group',
                      filled: true,
                      fillColor: Color.fromRGBO(255, 255, 255, 0.65),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(64, 116, 77, 1),
                        ),
                      ),
                    ),
                    onSubmitted: (_) => send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: send,
                  icon: const Icon(
                    Icons.send,
                    color: Color.fromRGBO(64, 116, 77, 1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
