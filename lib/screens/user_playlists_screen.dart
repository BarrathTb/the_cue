import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:the_cue/models/playlist.dart';
import 'package:the_cue/screens/playlist_tracks_screen.dart';
import 'package:the_cue/services/playlist_service.dart';

final Logger _logger = Logger();

class UserPlaylistsScreen extends StatefulWidget {
  const UserPlaylistsScreen({super.key});

  @override
  State<UserPlaylistsScreen> createState() => _UserPlaylistsScreenState();
}

class _UserPlaylistsScreenState extends State<UserPlaylistsScreen> {
  List<PlaylistModel> _playlists = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAllUserPlaylists();
  }

  Future<void> _fetchAllUserPlaylists() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final playlists = await PlaylistService.getUserPlaylists();
      if (mounted) {
        setState(() {
          _playlists = playlists;
          _isLoading = false;
        });
      }
    } catch (e) {
      _logger.e('Error fetching all user playlists: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to load playlists. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      appBar: AppBar(
        title: const Text('All My Playlists',
            style: TextStyle(color: Colors.white)),
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
              onPressed: _fetchAllUserPlaylists,
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }
    if (_playlists.isEmpty) {
      return const Center(
          child: Text('You have no playlists.',
              style: TextStyle(color: Colors.white70, fontSize: 16)));
    }

    // Using ListTile for a simpler vertical list, but PlaylistCard could be adapted for a GridView
    return ListView.builder(
      itemCount: _playlists.length,
      itemBuilder: (context, index) {
        final playlist = _playlists[index];
        return ListTile(
          leading: playlist.imageUrl.isNotEmpty
              ? Image.network(
                  playlist.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.music_note,
                      color: Colors.white,
                      size: 50),
                )
              : const Icon(Icons.music_note, color: Colors.white, size: 50),
          title:
              Text(playlist.name, style: const TextStyle(color: Colors.white)),
          subtitle: Text(
              playlist.description.isNotEmpty
                  ? playlist.description
                  : 'No description',
              style: const TextStyle(color: Colors.white70)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaylistTracksScreen(
                  playlistId: playlist.id,
                  playlistName: playlist.name,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
