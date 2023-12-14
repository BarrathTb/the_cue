import 'package:flutter/material.dart';
import 'package:the_cue/widgits/playlist_card.dart';
import 'package:the_cue/widgits/popular_songs.dart';
import 'package:the_cue/widgits/recent_playlist_card.dart';
import 'package:the_cue/widgits/section_heading.dart';



import '../models/song.dart';

class HomePageContent extends StatefulWidget {
  final void Function(Song song) onSongSelected;

  const HomePageContent({super.key, required this.onSongSelected});

  @override
  HomePageContentState createState() => HomePageContentState();
}

class HomePageContentState extends State<HomePageContent> {

  List<Song> songs = songsData
      .map((map) => Song(
            image: map['image']!,
            title: map['title']!,
            artist: map['artist']!,
          ))
      .toList();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionHeading(heading: 'Continue where you left off'),
                ElevatedButton(
                  onPressed: () {
                    // Add functionality for the 'Explore All' button
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xFF161616),
                    backgroundColor: Colors.orange.shade400,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)), // text color
                  ),
                  child: const Text(
                    'Explore All',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Source Sans Pro',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              ],
            ),
          ),
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                RecentPlaylistCard(
                  title: 'Relaxing',
                  subtitle: 'Study playlist',
                  imagePath: 'assets/images/card_image_one.png',
                ),
                RecentPlaylistCard(
                  title: 'Party Jams',
                  subtitle: 'Floorshaking playlist',
                  imagePath: 'assets/images/card_image_two.png',
                ),
                RecentPlaylistCard(
                  title: 'Wedding classics',
                  subtitle: 'Top wedding playlist',
                  imagePath: 'assets/images/card_image_five.png',
                ),
                RecentPlaylistCard(
                  title: 'Study time',
                  subtitle: 'Get to work',
                  imagePath: 'assets/images/card_image_three.png',
                ),
                RecentPlaylistCard(
                  title: 'Chill mix',
                  subtitle: 'Downtempo classics',
                  imagePath: 'assets/images/card_image_four.png',
                ),
                RecentPlaylistCard(
                  title: 'Late Nights',
                  subtitle: 'Hot beats',
                  imagePath: 'assets/images/card_image_six.png',
                ),

                // Add more RecentPlaylistCards here...
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionHeading(heading: 'Personalized for you'),
                ElevatedButton(
                  onPressed: () {
                    // Add functionality for the 'Discover More' button
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xFF161616),
                    backgroundColor: const Color(0xFFFFA726),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text(
                    'Discover More',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Source Sans Pro',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              ],
            ),
          ),
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                PlaylistCard(
                  title: 'Your Favorites',
                  description: 'Top artists',
                  imagePath: 'assets/images/playlist_card_one.png',
                ),
                PlaylistCard(
                  title: 'Best of the Best',
                  description: 'Office music',
                  imagePath: 'assets/images/playlist_card_two.png',
                ),
                PlaylistCard(
                  title: 'Top 100',
                  description: 'Top recent plays',
                  imagePath: 'assets/images/playlist_card_three.png',
                ),
                PlaylistCard(
                  title: 'Wedding classics',
                  description: 'Top wedding playlist',
                  imagePath: 'assets/images/playlist_card_four.png',
                ),
                PlaylistCard(
                  title: 'Rock classics',
                  description: 'Top rock playlist',
                  imagePath: 'assets/images/playlist_card_five.png',
                ),
                // Add more PlaylistCards here...
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 16.0), // padding around the list
            child: SectionHeading(heading: 'Popular Songs'),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height *
                0.3, // specify the height you want
            child: PopularSongs(
              songs: songs,
              onPlayPressed: (BuildContext context, Song song) {
                widget.onSongSelected(song);
              },
            ),
          ),
        ],
      ),
    );
  }
}
