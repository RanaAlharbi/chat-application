import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab_supabase/features/home/bloc/home_bloc.dart';

class GroupChatScreen extends StatelessWidget {
  final String groupId;
  final String groupName;

  const GroupChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  Widget build(BuildContext context) {
    // Make sure we’re listening to this group
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeBloc>().add(LoadGroupMessages(groupId));
    });

    final textCtrl = TextEditingController();

    void send() {
      final text = textCtrl.text.trim();
      if (text.isEmpty) return;
      context.read<HomeBloc>().add(
        SendGroupMessage(groupId: groupId, content: text),
      );
      textCtrl.clear();
    }

    final meAuthId = context.read<HomeBloc>().supabase.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
        backgroundColor: const Color.fromRGBO(64, 116, 77, 1),
      ),
      backgroundColor: const Color.fromRGBO(218, 229, 221, 1),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state is GroupLoading && state is! GroupMessagesLoaded) {
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
                    padding: const EdgeInsets.all(12),
                    itemCount: msgs.length,
                    itemBuilder: (_, i) {
                      final m = msgs[i];
                      // m.senderId is public.users.id
                      final isMine = m.senderId == meAuthId; // best-effort
                      final time =
                          '${m.createdAt.hour.toString().padLeft(2, '0')}:${m.createdAt.minute.toString().padLeft(2, '0')}';

                      return Align(
                        alignment: isMine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMine
                                ? const Color.fromRGBO(64, 116, 77, 1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.content,
                                style: TextStyle(
                                  color: isMine ? Colors.white : Colors.black87,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                time,
                                style: TextStyle(
                                  color: isMine
                                      ? Colors.white70
                                      : Colors.black54,
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
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Message group…',
                      filled: true,
                      fillColor: Color.fromRGBO(255, 255, 255, 0.7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                    ),
                    onSubmitted: (_) => send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Color.fromRGBO(64, 116, 77, 1),
                  ),
                  onPressed: send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
