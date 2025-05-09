import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String displayName;
  final String email;
  final String? profileImageUrl;
  final String role; // "user" | "dj" | "admin"
  final Timestamp createdAt;
  final bool spotifyConnected;
  final UserSettings settings;

  User({
    required this.id,
    required this.displayName,
    required this.email,
    this.profileImageUrl,
    required this.role,
    required this.createdAt,
    required this.spotifyConnected,
    required this.settings,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return User(
      id: doc.id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      role: data['role'] ?? 'user',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      spotifyConnected: data['spotifyConnected'] ?? false,
      settings: UserSettings.fromMap(data['settings'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'role': role,
      'createdAt': createdAt,
      'spotifyConnected': spotifyConnected,
      'settings': settings.toMap(),
    };
  }
}

class UserSettings {
  final bool notifications;
  final String theme;

  UserSettings({
    required this.notifications,
    required this.theme,
  });

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      notifications: map['notifications'] ?? true,
      theme: map['theme'] ?? 'system',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notifications': notifications,
      'theme': theme,
    };
  }
}
