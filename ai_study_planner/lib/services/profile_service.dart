import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const String _profileImageKey = 'profile_image_path';
  static ProfileService? _instance;
  String? _currentProfileImagePath;

  ProfileService._();

  static ProfileService get instance {
    _instance ??= ProfileService._();
    return _instance!;
  }

  // Initialize the profile service
  Future<void> initialize() async {
    await _loadProfileImagePath();
  }

  // Load profile image path from storage
  Future<void> _loadProfileImagePath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentProfileImagePath = prefs.getString(_profileImageKey);
    } catch (e) {
      print('Error loading profile image path: $e');
      _currentProfileImagePath = null;
    }
  }

  // Save profile image path to storage
  Future<void> _saveProfileImagePath(String? imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (imagePath != null) {
        await prefs.setString(_profileImageKey, imagePath);
      } else {
        await prefs.remove(_profileImageKey);
      }
      _currentProfileImagePath = imagePath;
    } catch (e) {
      print('Error saving profile image path: $e');
    }
  }

  // Get current profile image path
  String? get currentProfileImagePath => _currentProfileImagePath;

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        return await _processAndSaveImage(File(image.path));
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  // Take image with camera
  Future<File?> takeImageWithCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        return await _processAndSaveImage(File(image.path));
      }
      return null;
    } catch (e) {
      print('Error taking image with camera: $e');
      return null;
    }
  }

  // Process and save the selected image
  Future<File?> _processAndSaveImage(File imageFile) async {
    try {
      // Delete old profile image if it exists
      await _deleteCurrentProfileImage();

      // Get app documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory profileDir = Directory('${appDir.path}/profile_images');

      // Create profile images directory if it doesn't exist
      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }

      // Generate unique filename
      final String fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = '${profileDir.path}/$fileName';

      // Copy image to app directory
      final File savedImage = await imageFile.copy(filePath);

      // Save the new path
      await _saveProfileImagePath(filePath);

      print('✅ Profile image saved successfully: $filePath');
      return savedImage;
    } catch (e) {
      print('Error processing and saving image: $e');
      return null;
    }
  }

  // Delete current profile image
  Future<void> _deleteCurrentProfileImage() async {
    if (_currentProfileImagePath != null) {
      try {
        final File currentImage = File(_currentProfileImagePath!);
        if (await currentImage.exists()) {
          await currentImage.delete();
          print('🗑️ Old profile image deleted: $_currentProfileImagePath');
        }
      } catch (e) {
        print('Error deleting old profile image: $e');
      }
    }
  }

  // Remove profile image
  Future<void> removeProfileImage() async {
    try {
      await _deleteCurrentProfileImage();
      await _saveProfileImagePath(null);
      print('🗑️ Profile image removed successfully');
    } catch (e) {
      print('Error removing profile image: $e');
    }
  }

  // Get profile image as File
  File? getProfileImageFile() {
    if (_currentProfileImagePath != null) {
      final File imageFile = File(_currentProfileImagePath!);
      if (imageFile.existsSync()) {
        return imageFile;
      }
    }
    return null;
  }

  // Check if profile image exists
  bool get hasProfileImage => _currentProfileImagePath != null;

  // Get profile image widget
  Widget getProfileImageWidget({
    double size = 100,
    BoxShape shape = BoxShape.circle,
    BoxBorder? border,
  }) {
    if (hasProfileImage) {
      final File? imageFile = getProfileImageFile();
      if (imageFile != null) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: shape, border: border),
          child: ClipOval(
            child: Image.file(
              imageFile,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildDefaultProfileImage(size, shape, border);
              },
            ),
          ),
        );
      }
    }

    return _buildDefaultProfileImage(size, shape, border);
  }

  // Build default profile image
  Widget _buildDefaultProfileImage(
    double size,
    BoxShape shape,
    BoxBorder? border,
  ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: shape,
        color: Colors.grey[300],
        border: border,
      ),
      child: Icon(Icons.person, size: size * 0.5, color: Colors.grey[600]),
    );
  }

  // Get profile image bytes for storage
  Future<Uint8List?> getProfileImageBytes() async {
    try {
      final File? imageFile = getProfileImageFile();
      if (imageFile != null) {
        return await imageFile.readAsBytes();
      }
      return null;
    } catch (e) {
      print('Error reading profile image bytes: $e');
      return null;
    }
  }
}
