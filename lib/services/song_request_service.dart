import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../models/song_request.dart';
import '../models/track.dart'; // Assuming Track model is used for trackData

final Logger _logger = Logger();

class SongRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new song request
  Future<void> createSongRequest({
    required String eventId,
    required String userId,
    required Track track, // Use the existing Track model
    String? note,
  }) async {
    try {
      final newRequestRef = _firestore.collection('songRequests').doc();
      final songRequest = SongRequest(
        id: newRequestRef.id,
        eventId: eventId,
        userId: userId,
        trackData: TrackData(
          id: track.id,
          name: track.title,
          artist: track.artist,
          albumArt: track.imageUrl,
          duration: track.duration, // Use the correct duration property
          uri: track.uri, // Pass the track URI
        ),
        status: 'pending', // Initial status
        requestTime: Timestamp.now(),
        note: note,
        upvotes: 0,
        upvotedBy: [],
        isPriority: false, // Initialize new field
        priorityTimestamp: null, // Initialize new field
      );

      await newRequestRef.set(songRequest.toFirestore());
    } catch (e) {
      _logger.e('Error creating song request: $e');
      rethrow;
    }
  }

  // Get a stream of song requests for a specific event
  Stream<List<SongRequest>> getSongRequestsForEvent(String eventId) {
    return _firestore
        .collection('songRequests')
        .where('eventId', isEqualTo: eventId)
        .orderBy('isPriority', descending: true)
        .orderBy('priorityTimestamp',
            descending: false) // Ascending for timestamp
        .orderBy('upvotes', descending: true)
        .orderBy('requestTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SongRequest.fromFirestore(doc))
            .toList());
  }

  // Get a stream of song requests for a specific event filtered by status
  Stream<List<SongRequest>> getSongRequestsForEventByStatus(
      String eventId, String status) {
    return _firestore
        .collection('songRequests')
        .where('eventId', isEqualTo: eventId)
        .where('status', isEqualTo: status)
        .orderBy('isPriority', descending: true)
        .orderBy('priorityTimestamp',
            descending: false) // Ascending for timestamp
        .orderBy('upvotes', descending: true)
        .orderBy('requestTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SongRequest.fromFirestore(doc))
            .toList());
  }

  // Update the status of a song request
  Future<void> updateSongRequestStatus(String requestId, String status) async {
    try {
      await _firestore.collection('songRequests').doc(requestId).update({
        'status': status,
      });
    } catch (e) {
      _logger.e('Error updating song request status: $e');
      rethrow;
    }
  }

  // Add or remove an upvote for a song request
  Future<void> toggleUpvote(String requestId, String userId) async {
    try {
      final requestRef = _firestore.collection('songRequests').doc(requestId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(requestRef);
        final data = snapshot.data() as Map<String, dynamic>;
        List<String> upvotedBy = List<String>.from(data['upvotedBy'] ?? []);

        if (upvotedBy.contains(userId)) {
          // User has already upvoted, remove upvote
          upvotedBy.remove(userId);
        } else {
          // User has not upvoted, add upvote
          upvotedBy.add(userId);
        }

        transaction.update(requestRef, {
          'upvotes': upvotedBy.length,
          'upvotedBy': upvotedBy,
        });
      });
    } catch (e) {
      _logger.e('Error toggling upvote: $e');
      rethrow;
    }
  }

  // Delete a song request
  Future<void> deleteSongRequest(String requestId) async {
    try {
      await _firestore.collection('songRequests').doc(requestId).delete();
    } catch (e) {
      _logger.e('Error deleting song request: $e');
      rethrow;
    }
  }

  // Update a song request to be a priority request
  Future<void> updateRequestPriority(String requestId) async {
    try {
      await _firestore.collection('songRequests').doc(requestId).update({
        'isPriority': true,
        'priorityTimestamp':
            FieldValue.serverTimestamp(), // Use server timestamp
      });
    } catch (e) {
      _logger.e('Error updating request priority: $e');
      rethrow;
    }
  }
}
