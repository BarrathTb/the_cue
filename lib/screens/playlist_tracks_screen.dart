import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:the_cue/models/track.dart';
import 'package:the_cue/services/playlist_service.dart';
import 'package:the_cue/services/spotify_service.dart'; // For _playTrack

final Logger _logger = Logger();

class PlaylistTracksScreen extends StatefulWidget {
  final String playlistId;
  final String playlistName;

  const PlaylistTracksScreen({
    super.key,
    required this.playlistId,
    required this.playlistName,
  });

  @override
  State<PlaylistTracksScreen> createState() => _PlaylistTracksScreenState();
}

class _PlaylistTracksScreenState extends State<PlaylistTracksScreen> {
  List<Track> _tracks = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPlaylistTracks();
  }

  Future<void> _fetchPlaylistTracks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final tracks = await PlaylistService.getPlaylistTracks(widget.playlistId);
      if (mounted) {
        setState(() {
          _tracks = tracks;
          _isLoading = false;
        });
      }
    } catch (e) {
      _logger.e('Error fetching playlist tracks: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to load tracks. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  // Basic play track functionality (can be expanded)
  Future<void> _playTrack(Track track) async {
    try {
      await SpotifyService.playSong(track.uri);
      // Consider if onSongSelected callback is needed here or if it's just for player screen
    } catch (e) {
      _logger.e('Failed to play track from playlist screen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to play track')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      appBar: AppBar(
        title: Text(widget.playlistName,
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF161616),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!,
                style: const TextStyle(color: Colors.red, fontSize: 16)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchPlaylistTracks,
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }
    if (_tracks.isEmpty) {
      return const Center(
          child: Text('This playlist is empty.',
              style: TextStyle(color: Colors.white70, fontSize: 16)));
    }

    return ListView.builder(
      itemCount: _tracks.length,
      itemBuilder: (context, index) {
        final track = _tracks[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              track.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[800],
                  child: const Icon(Icons.music_note, color: Colors.white),
                );
              },
            ),
          ),
          title: Text(track.title, style: const TextStyle(color: Colors.white)),
          subtitle:
              Text(track.artist, style: const TextStyle(color: Colors.white70)),
          trailing: IconButton(
            icon:
                const Icon(Icons.play_circle_outline, color: Color(0xFFFFA726)),
            onPressed: () => _playTrack(track),
          ),
          onTap: () => _playTrack(track), // Also play on tap
        );
      },
    );
  }
}
