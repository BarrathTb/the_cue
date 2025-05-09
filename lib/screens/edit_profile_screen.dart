import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../models/user.dart' as app_user; // Alias to avoid conflict
import '../services/user_service.dart';

final Logger _logger = Logger();

class EditProfileScreen extends StatefulWidget {
  final app_user.User currentUser;

  const EditProfileScreen({super.key, required this.currentUser});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserService _userService = UserService();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _profileImageUrlController =
      TextEditingController();
  bool _notificationsEnabled = false;
  String _selectedTheme = 'system'; // Default theme
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _displayNameController.text = widget.currentUser.displayName;
    _profileImageUrlController.text = widget.currentUser.profileImageUrl ?? '';
    _notificationsEnabled = widget.currentUser.settings.notifications;
    _selectedTheme = widget.currentUser.settings.theme;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _profileImageUrlController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedSettings = app_user.UserSettings(
        notifications: _notificationsEnabled,
        theme: _selectedTheme,
      );

      final updatedUser = app_user.User(
        id: widget.currentUser.id,
        email: widget.currentUser.email,
        displayName: _displayNameController.text.trim(),
        profileImageUrl: _profileImageUrlController.text.trim().isEmpty
            ? null
            : _profileImageUrlController.text.trim(),
        role: widget.currentUser.role,
        createdAt: widget.currentUser.createdAt,
        spotifyConnected: widget.currentUser.spotifyConnected,
        settings: updatedSettings,
      );

      await _userService.updateUser(updatedUser);

      // Update Firebase Auth profile (optional, but good practice)
      await FirebaseAuth.instance.currentUser
          ?.updateDisplayName(_displayNameController.text.trim());

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      if (!mounted) return;
      Navigator.pop(context); // Go back to ProfileScreen
    } catch (e) {
      _logger.e('Error updating profile: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF161616),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Display Name',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _displayNameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter your display name',
                hintStyle: const TextStyle(color: Colors.white60),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Profile Image URL',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _profileImageUrlController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter profile image URL',
                hintStyle: const TextStyle(color: Colors.white60),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Enable Notifications',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  activeColor: const Color(0xFFFF9100),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Theme',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                DropdownButton<String>(
                  value: _selectedTheme,
                  dropdownColor: const Color(0xFF212121),
                  style: const TextStyle(color: Colors.white),
                  underline:
                      Container(height: 2, color: const Color(0xFFFF9100)),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedTheme = newValue;
                      });
                    }
                  },
                  items: <String>['system', 'light', 'dark']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9100),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: const Text('Save Changes'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
