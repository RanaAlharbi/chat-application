import 'package:flutter/material.dart';
import 'package:lab_supabase/features/chat/screen/chat_screen.dart';
import 'package:lab_supabase/theme/app_color.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsersListScreen extends StatelessWidget {
  const UsersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final myAuthId = supabase.auth.currentUser?.id; // Use your id to exclude yourself from chat friends 
    // Change UI everytime user table changes in supabase 
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase
          .from('users')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: true), // dort users by when signed up (oldest to newest)
      builder: (context, snapshot) {
        // While waiting show loading indicator 
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        // If error show error message
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // snapshot.data = list of users from supabase 
        final rows = snapshot.data ?? const [];
        // exclude myself by auth_id
        final people = rows.where((user) => user['auth_id'] != myAuthId).toList();
        if (people.isEmpty) {
          return const Center(child: Text('No users yet.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: people.length,
    
          itemBuilder: (context, i) {
            final user = people[i];
            final friendAuthId = (user['auth_id'] as String?) ?? '';
            final email =
                (user['username'] as String?) ??
                'User'; 
            final avatarUrl = user['avatar_url'] as String?;

            void openChat() {
              if (friendAuthId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invalid user ID — cannot start chat.'),
                  ),
                );
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    friendId: friendAuthId, 
                    friendName: email, 
                  ),
                ),
              );
            }

            return ListTile(
              leading: CircleAvatar(
              backgroundColor: AppColor.darkgreen.withAlpha(50),
              radius: 25,
                backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                    ? NetworkImage(avatarUrl)
                    : null,
                child: (avatarUrl == null || avatarUrl.isEmpty)
                    ? Text(email.isNotEmpty ? email[0].toUpperCase() : '?')
                    : null,
              ),
              title: Text(
                email.split('@').first.trim(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: const Text('Tap to chat'),
             
              onTap: openChat,
            );
          },
        );
      },
    );
  }
}
