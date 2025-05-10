import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:flutter/material.dart';

import '../models/event.dart';
import '../models/song_request.dart'; // Import SongRequest model
import '../services/song_request_service.dart'; // Import SongRequestService
import 'search_page.dart'; // To navigate to search for songs within the event

class EventDetailsScreen extends StatefulWidget {
  final Event event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      appBar: AppBar(
        title: Text(widget.event.name),
        backgroundColor: const Color(0xFF161616),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.event.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.event.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[700],
                      child: const Icon(Icons.event,
                          size: 50, color: Colors.white),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Text(
              widget.event.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.event.description ?? 'No description available.',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Location: ${widget.event.location.venue}, ${widget.event.location.address}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${widget.event.startTime.toDate().toString().split(' ')[0]}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Requests Open: ${widget.event.requestsOpen ? "Yes" : "No"}',
              style: TextStyle(
                color: widget.event.requestsOpen ? Colors.green : Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            if (widget.event.requestsOpen)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to SearchPage to request a song for this event
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchPage(
                          event: widget.event, // Pass the event object
                          onSongSelected: (track, note) async {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              try {
                                final songRequestService = SongRequestService();
                                await songRequestService.createSongRequest(
                                  eventId: widget.event.id,
                                  userId: user.uid,
                                  track: track,
                                  note: note, // Pass the note
                                );

                                if (!mounted) {
                                  return; // Check mounted before using context
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Song request submitted!')),
                                );

                                if (!mounted) {
                                  return; // Check mounted before using context
                                }
                                Navigator.pop(context);
                              } catch (e) {
                                if (!mounted) {
                                  return; // Check mounted before using context
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Failed to submit song request: $e')),
                                );
                              }
                            } else {
                              if (!mounted) {
                                return; // Check mounted before using context
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'You must be logged in to request a song.')),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9100),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Request a Song'),
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              'Song Requests',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<SongRequest>>(
              stream:
                  SongRequestService().getSongRequestsForEvent(widget.event.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading requests: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red)),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final requests = snapshot.data ?? [];

                if (requests.isEmpty) {
                  return const Center(
                    child: Text('No song requests yet.',
                        style: TextStyle(color: Colors.white70)),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true, // Use shrinkWrap in a SingleChildScrollView
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable ListView scrolling
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    return Card(
                      color: const Color(0xFF212121),
                      margin: const EdgeInsets.symmetric(vertical: 4),
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
                            IconButton(
                              icon: const Icon(Icons.thumb_up,
                                  color: Color(0xFFFFA726)),
                              onPressed: () async {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  try {
                                    await SongRequestService()
                                        .toggleUpvote(request.id, user.uid);
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Failed to toggle upvote: $e')),
                                    );
                                  }
                                } else {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'You must be logged in to upvote.')),
                                  );
                                }
                              },
                            ),
                            Text(
                              '${request.upvotes}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            // Add Prioritize Button
                            if (FirebaseAuth.instance.currentUser != null &&
                                request.userId ==
                                    FirebaseAuth.instance.currentUser!.uid &&
                                !request.isPriority)
                              IconButton(
                                icon:
                                    const Icon(Icons.star, color: Colors.amber),
                                tooltip: 'Prioritize this request',
                                onPressed: () async {
                                  final messenger =
                                      ScaffoldMessenger.of(context);
                                  try {
                                    await SongRequestService()
                                        .updateRequestPriority(request.id);
                                    messenger.showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Request prioritized!')),
                                    );
                                  } catch (e) {
                                    messenger.showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Failed to prioritize request: $e')),
                                    );
                                  }
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
