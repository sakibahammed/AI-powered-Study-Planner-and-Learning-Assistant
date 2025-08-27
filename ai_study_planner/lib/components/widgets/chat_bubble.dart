import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final Color bubbleColor;
  final Color fontColor;
  final CrossAxisAlignment alignment;

  const ChatBubble({
    super.key,
    required this.message,
    required this.bubbleColor,
    required this.fontColor,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(
                alignment == CrossAxisAlignment.start ? 0 : 30,
              ),
              topRight: Radius.circular(
                alignment == CrossAxisAlignment.end ? 0 : 30,
              ),
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
            gradient: LinearGradient(
              colors: [bubbleColor.withValues(alpha: 0.9), bubbleColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            message,
            style: TextStyle(
              color: fontColor,
              fontSize: 17,
              height: 1.3,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
