import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:the_cue/screens/browse_categories_screen.dart'; // Import BrowseCategoriesScreen
import 'package:the_cue/screens/playlist_tracks_screen.dart';
import 'package:the_cue/screens/user_playlists_screen.dart';
import 'package:the_cue/widgits/playlist_card.dart';
import 'package:the_cue/widgits/popular_songs.dart';
import 'package:the_cue/widgits/recent_playlist_card.dart';
import 'package:the_cue/widgits/section_heading.dart';

import '../models/playlist.dart';
import '../models/track.dart';
import '../services/playlist_service.dart';
import '../services/spotify_service.dart';

final Logger _logger = Logger();

class HomePageContent extends StatefulWidget {
  final void Function(Track track, String? note) onSongSelected;

  const HomePageContent({super.key, required this.onSongSelected});

  @override
  HomePageContentState createState() => HomePageContentState();
}

class HomePageContentState extends State<HomePageContent> {
  List<Track> tracks = []; // For popular/recommended songs
  List<PlaylistModel> recentPlaylists = [];
  List<PlaylistModel> personalizedPlaylists = [];
  bool _isConnected = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeSpotifyAndLoadData();
  }

  Future<void> _initializeSpotifyAndLoadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Connect to Spotify first and wait for it to complete
      _isConnected = await SpotifyService.connectToSpotify();

      if (_isConnected) {
        // Wait for each operation to complete before starting the next one
        await _loadPlaylists();
        await _loadPopularSongs();

        if (mounted) {
          setState(() => _isLoading = false);
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      _logger.e('Failed to initialize Spotify or load data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadPopularSongs() async {
    try {
      _logger.i(
          'Searching for "Global Top 50" playlist by name for popular songs...');
      final foundPlaylists =
          await SpotifyService.searchPlaylistsByName("Global Top 50", limit: 1);

      if (foundPlaylists.isNotEmpty) {
        final playlistId = foundPlaylists.first.id;
        _logger.i(
            'Found playlist "${foundPlaylists.first.name}" (ID: $playlistId) by search. Fetching tracks...');
        final popularTracks =
            await PlaylistService.getPlaylistTracks(playlistId);

        _logger.i(
            'Fetched ${popularTracks.length} tracks from playlist ID $playlistId for popular songs.');

        if (mounted) {
          setState(() {
            tracks = popularTracks.take(10).toList(); // Display top 10
          });
        }
      } else {
        _logger.w(
            'Could not find "Global Top 50" (or similar) playlist by search.');
        if (mounted) {
          setState(() {
            tracks = [];
          });
        }
      }
    } catch (e, s) {
      _logger.e('Error in _loadPopularSongs: $e\nStack trace:\n$s');
      if (mounted) {
        setState(() {
          tracks = [];
        });
      }
    }
  }

  Future<void> _loadPlaylists() async {
    try {
      final playlists = await PlaylistService.getUserPlaylists();
      if (mounted) {
        setState(() {
          recentPlaylists = playlists.take(6).toList();
          personalizedPlaylists =
              playlists.length > 6 ? playlists.skip(6).take(5).toList() : [];
        });
      }
    } catch (e) {
      _logger.e('Failed to load playlists: $e');
      if (mounted) {
        setState(() {
          recentPlaylists = [];
          personalizedPlaylists = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_isConnected &&
        tracks.isEmpty &&
        recentPlaylists.isEmpty &&
        personalizedPlaylists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Could not connect to Spotify.',
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (mounted) {
                  setState(() => _isLoading = true);
                }
                _initializeSpotifyAndLoadData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA726),
              ),
              child: const Text('Retry Connection'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (recentPlaylists.isNotEmpty) ...[
            _buildSectionHeader(
              'Continue where you left off',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserPlaylistsScreen()),
                );
              },
            ),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recentPlaylists.length,
                itemBuilder: (context, index) {
                  final playlist = recentPlaylists[index];
                  return RecentPlaylistCard(
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
              ),
            ),
          ],
          if (personalizedPlaylists.isNotEmpty) ...[
            _buildSectionHeader(
              'Personalized for you',
              buttonText: 'Discover More',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BrowseCategoriesScreen(
                          onSongSelected: widget.onSongSelected)),
                );
              },
            ),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: personalizedPlaylists.length,
                itemBuilder: (context, index) {
                  final playlist = personalizedPlaylists[index];
                  return PlaylistCard(
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
              ),
            ),
          ],
          if (tracks.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
              child: SectionHeading(heading: 'Popular Songs'),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              child: PopularSongs(
                tracks: tracks,
                onPlayPressed: (context, track) {
                  widget.onSongSelected(track, null);
                },
              ),
            ),
          ] else if (!_isLoading && _isConnected) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                  child: Text("Could not load popular songs.",
                      style: TextStyle(color: Colors.white70))),
            )
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title,
      {String buttonText = 'Explore All', VoidCallback? onPressed}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SectionHeading(heading: title),
          ),
          if (onPressed != null)
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xFF161616),
                backgroundColor: const Color(0xFFFFA726),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Source Sans Pro',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
