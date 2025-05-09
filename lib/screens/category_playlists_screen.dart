import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:the_cue/models/playlist.dart';
import 'package:the_cue/screens/playlist_tracks_screen.dart';
import 'package:the_cue/services/spotify_service.dart';
import 'package:the_cue/widgits/playlist_card.dart'; // Re-using PlaylistCard for display

final Logger _logger = Logger();

class CategoryPlaylistsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String? userCountry; // Pass userCountry for API consistency

  const CategoryPlaylistsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.userCountry,
  });

  @override
  State<CategoryPlaylistsScreen> createState() =>
      _CategoryPlaylistsScreenState();
}

class _CategoryPlaylistsScreenState extends State<CategoryPlaylistsScreen> {
  List<PlaylistModel> _playlists = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCategoryPlaylists();
  }

  Future<void> _fetchCategoryPlaylists() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final playlists = await SpotifyService.getCategoryPlaylists(
        widget.categoryId,
        country: widget.userCountry, // Use the passed country
        limit: 50, // Fetch more playlists for a category
      );
      if (mounted) {
        setState(() {
          _playlists = playlists;
          _isLoading = false;
        });
      }
    } catch (e) {
      _logger.e('Error fetching category playlists: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to load playlists for this category.';
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
        title: Text(widget.categoryName,
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
              onPressed: _fetchCategoryPlaylists,
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }
    if (_playlists.isEmpty) {
      return const Center(
          child: Text('No playlists found in this category.',
              style: TextStyle(color: Colors.white70, fontSize: 16)));
    }

    // Using a GridView to display playlist cards, similar to how categories might be shown
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8, // Adjust for PlaylistCard aspect ratio
      ),
      itemCount: _playlists.length,
      itemBuilder: (context, index) {
        final playlist = _playlists[index];
        return PlaylistCard(
          // Reusing PlaylistCard
          playlist: playlist,
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
