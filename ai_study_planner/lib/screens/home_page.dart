import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'components/mybuttons.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  void logOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6EAD8),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('LOGGED IN AS: ${user.email!}'),
              SizedBox(height: 20),
              MyButtons(
                color: Color(0xFFFD6967),
                label: 'Log out',
                onTap: logOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}