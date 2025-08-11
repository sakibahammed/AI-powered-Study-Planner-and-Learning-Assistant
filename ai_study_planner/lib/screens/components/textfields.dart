import 'package:flutter/material.dart';

class MyTextFields extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  final TextAlign alignment;

  const MyTextFields({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: SizedBox(
        height: 50,
        child: TextField(
          style: TextStyle(color: Color.fromARGB(255, 114, 114, 114)),
          controller: controller,
          obscureText: obscureText,
          textAlign: alignment,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color.fromARGB(0, 255, 255, 255)),
            ),
            fillColor: Color(0x82FFFFFF),
            filled: true,
            //hintText: hintText,
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFFFFFFF)),
            ),
            hintText: hintText,
            hintStyle: TextStyle(color: Color(0xFF999999), fontSize: 20),
          ),
        ),
      ),
    );
  }
}