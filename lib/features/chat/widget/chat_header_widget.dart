import 'package:flutter/material.dart';

class ChatHeaderWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  const ChatHeaderWidget({
    super.key,
    this.title = 'Title',
    this.subtitle = 'Names',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        Text(
          subtitle,
          maxLines: 1,
          style: const TextStyle(fontSize: 13, color: Colors.white),
        ),
      ],
    );
  }
}
