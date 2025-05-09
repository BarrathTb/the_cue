import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../models/user.dart';

final Logger _logger = Logger();

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser({
    required String uid,
    required String email,
    required String displayName,
  }) async {
    try {
      final user = User(
        id: uid,
        email: email,
        displayName: displayName,
        role: 'user', // Default role
        createdAt: Timestamp.now(),
        spotifyConnected: false,
        settings: UserSettings(notifications: true, theme: 'system'),
      );

      await _firestore.collection('users').doc(uid).set(user.toFirestore());
    } catch (e) {
      _logger.e('Error creating user in Firestore: $e');
      rethrow;
    }
  }

  Future<User?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _logger.i('User document exists: ${doc.id}');
        _logger.i('User document data: ${doc.data()}');
        return User.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      _logger.e('Error getting user from Firestore: $e');
      rethrow;
    }
  }

  Future<void> updateUser(User user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .update(user.toFirestore());
    } catch (e) {
      _logger.e('Error updating user in Firestore: $e');
      rethrow;
    }
  }

  // Update a user's role
  Future<void> updateUserRole(String uid, String role) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'role': role,
      });
    } catch (e) {
      _logger.e('Error updating user role in Firestore: $e');
      rethrow;
    }
  }
}
