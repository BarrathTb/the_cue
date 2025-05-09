import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

import '../models/track.dart'; // assuming you have a Song model

final Logger _logger = Logger();

class MusicPlayerScreen extends StatefulWidget {
  final Track track;
  const MusicPlayerScreen({super.key, required this.track});

  @override
  MusicPlayerScreenState createState() => MusicPlayerScreenState();
}

class MusicPlayerScreenState extends State<MusicPlayerScreen> {
  bool isPlaying = false;
  double _progress = 0.0;
  late StreamSubscription<PlayerState> _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _subscribeToPlayerState();
  }

  Future<void> _initializePlayer() async {
    try {
      final playerState = await SpotifySdk.getPlayerState();
      setState(() {
        isPlaying = playerState?.isPaused == false;
      });
    } catch (e) {
      _logger.e('Failed to initialize player: $e');
    }
  }

  void _subscribeToPlayerState() {
    _playerStateSubscription =
        SpotifySdk.subscribePlayerState().listen((playerState) {
      if (playerState.track != null) {
        setState(() {
          isPlaying = !playerState.isPaused;
          if (playerState.track?.duration != null) {
            _progress =
                playerState.playbackPosition / playerState.track!.duration;
          }
        });
      }
    });
  }

  Future<void> _togglePlayPause() async {
    try {
      if (isPlaying) {
        await SpotifySdk.pause();
      } else {
        await SpotifySdk.resume();
      }
      setState(() => isPlaying = !isPlaying);
    } catch (e) {
      _logger.e('Failed to toggle play/pause: $e');
    }
  }

  Future<void> _skipNext() async {
    try {
      await SpotifySdk.skipNext();
    } catch (e) {
      _logger.e('Failed to skip next: $e');
    }
  }

  Future<void> _skipPrevious() async {
    try {
      await SpotifySdk.skipPrevious();
    } catch (e) {
      _logger.e('Failed to skip previous: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(widget.track.imageUrl),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) =>
                      const AssetImage('assets/images/default_image.png'),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        widget.track.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.track.artist,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey[800],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFFFFA726)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.skip_previous,
                          color: Colors.white, size: 32),
                      onPressed: _skipPrevious,
                    ),
                    IconButton(
                      icon: Icon(
                        isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_fill,
                        color: const Color(0xFFFFA726),
                        size: 64,
                      ),
                      onPressed: _togglePlayPause,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next,
                          color: Colors.white, size: 32),
                      onPressed: _skipNext,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _playerStateSubscription.cancel();
    super.dispose();
  }
}
