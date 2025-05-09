import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:the_cue/models/album.dart';
import 'package:the_cue/models/artist.dart';
import 'package:the_cue/models/event.dart';
import 'package:the_cue/models/track.dart';
import 'package:the_cue/services/spotify_service.dart';

final logger = Logger();

class SearchPage extends StatefulWidget {
  final void Function(Track track, String? note) onSongSelected;
  final Event? event;
  final String? initialQuery; // Add optional initial query

  const SearchPage({
    super.key,
    required this.onSongSelected,
    this.event,
    this.initialQuery,
  });

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  late String query; // Initialize in initState
  List<Track> trackSearchResults = [];
  List<Artist> artistSearchResults = [];
  List<Album> albumSearchResults = [];
  bool _isLoading = false;

  bool _searchTracks = true; // Default to searching tracks
  bool _searchArtists = true;
  bool _searchAlbums = true;

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingPreviewUrl;

  final _debouncer = Debouncer(milliseconds: 500);
  final TextEditingController _noteController = TextEditingController();
  late TextEditingController _searchQueryController; // Controller for TextField

  @override
  void initState() {
    super.initState();
    query = widget.initialQuery ?? "";
    _searchQueryController = TextEditingController(text: query);

    if (query.isNotEmpty) {
      _performSearch(query);
    }

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _currentlyPlayingPreviewUrl = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _searchQueryController.dispose(); // Dispose search controller
    _audioPlayer.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String currentQuery) async {
    if (currentQuery.isEmpty) {
      if (!mounted) return;
      setState(() {
        trackSearchResults = [];
        artistSearchResults = [];
        albumSearchResults = [];
        _isLoading = false;
      });
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      List<Future<dynamic>> searchFutures = [];

      if (_searchTracks) {
        searchFutures.add(SpotifyService.searchTracks(currentQuery));
      }
      if (_searchArtists) {
        searchFutures.add(SpotifyService.searchArtists(currentQuery));
      }
      if (_searchAlbums) {
        searchFutures.add(SpotifyService.searchAlbums(currentQuery));
      }

      if (searchFutures.isEmpty) {
        if (!mounted) return;
        setState(() {
          trackSearchResults = [];
          artistSearchResults = [];
          albumSearchResults = [];
          _isLoading = false;
        });
        return;
      }

      final results = await Future.wait(searchFutures);

      if (!mounted) return;
      setState(() {
        int resultIndex = 0;
        if (_searchTracks) {
          trackSearchResults = results[resultIndex++] as List<Track>;
        } else {
          trackSearchResults = [];
        }
        if (_searchArtists) {
          artistSearchResults = results[resultIndex++] as List<Artist>;
        } else {
          artistSearchResults = [];
        }
        if (_searchAlbums) {
          albumSearchResults = results[resultIndex++] as List<Album>;
        } else {
          albumSearchResults = [];
        }
        _isLoading = false;
      });
    } catch (e, s) {
      logger.e('Failed to search: ${e.toString()}\nStack trace:\n$s');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        trackSearchResults = [];
        artistSearchResults = [];
        albumSearchResults = [];
      });
    }
  }

  Future<void> _playTrack(Track track) async {
    try {
      await SpotifySdk.play(spotifyUri: track.uri);
      widget.onSongSelected(track, null);
    } catch (e) {
      logger.e('Failed to play track: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to play track')),
      );
    }
  }

  Future<void> _playPreview(String url) async {
    if (_currentlyPlayingPreviewUrl == url) {
      await _audioPlayer.stop();
      if (mounted) {
        setState(() {
          _currentlyPlayingPreviewUrl = null;
        });
      }
    } else {
      try {
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(url));
        if (mounted) {
          setState(() {
            _currentlyPlayingPreviewUrl = url;
          });
        }
      } catch (e) {
        logger.e("Error playing preview: $e");
        if (mounted) {
          setState(() {
            _currentlyPlayingPreviewUrl = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not play preview.')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF161616),
        appBar: AppBar(
          title: const Text('Search Songs'),
          backgroundColor: const Color(0xFF161616),
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchQueryController, // Use the controller
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  _debouncer.run(() {
                    setState(() => query = value);
                    _performSearch(value);
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search for songs, artists, albums...',
                  hintStyle: const TextStyle(color: Colors.white60),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Color(0xFFFFA726)),
                  ),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  ChoiceChip(
                    label: const Text('Tracks'),
                    selected: _searchTracks,
                    onSelected: (bool selected) {
                      setState(() {
                        _searchTracks = selected;
                      });
                      _performSearch(query);
                    },
                    selectedColor: Theme.of(context).colorScheme.secondary,
                    labelStyle: TextStyle(
                        color: _searchTracks ? Colors.black : Colors.white),
                    backgroundColor: Colors.grey[800],
                    checkmarkColor: Colors.black,
                  ),
                  ChoiceChip(
                    label: const Text('Artists'),
                    selected: _searchArtists,
                    onSelected: (bool selected) {
                      setState(() {
                        _searchArtists = selected;
                      });
                      _performSearch(query);
                    },
                    selectedColor: Theme.of(context).colorScheme.secondary,
                    labelStyle: TextStyle(
                        color: _searchArtists ? Colors.black : Colors.white),
                    backgroundColor: Colors.grey[800],
                    checkmarkColor: Colors.black,
                  ),
                  ChoiceChip(
                    label: const Text('Albums'),
                    selected: _searchAlbums,
                    onSelected: (bool selected) {
                      setState(() {
                        _searchAlbums = selected;
                      });
                      _performSearch(query);
                    },
                    selectedColor: Theme.of(context).colorScheme.secondary,
                    labelStyle: TextStyle(
                        color: _searchAlbums ? Colors.black : Colors.white),
                    backgroundColor: Colors.grey[800],
                    checkmarkColor: Colors.black,
                  ),
                ],
              ),
            ),
            if (widget.event != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _noteController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Add a note (optional)',
                    hintStyle: const TextStyle(color: Colors.white60),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Color(0xFFFFA726)),
                    ),
                  ),
                ),
              ),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (trackSearchResults.isEmpty &&
                artistSearchResults.isEmpty &&
                albumSearchResults.isEmpty &&
                query.isNotEmpty &&
                (_searchTracks || _searchArtists || _searchAlbums))
              const Expanded(
                child: Center(
                  child: Text(
                    'No results found for selected filters.',
                    style: TextStyle(color: Colors.white60),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView(
                  children: [
                    if (_searchTracks && trackSearchResults.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Text("Tracks",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: trackSearchResults.length,
                        itemBuilder: (context, index) {
                          final track = trackSearchResults[index];
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                track.imageUrl,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 40,
                                    height: 40,
                                    color: Colors.grey[800],
                                    child: const Icon(Icons.music_note,
                                        color: Colors.white),
                                  );
                                },
                              ),
                            ),
                            title: Text(
                              track.title,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              track.artist,
                              style: const TextStyle(color: Colors.white60),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (track.previewUrl != null &&
                                    track.previewUrl!.isNotEmpty)
                                  IconButton(
                                    icon: Icon(
                                      _currentlyPlayingPreviewUrl ==
                                              track.previewUrl
                                          ? Icons.stop_circle_outlined
                                          : Icons.play_circle_outline,
                                      color: Colors.white70,
                                    ),
                                    onPressed: () =>
                                        _playPreview(track.previewUrl!),
                                  ),
                                IconButton(
                                  icon: Icon(
                                    widget.event != null
                                        ? Icons.add_circle
                                        : Icons.play_circle_outline,
                                    color: const Color(0xFFFFA726),
                                  ),
                                  onPressed: () {
                                    if (widget.event != null) {
                                      widget.onSongSelected(
                                          track, _noteController.text.trim());
                                    } else {
                                      _playTrack(track);
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                    if (_searchArtists && artistSearchResults.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Text("Artists",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: artistSearchResults.length,
                        itemBuilder: (context, index) {
                          final artist = artistSearchResults[index];
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: artist.imageUrl != null &&
                                      artist.imageUrl!.isNotEmpty
                                  ? Image.network(
                                      artist.imageUrl!,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: 40,
                                          height: 40,
                                          color: Colors.grey[800],
                                          child: const Icon(Icons.person,
                                              color: Colors.white),
                                        );
                                      },
                                    )
                                  : Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Icon(Icons.person,
                                          color: Colors.white),
                                    ),
                            ),
                            title: Text(
                              artist.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      ),
                    ],
                    if (_searchAlbums && albumSearchResults.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Text("Albums",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: albumSearchResults.length,
                        itemBuilder: (context, index) {
                          final album = albumSearchResults[index];
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: album.imageUrl != null &&
                                      album.imageUrl!.isNotEmpty
                                  ? Image.network(
                                      album.imageUrl!,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: 40,
                                          height: 40,
                                          color: Colors.grey[800],
                                          child: const Icon(Icons.album,
                                              color: Colors.white),
                                        );
                                      },
                                    )
                                  : Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(Icons.album,
                                          color: Colors.white),
                                    ),
                            ),
                            title: Text(
                              album.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              album.artistName,
                              style: const TextStyle(color: Colors.white60),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ));
  }
}

// Debouncer class to prevent too many API calls
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    // Add dispose method for the debouncer
    _timer?.cancel();
  }
}
