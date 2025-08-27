import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/login_page.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  File? _selectedImage;
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Load user data from Firestore
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userData.exists && userData.data()?['profileImage'] != null) {
        setState(() {
          _imageUrl = userData.data()!['profileImage'];
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedImage = File(result.files.single.path!);
          _isLoading = true;
        });

        // Here you would typically upload to Firebase Storage
        // For now, we'll just save the local file path
        await _saveImageToFirestore();

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _saveImageToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _selectedImage != null) {
      // In a real app, you'd upload to Firebase Storage first
      // For now, we'll save the local path
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'profileImage': _selectedImage!.path},
      );
    }
  }

  Future<void> _showEditProfileDialog() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Get current user data
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    String firstName = userData.data()?['firstName'] ?? '';
    String lastName = userData.data()?['lastName'] ?? '';

    final firstNameController = TextEditingController(text: firstName);
    final lastNameController = TextEditingController(text: lastName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .update({
                        'firstName': firstNameController.text.trim(),
                        'lastName': lastNameController.text.trim(),
                      });

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Profile updated successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating profile: $e')),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error logging out: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.deepOrangeAccent,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (_imageUrl != null
                                    ? NetworkImage(_imageUrl!) as ImageProvider
                                    : null),
                          child: _selectedImage == null && _imageUrl == null
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        if (_isLoading)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: .5),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Tap to change profile picture',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),

            // Settings Options
            _buildSettingItem(
              icon: Icons.person,
              title: 'Edit Profile',
              subtitle: 'Change your personal information',
              onTap: () {
                _showEditProfileDialog();
              },
            ),

            _buildSettingItem(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Manage your notification preferences',
              onTap: () {
                // TODO: Implement notifications settings
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Notifications settings coming soon!'),
                  ),
                );
              },
            ),

            _buildSettingItem(
              icon: Icons.security,
              title: 'Privacy & Security',
              subtitle: 'Manage your privacy settings',
              onTap: () {
                // TODO: Implement privacy settings
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Privacy settings coming soon!')),
                );
              },
            ),

            _buildSettingItem(
              icon: Icons.help,
              title: 'Help & Support',
              subtitle: 'Get help and contact support',
              onTap: () {
                // TODO: Implement help & support
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Help & Support coming soon!')),
                );
              },
            ),

            SizedBox(height: 20),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
