import 'package:cloud_firestore/cloud_firestore.dart';

class SongRequest {
  final String id;
  final String eventId;
  final String userId;
  final TrackData trackData;
  final String status; // "pending" | "approved" | "denied" | "played"
  final Timestamp requestTime;
  final String? note;
  final int upvotes;
  final List<String> upvotedBy;
  final bool isPriority; // New field for priority status
  final Timestamp? priorityTimestamp; // New field for priority timestamp

  SongRequest({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.trackData,
    required this.status,
    required this.requestTime,
    this.note,
    required this.upvotes,
    required this.upvotedBy,
    this.isPriority = false, // Default to false
    this.priorityTimestamp, // Nullable
  });

  factory SongRequest.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return SongRequest(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      userId: data['userId'] ?? '',
      trackData: TrackData.fromMap(data['trackData'] ?? {}),
      status: data['status'] ?? 'pending',
      requestTime: data['requestTime'] ?? Timestamp.now(),
      note: data['note'],
      upvotes: data['upvotes'] ?? 0,
      upvotedBy: List<String>.from(data['upvotedBy'] ?? []),
      isPriority: data['isPriority'] ?? false,
      priorityTimestamp: data['priorityTimestamp'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'userId': userId,
      'trackData': trackData.toMap(),
      'status': status,
      'requestTime': requestTime,
      'note': note,
      'upvotes': upvotes,
      'upvotedBy': upvotedBy,
      'isPriority': isPriority,
      'priorityTimestamp': priorityTimestamp,
    };
  }
}

class TrackData {
  final String id;
  final String name;
  final String artist;
  final String albumArt;
  final int duration; // in milliseconds
  final String uri; // Added Spotify URI

  TrackData({
    required this.id,
    required this.name,
    required this.artist,
    required this.albumArt,
    required this.duration,
    required this.uri, // Added to constructor
  });

  factory TrackData.fromMap(Map<String, dynamic> map) {
    return TrackData(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      artist: map['artist'] ?? '',
      albumArt: map['albumArt'] ?? '',
      duration: (map['duration'] ?? 0).toInt(),
      uri: map['uri'] ?? '', // Added for URI
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'artist': artist,
      'albumArt': albumArt,
      'duration': duration,
      'uri': uri, // Added for URI
    };
  }
}
