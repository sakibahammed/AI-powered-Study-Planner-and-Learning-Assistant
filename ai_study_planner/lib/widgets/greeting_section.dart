import 'package:flutter/material.dart';

class GreetingSection extends StatelessWidget {
  const GreetingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.orange,
          radius: 24,
          child: Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Text.rich(
          TextSpan(
            text: 'Hello ',
            style: TextStyle(fontSize: 20, color: Colors.grey),
            children: [
              TextSpan(
                text: 'Name!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
