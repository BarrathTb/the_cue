import 'package:flutter/material.dart';
import '../models/track.dart';

class PopularSongs extends StatelessWidget {
  final List<Track> tracks;
  final void Function(BuildContext, Track) onPlayPressed;

  const PopularSongs(
      {super.key, required this.tracks, required this.onPlayPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        child: Column(
          children: tracks.map((Track track) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: ClipOval(
                      child: Image(
                        image: track.imageUrl.isNotEmpty
                            ? NetworkImage(track.imageUrl)
                            : const AssetImage(
                                    'assets/images/default_image.png')
                                as ImageProvider,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/default_image.png',
                            fit: BoxFit.cover,
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFFFA726),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title.isNotEmpty
                              ? track.title
                              : 'Default title',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Source Sans Pro',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          track.artist.isNotEmpty
                              ? track.artist
                              : 'Default artist',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Source Sans Pro',
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.play_circle_outline,
                      color: Color(0xFFFFA726),
                    ),
                    onPressed: () => onPlayPressed(context, track),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
