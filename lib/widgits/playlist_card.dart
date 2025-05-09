import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../models/playlist.dart';
import '../services/playlist_service.dart';

final Logger _logger = Logger();

class PlaylistCard extends StatelessWidget {
  const PlaylistCard({
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
        margin: const EdgeInsets.all(16),
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
  List<PlaylistModel> playlists = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    final fetchedPlaylists = await PlaylistService.getUserPlaylists();
    setState(() {
      playlists = fetchedPlaylists;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: playlists.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: PlaylistCard(
            playlist: playlists[index],
            onTap: () {
              // Handle playlist selection
              _logger.i('Selected playlist: ${playlists[index].name}');
            },
          ),
        );
      },
    );
  }
}
