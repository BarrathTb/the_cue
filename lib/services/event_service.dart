import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../models/event.dart';

final Logger _logger = Logger();

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new event
  Future<void> createEvent(Event event) async {
    try {
      await _firestore
          .collection('events')
          .doc(event.id)
          .set(event.toFirestore());
    } catch (e) {
      _logger.e('Error creating event: $e');
      rethrow;
    }
  }

  // Get a single event by ID
  Future<Event?> getEvent(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (doc.exists) {
        return Event.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      _logger.e('Error getting event: $e');
      rethrow;
    }
  }

  // Get a stream of events for a specific DJ
  Stream<List<Event>> getEventsForDj(String djId) {
    return _firestore
        .collection('events')
        .where('djId', isEqualTo: djId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());
  }

  // Get a stream of all open events
  Stream<List<Event>> getOpenEvents() {
    return _firestore
        .collection('events')
        .where('requestsOpen', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());
  }

  // Update an existing event
  Future<void> updateEvent(Event event) async {
    try {
      await _firestore
          .collection('events')
          .doc(event.id)
          .update(event.toFirestore());
    } catch (e) {
      _logger.e('Error updating event: $e');
      rethrow;
    }
  }

  // Delete an event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      _logger.e('Error deleting event: $e');
      rethrow;
    }
  }
}
