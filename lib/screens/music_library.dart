import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

import '../models/track.dart';
import '../services/spotify_service.dart'; // Import SpotifyService

final Logger _logger = Logger();

class MusicLibrary extends StatefulWidget {
  final void Function(Track track, String? note)
      onSongSelected; // Updated signature

  const MusicLibrary({super.key, required this.onSongSelected});

  @override
  MusicLibraryState createState() => MusicLibraryState();
}

class MusicLibraryState extends State<MusicLibrary> {
  List<Track> allTracks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLibrary();
  }

  Future<void> _loadLibrary() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      // Fetch user's saved tracks from SpotifyService
      final savedTracks = await SpotifyService.getSavedTracks(
          limit: 50); // Fetch up to 50 saved tracks
      if (mounted) {
        setState(() {
          allTracks = savedTracks;
          _isLoading = false;
        });
      }
    } catch (e, s) {
      _logger.e('Failed to load music library: $e\nStack trace:\n$s');
      if (mounted) {
        setState(() {
          _isLoading = false;
          allTracks = []; // Clear tracks on error
        });
      }
    }
  }

  void showTracksByArtist(String artist) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      builder: (BuildContext context) {
        List<Track> tracksByArtist = allTracks
            .where(
                (track) => track.artist.toLowerCase() == artist.toLowerCase())
            .toList();

        return ListView.builder(
          itemCount: tracksByArtist.length,
          itemBuilder: (BuildContext context, int index) {
            Track track = tracksByArtist[index];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  track.imageUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey[800],
                      child: const Icon(Icons.music_note, color: Colors.white),
                    );
                  },
                ),
              ),
              title: Text(
                track.title,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                track.artist,
                style: const TextStyle(color: Colors.white70),
              ),
              onTap: () {
                Navigator.pop(context);
                widget.onSongSelected(track, null); // Pass null for note
              },
            );
          },
        );
      },
    );
  }

  Future<void> _playTrack(Track track) async {
    try {
      await SpotifySdk.play(spotifyUri: track.uri);
      widget.onSongSelected(track, null); // Pass null for note
    } catch (e) {
      _logger.e('Failed to play track: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (allTracks.isEmpty) {
      return const Center(
        child: Text(
          'No tracks available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      body: ListView.builder(
        itemCount: allTracks.length,
        itemBuilder: (BuildContext context, int index) {
          final track = allTracks[index];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                track.imageUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey[800],
                    child: const Icon(Icons.music_note, color: Colors.white),
                  );
                },
              ),
            ),
            title: Text(
              track.title,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              track.artist,
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.play_circle_outline,
                color: Color(0xFFFFA726),
              ),
              onPressed: () => _playTrack(track),
            ),
            onTap: () => showTracksByArtist(track.artist),
          );
        },
      ),
    );
  }
}
