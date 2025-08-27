import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import 'login_page.dart';
import 'verification.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Check email verification
            if (snapshot.data!.emailVerified) {
              return DashboardScreen();
            } else {
              return EmailVerificationScreen(user: snapshot.data!);
            }
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
