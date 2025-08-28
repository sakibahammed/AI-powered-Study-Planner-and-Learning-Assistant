import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'auth/auth_page.dart';
import 'services/notification_service.dart';

// Global notification service instance
NotificationService? _notificationService;

// Proper notification initialization with multiple fallbacks
Future<void> _initializeNotificationService() async {
  try {
    print('🔔 Initializing notification service...');

    // Create service instance
    _notificationService = NotificationService();

    // Try to initialize with timeout
    await _notificationService!.initialize().timeout(
      Duration(seconds: 10),
      onTimeout: () {
        print('⚠️ Notification service initialization timed out');
        throw TimeoutException('Notification service initialization timed out');
      },
    );

    print('✅ Notification service initialized successfully');
  } catch (e) {
    print('⚠️ Notification service failed to initialize: $e');
    print('⚠️ App will continue without notifications');

    // Set to null so we know it's not available
    _notificationService = null;
  }
}

void main() async {
  try {
    print('🚀 Starting app initialization...');

    WidgetsFlutterBinding.ensureInitialized();
    print('✅ Flutter binding initialized');

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized');

    FirebaseAuth.instance.setLanguageCode('en');
    print('✅ Firebase Auth configured');

    // Initialize notification service with proper error handling
    await _initializeNotificationService();

    print('🚀 All services initialized, starting app...');
    runApp(const MyApp());
  } catch (error) {
    print('❌ Critical error during app initialization: $error');
    print('❌ App cannot start');

    // Show a simple error screen instead of crashing
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'App Failed to Start',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Error: $error', style: TextStyle(fontSize: 16)),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Try to restart
                    main();
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
