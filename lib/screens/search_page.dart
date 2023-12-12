import 'package:flutter/material.dart';
import '../models/song.dart';
import '../widgits/popular_songs.dart';

class SearchPage extends StatefulWidget {
  final void Function(Song song) onSongSelected;
  const SearchPage({super.key, required this.onSongSelected});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  int selectedIndex = 0;
  String query = "";

  // Function to filter songs
  List<Song> searchSongs(String query) {
    return songsData
        .where((song) =>
    song['title']!.toLowerCase().contains(query.toLowerCase()) ||
        song['artist']!.toLowerCase().contains(query.toLowerCase()))
        .map((song) => Song(
      image: song['image']!,
      title: song['title']!,
      artist: song['artist']!,
    ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    var filteredSongs = searchSongs(query);

    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  query = value;
                });
              },
              decoration: const InputDecoration(
                hintStyle: TextStyle(color: Colors.white),
                hintText: 'Search for songs...',
                prefixIcon: Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Color(0xFF161616),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredSongs.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                  ),
                  child: PopularSongs(
                    songs: [filteredSongs[index]], // Pass a list of Song objects
                    onPlayPressed: (BuildContext context, Song song) {
                      widget.onSongSelected(song);
                    },
                  ),

                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
