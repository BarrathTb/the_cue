import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:the_cue/models/track.dart'; // Changed to package import
import 'package:the_cue/models/user.dart'
    as app_user; // Alias for app user model
import 'package:the_cue/screens/dj_dashboard_screen.dart'; // Import DjDashboardScreen
import 'package:the_cue/screens/event_list_screen.dart'; // Import EventListScreen
import 'package:the_cue/screens/music_library.dart';
import 'package:the_cue/screens/music_player_screen.dart';
import 'package:the_cue/screens/search_page.dart';
import 'package:the_cue/screens/settings_screen.dart';
import 'package:the_cue/services/spotify_service.dart';
import 'package:the_cue/widgits/home_page_content.dart';
import 'package:the_cue/widgits/nav_route.dart';

import '../services/user_service.dart'; // Import UserService

final Logger _logger = Logger();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  Track? _selectedTrack;
  bool _isSpotifyConnected = false;
  app_user.User? _currentUser; // Store current user
  final UserService _userService = UserService(); // UserService instance

  @override
  void initState() {
    super.initState();
    _initializeSpotify();
    _loadCurrentUser(); // Load user data
  }

  Future<void> _initializeSpotify() async {
    try {
      final connected = await SpotifyService.connectToSpotify();
      setState(() {
        _isSpotifyConnected = connected;
      });
    } catch (e) {
      _logger.e('Failed to initialize Spotify: $e');
    }
  }

  Future<void> _loadCurrentUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      try {
        final userProfile = await _userService.getUser(firebaseUser.uid);
        setState(() {
          _currentUser = userProfile;
        });
      } catch (e) {
        _logger.e('Error loading user profile: $e');
        // Handle error loading user profile
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleTrackSelected(Track track, String? note) {
    // Accept note parameter
    setState(() {
      _selectedTrack = track;
      // Adjust index based on whether DJ tab is visible
      _selectedIndex =
          (_currentUser?.role == 'dj' ? 5 : 4); // switch to music player screen
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSpotifyConnected) {
      return Scaffold(
        backgroundColor: const Color(0xFF161616),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Connecting to Spotify...',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeSpotify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA726),
                ),
                child: const Text('Retry Connection'),
              ),
            ],
          ),
        ),
      );
    }

    // Conditionally include DjDashboardScreen based on user role
    final List<Widget> widgetOptions = <Widget>[
      HomePageContent(
        onSongSelected: (track, note) =>
            _handleTrackSelected(track, note), // Pass track and note
      ),
      const EventListScreen(), // Add EventListScreen
      SearchPage(
        onSongSelected: (track, note) =>
            _handleTrackSelected(track, note), // Pass track and note
      ),
      if (_selectedTrack != null)
        MusicPlayerScreen(track: _selectedTrack!)
      else
        const Center(
          child: Text(
            'No track selected',
            style: TextStyle(color: Colors.white),
          ),
        ),
      MusicLibrary(
        onSongSelected: (track, note) =>
            _handleTrackSelected(track, note), // Pass track and note
      ),
      if (_currentUser?.role == 'dj') // Conditionally add DJ tab content
        const DjDashboardScreen(),
      const SettingsScreen(),
    ];

    // Conditionally build bottom navigation bar items
    final List<BottomNavigationBarItem> bottomNavBarItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.event),
        label: 'Events',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.search),
        label: 'Search',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.play_circle_fill_outlined),
        label: 'Player',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.library_music),
        label: 'Library',
      ),
      if (_currentUser?.role == 'dj') // Conditionally add DJ tab item
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'DJ',
        ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'Settings',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: widgetOptions,
      ),
      bottomNavigationBar: NavRoute(
        currentIndex: _selectedIndex,
        valueChanged: _onItemTapped,
        items: bottomNavBarItems, // Pass the dynamically created items
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF161616),
      iconTheme: const IconThemeData(color: Colors.white),
      title: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
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
        ),
      ),
      actions: [
        _buildMusicIcon(),
        const SizedBox(width: 16),
        _buildProfileIcon(),
        const SizedBox(width: 16),
      ],
      titleSpacing: 0.0,
    );
  }

  Widget _buildMusicIcon() {
    return Container(
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
    );
  }

  Widget _buildProfileIcon() {
    return Container(
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
    );
  }
}
