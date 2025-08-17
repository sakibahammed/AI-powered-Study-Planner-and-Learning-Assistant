import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/settings_screen.dart';

class GreetingSection extends StatefulWidget {
  @override
  _GreetingSectionState createState() => _GreetingSectionState();
}

class _GreetingSectionState extends State<GreetingSection> {
  String userName = 'User';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userData.exists && userData.data()?['firstName'] != null) {
          setState(() {
            userName = userData.data()!['firstName'];
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Method to refresh username - can be called from parent widget
  void refreshUserName() {
    _loadUserName();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onLongPress: () async {
            // Navigate to settings and refresh username when returning
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen()),
            );
            // Refresh username when returning from settings
            _loadUserName();
          },
          child: CircleAvatar(
            backgroundColor: Colors.orange,
            radius: 24,
            child: Icon(Icons.person, color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Text.rich(
          TextSpan(
            text: 'Hello ',
            style: TextStyle(fontSize: 20, color: Colors.grey),
            children: [
              TextSpan(
                text: isLoading ? '...' : '$userName!',
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
