import 'package:flutter/material.dart';
import '../models/song.dart';

class MusicLibrary extends StatefulWidget {
  final void Function(Song song) onSongSelected;

  const MusicLibrary({super.key, required this.onSongSelected});

  @override
  MusicLibraryState createState() => MusicLibraryState();
}

class MusicLibraryState extends State<MusicLibrary> {
  late List<Song> allSongs;

  @override
  void initState() {
    super.initState();
    allSongs = songs;
  }

  void showSongsByArtist(String artist) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        List<Song> songsByArtist = allSongs
            .where((song) => song.artist.toLowerCase() == artist.toLowerCase())
            .toList();

        return ListView.builder(
          itemCount: songsByArtist.length,
          itemBuilder: (BuildContext context, int index) {
            Song song = songsByArtist[index];
            return ListTile(
              leading: Image.asset(song.image),
              title: Text(song.title, style: const TextStyle(color: Colors.white)),
              subtitle: Text(song.artist, style: const TextStyle(color: Colors.white)),
            );
          },
        );
      },
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
            leading: Image.asset(allSongs[index].image),
            title: Text(allSongs[index].title, style: const TextStyle(color: Colors.white)),
            subtitle: Text(allSongs[index].artist, style: const TextStyle(color: Colors.white)),
            trailing: IconButton(icon: const Icon(Icons.play_circle_outline, color: Color(0xFFFFA726)),
                onPressed: () {
                  widget.onSongSelected(allSongs[index]);
                }),
            onTap: () => showSongsByArtist(allSongs[index].artist),
          );
        },
      ),
    );
  }
}


