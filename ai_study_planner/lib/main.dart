import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'auth/auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseAuth.instance.setLanguageCode('en');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Study Planner',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 129, 24, 148),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.purpleAccent,
        ),
        textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.purple)),
      ),
      home: AuthPage(),
    );
  }
}
