import 'package:ai_study_planner/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dashboard UI',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 129, 24, 148),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.purpleAccent,
        ),
        textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.purple)),
      ),
      home: DashboardScreen(),
    );
  }
}
