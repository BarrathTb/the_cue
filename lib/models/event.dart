import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String name;
  final String? description;
  final Timestamp startTime;
  final Timestamp endTime;
  final Location location;
  final String djId;
  final String accessCode;
  final bool requestsOpen;
  final String? imageUrl;

  Event({
    required this.id,
    required this.name,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.djId,
    required this.accessCode,
    required this.requestsOpen,
    this.imageUrl,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Event(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      startTime: data['startTime'] ?? Timestamp.now(),
      endTime: data['endTime'] ?? Timestamp.now(),
      location: Location.fromMap(data['location'] ?? {}),
      djId: data['djId'] ?? '',
      accessCode: data['accessCode'] ?? '',
      requestsOpen: data['requestsOpen'] ?? true,
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'startTime': startTime,
      'endTime': endTime,
      'location': location.toMap(),
      'djId': djId,
      'accessCode': accessCode,
      'requestsOpen': requestsOpen,
      'imageUrl': imageUrl,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Event && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Location {
  final String venue;
  final String address;
  final Coordinates coordinates;

  Location({
    required this.venue,
    required this.address,
    required this.coordinates,
  });

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      venue: map['venue'] ?? '',
      address: map['address'] ?? '',
      coordinates: Coordinates.fromMap(map['coordinates'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'venue': venue,
      'address': address,
      'coordinates': coordinates.toMap(),
    };
  }
}

class Coordinates {
  final double lat;
  final double lng;

  Coordinates({
    required this.lat,
    required this.lng,
  });

  factory Coordinates.fromMap(Map<String, dynamic> map) {
    return Coordinates(
      lat: (map['lat'] ?? 0.0).toDouble(),
      lng: (map['lng'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
}
