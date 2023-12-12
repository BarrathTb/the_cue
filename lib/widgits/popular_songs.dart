import 'package:flutter/material.dart';
import '../models/song.dart';

class PopularSongs extends StatelessWidget {
  final List<Song> songs;
  final void Function(BuildContext, Song) onPlayPressed;

  const PopularSongs({super.key, required this.songs, required this.onPlayPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        child: Column(
          children: songs.map((Song song) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage(
                        song.image.isNotEmpty ? song.image : 'assets/images/default_image.png',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title.isNotEmpty ? song.title : 'Default title',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Source Sans Pro',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          song.artist.isNotEmpty ? song.artist : 'Default artist',
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
                    onPressed: () => onPlayPressed(context, song),
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
