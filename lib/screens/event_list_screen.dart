import 'package:flutter/material.dart';

import '../models/event.dart';
import '../services/event_service.dart';
import 'event_details_screen.dart'; // Import EventDetailsScreen

class EventListScreen extends StatelessWidget {
  const EventListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EventService eventService = EventService();

    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      appBar: AppBar(
        title: const Text('Available Events'),
        backgroundColor: const Color(0xFF161616),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Event>>(
        stream: eventService.getOpenEvents(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red)),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data ?? [];

          if (events.isEmpty) {
            return const Center(
              child: Text('No open events available.',
                  style: TextStyle(color: Colors.white70)),
            );
          }

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                color: const Color(0xFF212121),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: event.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            event.imageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[700],
                                child: const Icon(Icons.event,
                                    color: Colors.white),
                              );
                            },
                          ),
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[700],
                          child: const Icon(Icons.event, color: Colors.white),
                        ),
                  title: Text(event.name,
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(
                    '${event.location.venue} - ${event.startTime.toDate().toString().split(' ')[0]}', // Display date
                    style: const TextStyle(color: Colors.white70),
                  ),
                  onTap: () {
                    // Navigate to EventDetailsScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailsScreen(event: event),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
