import 'package:flutter/material.dart';

class SendTextWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const SendTextWidget({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Message',
              filled: true,
              fillColor: Color.fromRGBO(255, 255, 255, 0.65),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                borderSide: BorderSide(color: Color.fromRGBO(64, 116, 77, 1)),
              ),
            ),
            onSubmitted: (_) => onSend(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onSend,
          icon: const Icon(Icons.send, color: Color.fromRGBO(64, 116, 77, 1)),
        ),
      ],
    );
  }
}
