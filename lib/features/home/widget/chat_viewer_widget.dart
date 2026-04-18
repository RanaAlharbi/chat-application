import 'package:flutter/material.dart';
import 'package:lab_supabase/features/chat/screen/chat_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatViewerWidget extends StatefulWidget {
  const ChatViewerWidget({super.key});

  @override
  State<ChatViewerWidget> createState() => _ChatViewerWidgetState();
}

class _ChatViewerWidgetState extends State<ChatViewerWidget> {
  final supabase = Supabase.instance.client;
  String? myUserId; 

  @override
  void initState() {
    super.initState();
    resolveMyUserId();
  }

  Future<void> resolveMyUserId() async {
    final authId = supabase.auth.currentUser?.id;
    if (authId == null) return;
    final row = await supabase
        .from('users')
        .select('id')
        .eq('auth_id', authId)
        .maybeSingle();
    setState(() => myUserId = row?['id'] as String?);
  }
  // Last Message between users 
  Future<Map<String, dynamic>?> lastMsg(String me, String peer) async {
    final meToFriend = await supabase
        .from('messages')
        .select()
        .eq('sender_id', me)
        .eq('reciever_id', peer)
        .order('created_at', ascending: false)
        .limit(1);

    final friendToMe = await supabase
        .from('messages')
        .select()
        .eq('sender_id', peer)
        .eq('reciever_id', me)
        .order('created_at', ascending: false)
        .limit(1);

    Map<String, dynamic>? a = (meToFriend is List && meToFriend.isNotEmpty)
        ? meToFriend.first as Map<String, dynamic>
        : null;
    Map<String, dynamic>? b = (friendToMe is List && friendToMe.isNotEmpty)
        ? friendToMe.first as Map<String, dynamic>
        : null;

    if (a == null && b == null) return null;
    if (a == null) return b;
    if (b == null) return a;

    final at = DateTime.parse(a['created_at'].toString());
    final bt = DateTime.parse(b['created_at'].toString());
    return at.isAfter(bt) ? a : b;
  }

  @override
  Widget build(BuildContext context) {
    if (myUserId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final myAuthId = supabase.auth.currentUser?.id;
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase
          .from('users')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: true),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }

        final all = snap.data ?? const [];
        final people = all.where((users) => users['auth_id'] != myAuthId).toList();
        if (people.isEmpty) {
          return const Center(child: Text('No users yet.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: people.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final user = people[i];
            final peerUserId = user['id'] as String; // public.users.id
            final email = (user['username'] as String?) ?? 'User';
            final avatarUrl = user['avatar_url'] as String?;

            return FutureBuilder<Map<String, dynamic>?>(
              future: lastMsg(myUserId!, peerUserId),
              builder: (context, lastSnap) {
                String subtitle = 'Start a conversation';
                if (lastSnap.hasData && lastSnap.data != null) {
                  final m = lastSnap.data!;
                  final content = (m['content'] as String?) ?? '';
                  final dt = DateTime.tryParse(m['created_at'].toString());
                  final hhmm = dt == null
                      ? ''
                      : ' • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                  subtitle = (content.isEmpty ? 'Message' : content);
                  if (subtitle.length > 40)
                    subtitle = '${subtitle.substring(0, 40)}…';
                  subtitle += hhmm;
                }

                void openChat() {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          ChatScreen(friendId: peerUserId, friendName: email),
                    ),
                  );
                }

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: (avatarUrl == null || avatarUrl.isEmpty)
                        ? Text(email.isNotEmpty ? email[0].toUpperCase() : '?')
                        : null,
                  ),
                  title: Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: openChat,
                  ),
                  onTap: openChat,
                );
              },
            );
          },
        );
      },
    );
  }
}
