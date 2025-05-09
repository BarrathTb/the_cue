import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../models/playlist.dart';
import '../services/playlist_service.dart';

final Logger _logger = Logger();

class RecentPlaylistCard extends StatelessWidget {
  const RecentPlaylistCard({
    super.key,
    required this.playlist,
    required this.onTap,
  });

  final PlaylistModel playlist;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(14),
        width: 170,
        height: 120,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(playlist.imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.blueGrey.shade900.withOpacity(0.7),
              BlendMode.srcOver,
            ),
            onError: (exception, stackTrace) =>
                const AssetImage('assets/images/default_image.png'),
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                // Wrap Name Text with Expanded
                child: Text(
                  playlist.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16, // Keep original font size for name
                  ),
                ),
              ),
              const SizedBox(height: 4), // Add a small space between texts
              Expanded(
                // Wrap Description Text with Expanded
                child: Text(
                  playlist.description,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 12, // Increased description font size
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardList extends StatefulWidget {
  const CardList({super.key});

  @override
  State<CardList> createState() => _CardListState();
}

class _CardListState extends State<CardList> {
  List<PlaylistModel> recentPlaylists = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentPlaylists();
  }

  Future<void> _loadRecentPlaylists() async {
    final allPlaylists = await PlaylistService.getUserPlaylists();
    setState(() {
      // Take the most recent 6 playlists
      recentPlaylists = allPlaylists.take(6).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: recentPlaylists.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return RecentPlaylistCard(
          playlist: recentPlaylists[index],
          onTap: () {
            // Handle recent playlist selection
            _logger
                .i('Selected recent playlist: ${recentPlaylists[index].name}');
          },
        );
      },
    );
  }
}
