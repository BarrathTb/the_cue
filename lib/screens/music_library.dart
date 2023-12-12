import 'package:flutter/material.dart';
import '../data/songs.dart';

class MusicLibrary extends StatefulWidget {
  final ValueChanged<Map<String, String>> onSongSelected;

  const MusicLibrary({super.key, required this.onSongSelected});

  @override
  MusicLibraryState createState() => MusicLibraryState();
}

class MusicLibraryState extends State<MusicLibrary> {
  late List<Map<String, String>> allSongs;

  @override
  void initState() {
    super.initState();
    allSongs = songs;
  }

  void showSongsByArtist(String artist) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          List<Map<String, String>> songsByArtist = allSongs
              .where((song) => song['artist'] == artist)
              .toList();

          return ListView.builder(
            itemCount: songsByArtist.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                leading: Image.asset(songsByArtist[index]['image'] ?? 'assets/images/default.png'),
                title: Text(songsByArtist[index]['title'] ?? 'No Title'),
                subtitle: Text(songsByArtist[index]['artist'] ?? 'No Artist'),
              );
            },
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      body: ListView.builder(
        itemCount: allSongs.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: Image.asset(allSongs[index]['image'] ?? 'assets/images/default.png'),
            title: Text(allSongs[index]['title'] ?? 'No Title', style: const TextStyle(color: Colors.white)),
            subtitle: Text(allSongs[index]['artist'] ?? 'No Artist', style: const TextStyle(color: Colors.white)),
            trailing: IconButton(icon: const Icon(Icons.play_circle_outline, color: Color(0xFFFFA726)),
                onPressed: () {
                  widget.onSongSelected(allSongs[index]);
                }),
            onTap: () => showSongsByArtist(allSongs[index]['artist']! ),
          );
        },
      ),
    );
  }
}


