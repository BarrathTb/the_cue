import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../models/event.dart';
import '../models/song_request.dart';
import '../services/event_service.dart';
import '../services/song_request_service.dart';
import '../services/spotify_service.dart'; // Import SpotifyService

final Logger _logger = Logger();

class DjDashboardScreen extends StatefulWidget {
  const DjDashboardScreen({super.key});

  @override
  State<DjDashboardScreen> createState() => _DjDashboardScreenState();
}

class _DjDashboardScreenState extends State<DjDashboardScreen> {
  String _currentView = 'pending'; // 'pending' or 'played'
  Event? _selectedEvent; // Currently selected event

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF161616),
        body: Center(
          child: Text(
            'Please log in to view the DJ Dashboard.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final EventService eventService = EventService();
    final SongRequestService songRequestService = SongRequestService();

    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      appBar: AppBar(
        title: const Text('DJ Dashboard'),
        backgroundColor: const Color(0xFF161616),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Event>>(
        stream: eventService.getEventsForDj(user.uid),
        builder: (context, eventSnapshot) {
          if (eventSnapshot.hasError) {
            return Center(
              child: Text('Error loading events: ${eventSnapshot.error}',
                  style: const TextStyle(color: Colors.red)),
            );
          }

          if (eventSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = eventSnapshot.data ?? [];

          if (events.isEmpty) {
            return const Center(
              child: Text('You are not assigned to any events.',
                  style: TextStyle(color: Colors.white70)),
            );
          }

          // If events are loaded and no event is selected, select the first one
          // Removed automatic selection of the first event. User must select from dropdown.

          // If events are loaded and no event is selected, select the first one
          if (events.isNotEmpty && _selectedEvent == null) {
            _selectedEvent = events.first;
          }

          if (_selectedEvent == null) {
            return const Center(
              child: Text('Select an event to view requests.',
                  style: TextStyle(color: Colors.white70)),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButton<Event>(
                  value: _selectedEvent,
                  dropdownColor: const Color(0xFF212121),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  underline:
                      Container(height: 2, color: const Color(0xFFFF9100)),
                  onChanged: (Event? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedEvent = newValue;
                      });
                    }
                  },
                  items: events.map<DropdownMenuItem<Event>>((Event event) {
                    return DropdownMenuItem<Event>(
                      value: event,
                      child: Text(event.name),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SegmentedButton<String>(
                  segments: const <ButtonSegment<String>>[
                    ButtonSegment<String>(
                        value: 'pending', label: Text('Pending/Approved')),
                    ButtonSegment<String>(
                        value: 'played', label: Text('Played')),
                  ],
                  selected: <String>{_currentView},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _currentView = newSelection.first;
                    });
                  },
                  style: SegmentedButton.styleFrom(
                    backgroundColor: const Color(0xFF212121),
                    foregroundColor: Colors.white70,
                    selectedBackgroundColor: const Color(0xFFFF9100),
                    selectedForegroundColor: Colors.white,
                  ),
                ),
              ),
              Padding(
                // Add Export button
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    final messenger =
                        ScaffoldMessenger.of(context); // Capture messenger
                    if (_selectedEvent != null) {
                      try {
                        // Fetch played songs for the selected event
                        final playedRequests = await songRequestService
                            .getSongRequestsForEventByStatus(
                                _selectedEvent!.id, 'played')
                            .first;

                        if (playedRequests.isEmpty) {
                          if (!mounted) return;
                          messenger.showSnackBar(
                            // Use captured messenger
                            const SnackBar(
                                content: Text('No played songs to export.')),
                          );
                          return;
                        }

                        // Format and print the playlist (basic export)
                        _logger.i(
                            '--- Played Songs for ${_selectedEvent!.name} ---');
                        for (var request in playedRequests) {
                          _logger.i(
                              '${request.trackData.artist} - ${request.trackData.name}');
                        }
                        _logger.i('-------------------------------------');

                        if (!mounted) return;
                        messenger.showSnackBar(
                          // Use captured messenger
                          const SnackBar(
                              content:
                                  Text('Played songs exported to console.')),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          // Use captured messenger
                          SnackBar(
                              content:
                                  Text('Failed to export played songs: $e')),
                        );
                      }
                    } else {
                      if (!mounted) return;
                      messenger.showSnackBar(
                        // Use captured messenger
                        const SnackBar(
                            content: Text('Please select an event first.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9100),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text('Export Played Songs'),
                ),
              ),
              Expanded(
                child: StreamBuilder<List<SongRequest>>(
                  stream: _currentView == 'pending'
                      ? songRequestService.getSongRequestsForEvent(
                          _selectedEvent!.id) // Use selected event ID
                      : songRequestService.getSongRequestsForEventByStatus(
                          _selectedEvent!.id,
                          'played'), // Use selected event ID
                  builder: (context, requestSnapshot) {
                    if (requestSnapshot.hasError) {
                      return Center(
                        child: Text(
                            'Error loading requests: ${requestSnapshot.error}',
                            style: const TextStyle(color: Colors.red)),
                      );
                    }

                    if (requestSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final requests = requestSnapshot.data ?? [];

                    if (requests.isEmpty) {
                      return const Center(
                        child: Text('No song requests for this event yet.',
                            style: TextStyle(color: Colors.white70)),
                      );
                    }

                    return ListView.builder(
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final request = requests[index];
                        return Card(
                          color: const Color(0xFF212121),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                request.trackData.albumArt,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 40,
                                    height: 40,
                                    color: Colors.grey[800],
                                    child: const Icon(Icons.music_note,
                                        color: Colors.white),
                                  );
                                },
                              ),
                            ),
                            title: Text(
                              request.trackData.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              '${request.trackData.artist} - Status: ${request.status}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (request.status ==
                                    'pending') // Show approve/deny only for pending
                                  IconButton(
                                    icon: const Icon(Icons.check_circle,
                                        color: Colors.green),
                                    onPressed: () async {
                                      final messenger = ScaffoldMessenger.of(
                                          context); // Capture messenger
                                      try {
                                        await songRequestService
                                            .updateSongRequestStatus(
                                                request.id, 'approved');
                                      } catch (e) {
                                        if (!mounted) return;
                                        messenger.showSnackBar(
                                          // Use captured messenger
                                          SnackBar(
                                              content: Text(
                                                  'Failed to approve request: $e')),
                                        );
                                      }
                                    },
                                  ),
                                if (request.status ==
                                    'pending') // Show approve/deny only for pending
                                  IconButton(
                                    icon: const Icon(Icons.cancel,
                                        color: Colors.red),
                                    onPressed: () async {
                                      final messenger = ScaffoldMessenger.of(
                                          context); // Capture messenger
                                      try {
                                        await songRequestService
                                            .updateSongRequestStatus(
                                                request.id, 'denied');
                                      } catch (e) {
                                        if (!mounted) return;
                                        messenger.showSnackBar(
                                          // Use captured messenger
                                          SnackBar(
                                              content: Text(
                                                  'Failed to deny request: $e')),
                                        );
                                      }
                                    },
                                  ),
                                if (request.status == 'pending' ||
                                    request.status ==
                                        'approved') // Show play for pending or approved
                                  IconButton(
                                    icon: const Icon(Icons.play_circle_fill,
                                        color: Color(0xFFFF9100)),
                                    onPressed: () async {
                                      final messenger = ScaffoldMessenger.of(
                                          context); // Capture messenger
                                      try {
                                        // Play the song using Spotify SDK
                                        await SpotifyService.playSong(request
                                            .trackData
                                            .id); // Assuming trackData.id is the Spotify URI
                                        await songRequestService
                                            .updateSongRequestStatus(
                                                request.id, 'played');
                                      } catch (e) {
                                        if (!mounted) return;
                                        messenger.showSnackBar(
                                          // Use captured messenger
                                          SnackBar(
                                              content: Text(
                                                  'Failed to play song or mark as played: $e')),
                                        );
                                      }
                                    },
                                  ),
                                Text(
                                  '${request.upvotes}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const Icon(Icons.thumb_up,
                                    color: Color(0xFFFFA726), size: 16),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
