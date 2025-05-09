import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../models/user.dart'
    as app_user; // Alias to avoid conflict with firebase_auth.User
import '../services/user_service.dart';
import 'edit_profile_screen.dart'; // Import EditProfileScreen

final Logger _logger = Logger();

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  app_user.User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      try {
        final userProfile = await _userService.getUser(firebaseUser.uid);
        setState(() {
          _currentUser = userProfile;
          _isLoading = false;
        });
      } catch (e) {
        _logger.e('Error loading user profile: $e');
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      // Handle case where user is not logged in (shouldn't happen if navigated correctly)
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF161616),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF161616),
        body: Center(
          child: Text(
            'User profile not found.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF161616),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _currentUser!.profileImageUrl != null
                    ? NetworkImage(_currentUser!.profileImageUrl!)
                    : null,
                child: _currentUser!.profileImageUrl == null
                    ? const Icon(Icons.person, size: 50, color: Colors.white70)
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Display Name: ${_currentUser!.displayName}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Email: ${_currentUser!.email}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Role: ${_currentUser!.role}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to EditProfileScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditProfileScreen(currentUser: _currentUser!),
                    ),
                  ).then((_) {
                    // Refresh profile data when returning from EditProfileScreen
                    _loadUserProfile();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9100),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Edit Profile'),
              ),
            ),
            // TODO: Add more profile details and edit options
          ],
        ),
      ),
    );
  }
}
