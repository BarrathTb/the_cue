import 'package:flutter/material.dart';
import 'package:the_cue/screens/music_library.dart';
import 'package:the_cue/widgits/home_page_content.dart';
import 'package:the_cue/widgits/nav_route.dart';
import 'package:the_cue/screens/search_page.dart';
import 'package:the_cue/screens/settings_screen.dart';
import 'package:the_cue/screens/music_player_screen.dart';

import '../models/song.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  Song _selectedSong = Song(image: 'assets/images/card_image_one.png', artist: 'Dua Lipa Featuring DaBaby', title: 'Levitating');


  @override
  void initState() {
    super.initState();
    _selectedSong = Song(image: 'assets/images/card_image_one.png', artist: 'Dua Lipa Featuring DaBaby', title: 'Levitating');
  }

  // Here is where _onItemTapped should be
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      HomePageContent(),
      SearchPage(onSongSelected: (song) {
        setState(() {
          _selectedSong = song;
          _selectedIndex = 2;  // switch to music player screen
        });
      }),
      MusicPlayerScreen(song: _selectedSong),
      MusicLibrary(onSongSelected: (song) {
        setState(() {
          _selectedSong = song as Song;
          _selectedIndex = 2;  // switch to music player screen
        });
      }),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161616),
        iconTheme: const IconThemeData(color: Colors.white),

        title: Container(
          margin: const EdgeInsets.only(left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Welcome to The Cue!",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontFamily: 'Source Sans Pro',
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {},
              ),
            ],
          )
        ),


        actions: [

          Container(
            margin: const EdgeInsets.only(top: 4, right: 8),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100000),
              image: const DecorationImage(
                image: AssetImage('assets/images/icon_music.png'),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF000000).withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Profile icon
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100000),
              image: const DecorationImage(
                image: AssetImage('assets/images/the_cue_profile_icon.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
        titleSpacing: 0.0,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: widgetOptions,
      ),
        bottomNavigationBar: NavRoute(
            currentIndex: _selectedIndex,
            valueChanged: (index){
              _onItemTapped(index);
            }
        )
    );

  }
}
