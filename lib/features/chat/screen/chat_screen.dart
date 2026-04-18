import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab_supabase/features/chat/bloc/chat_bloc.dart';
import 'package:lab_supabase/features/chat/widget/chat_body.dart';
import 'package:lab_supabase/features/chat/widget/chat_header_widget.dart';
import 'package:lab_supabase/features/chat/widget/send_text_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatelessWidget {
  final String friendId; // ID of person you're chatting with 
  final String friendName; // Display name
  final String? friendAvatarAsset; // Optional Image 

  const ChatScreen({
    super.key,
    required this.friendId,
    required this.friendName,
    this.friendAvatarAsset,
  });

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return BlocProvider(
      // Immediately load chat hiistory for friendId
      create: (_) => ChatBloc(supabase: supabase)..add(StartPrivateChat(friendId)),
      child: Scaffold(
         
        appBar: AppBar(
          leadingWidth: 100, // space for avatar and previous button
          leading: SizedBox(
            width: 100,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const BackButton(color: Colors.white),
                // Will change to display initials 
                CircleAvatar(
                  radius: 20,
                  backgroundImage: friendAvatarAsset != null
                      ? AssetImage(friendAvatarAsset!)
                      : const AssetImage('assests/images/profile.png'),
                ),
              ],
            ),
          ),
          backgroundColor: const Color.fromRGBO(64, 116, 77, 1),
          // Displau user's name + Private chat 
          title: ChatHeaderWidget(title: friendName, subtitle: 'Private chat'),
        ),
        body: ChatBody(),
      ),
    );
  }
}

