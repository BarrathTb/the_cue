import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

import '../models/album.dart'; // Import the Album model
import '../models/artist.dart'; // Import the Artist model
import '../models/playlist.dart'; // Import PlaylistModel
import '../models/track.dart';

final Logger _logger = Logger();

class SpotifyService {
  static const String _baseUrl = 'https://api.spotify.com/v1';
  static String? _accessToken;

  // Helper method to get or refresh the access token
  static Future<String?> _getOrRefreshAccessToken() async {
    try {
      final token = await SpotifySdk.getAccessToken(
        clientId: dotenv.env['SPOTIFY_CLIENT_ID']!,
        redirectUrl: dotenv.env['REDIRECT_URL']!,
        scope:
            'app-remote-control,user-library-read,playlist-read-private,streaming,user-read-currently-playing,user-top-read,user-read-private', // Added user-read-private for country
      );
      _accessToken = token;
      return _accessToken;
    } catch (e) {
      _logger.e('Failed to get access token: $e');
      _accessToken = null; // Clear token on error
      return null;
    }
  }

  static Future<bool> connectToSpotify() async {
    try {
      // First ensure we have an access token
      await _getOrRefreshAccessToken();
      if (_accessToken == null) {
        _logger.e('Failed to connect to Spotify: Could not get access token.');
        return false;
      }

      // Then connect to Spotify remote
      return await SpotifySdk.connectToSpotifyRemote(
        clientId: dotenv.env['SPOTIFY_CLIENT_ID']!,
        redirectUrl: dotenv.env['REDIRECT_URL']!,
      );
    } catch (e) {
      _logger.e('Failed to connect to Spotify remote: $e');
      return false;
    }
  }

  static Future<void> playSong(String uri) async {
    try {
      // Attempt to connect if we don't have a token, implying we're not connected.
      // The connectToSpotify method handles both token and remote connection.
      if (_accessToken == null) {
        bool connected = await connectToSpotify();
        if (!connected) {
          _logger.e('Failed to play song: Could not connect to Spotify.');
          return;
        }
      }
      // If connectToSpotify was successful (or we already had a token),
      // SpotifySdk.play should work if the remote connection is active.
      await SpotifySdk.play(spotifyUri: uri);
    } catch (e) {
      _logger.e('Failed to play song: $e');
    }
  }

  static Future<List<Track>> searchTracks(String query) async {
    try {
      if (_accessToken == null) {
        await _getOrRefreshAccessToken(); // Only get token, don't connect to remote
        if (_accessToken == null) {
          _logger.e('Error searching tracks: Could not get access token.');
          return [];
        }
      }

      final response = await http.get(
        Uri.parse(
            '$_baseUrl/search?type=track&q=${Uri.encodeComponent(query)}&limit=20'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tracks = data['tracks']['items'] as List;
        return tracks.map((track) => Track.fromSpotifyTrack(track)).toList();
      }
      return [];
    } catch (e, s) {
      // Also catch stack trace for more context
      _logger.e('Error searching tracks: ${e.toString()}\nStack trace:\n$s');
      return [];
    }
  }

  static Future<List<Artist>> searchArtists(String query) async {
    try {
      if (_accessToken == null) {
        await _getOrRefreshAccessToken();
        if (_accessToken == null) {
          _logger.e('Error searching artists: Could not get access token.');
          return [];
        }
      }

      final response = await http.get(
        Uri.parse(
            '$_baseUrl/search?type=artist&q=${Uri.encodeComponent(query)}&limit=20'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['artists'] != null && data['artists']['items'] != null) {
          final artists = data['artists']['items'] as List;
          return artists
              .map((artistData) => Artist.fromSpotifyApi(artistData))
              .toList();
        }
        return []; // Return empty if 'artists' or 'items' is null
      }
      return [];
    } catch (e, s) {
      _logger.e('Error searching artists: ${e.toString()}\nStack trace:\n$s');
      return [];
    }
  }

  static Future<List<Album>> searchAlbums(String query) async {
    try {
      if (_accessToken == null) {
        await _getOrRefreshAccessToken();
        if (_accessToken == null) {
          _logger.e('Error searching albums: Could not get access token.');
          return [];
        }
      }

      final response = await http.get(
        Uri.parse(
            '$_baseUrl/search?type=album&q=${Uri.encodeComponent(query)}&limit=20'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['albums'] != null && data['albums']['items'] != null) {
          final albums = data['albums']['items'] as List;
          return albums
              .map((albumData) => Album.fromSpotifyApi(albumData))
              .toList();
        }
        return [];
      }
      return [];
    } catch (e, s) {
      _logger.e('Error searching albums: ${e.toString()}\nStack trace:\n$s');
      return [];
    }
  }

  static Future<List<Track>> getRecommendedTracks({
    List<String>? seedGenres,
    List<String>? seedArtists,
    List<String>? seedTracks,
    int limit = 20,
  }) async {
    try {
      if (_accessToken == null) {
        await _getOrRefreshAccessToken();
        if (_accessToken == null) {
          _logger
              .e('Error getting recommendations: Could not get access token.');
          return [];
        }
      }

      Map<String, String> queryParameters = {
        'limit': limit.toString(),
      };
      if (seedGenres != null && seedGenres.isNotEmpty) {
        queryParameters['seed_genres'] = seedGenres.join(',');
      }
      if (seedArtists != null && seedArtists.isNotEmpty) {
        queryParameters['seed_artists'] = seedArtists.join(',');
      }
      if (seedTracks != null && seedTracks.isNotEmpty) {
        queryParameters['seed_tracks'] = seedTracks.join(',');
      }

      if (queryParameters.length == 1 && queryParameters.containsKey('limit')) {
        _logger.w(
            'Cannot get recommendations without at least one seed (genre, artist, or track).');
        return []; // Spotify API requires at least one seed
      }

      final uri = Uri.parse('$_baseUrl/recommendations')
          .replace(queryParameters: queryParameters);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['tracks'] != null) {
          final tracks = data['tracks'] as List;
          return tracks
              .map((trackData) => Track.fromSpotifyTrack(trackData))
              .toList();
        }
        return [];
      }
      _logger.w(
          'Failed to get recommendations: ${response.statusCode} ${response.body}');
      return [];
    } catch (e, s) {
      _logger.e(
          'Error getting recommendations: ${e.toString()}\nStack trace:\n$s');
      return [];
    }
  }

  // static Future<List<PlaylistModel>> getFeaturedPlaylists(
  //     {int limit = 1}) async {
  //   try {
  //     if (_accessToken == null) {
  //       await _getOrRefreshAccessToken();
  //       if (_accessToken == null) {
  //         _logger.e(
  //             'Error getting featured playlists: Could not get access token.');
  //         return [];
  //       }
  //     }

  //     final Map<String, String> queryParameters = {
  //       'limit': limit.toString(),
  //       // Removed 'country': 'US' for now to test without it
  //     };
  //     final uri = Uri.parse('$_baseUrl/browse/featured-playlists')
  //         .replace(queryParameters: queryParameters);
  //     _logger
  //         .i("Fetching featured playlists from URI: $uri"); // Log the exact URI

  //     final response = await http.get(
  //       uri,
  //       headers: {
  //         'Authorization': 'Bearer $_accessToken',
  //         'Content-Type': 'application/json',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       if (data['playlists'] != null && data['playlists']['items'] != null) {
  //         final playlistsData = data['playlists']['items'] as List;
  //         return playlistsData.map((playlistData) {
  //           String imageUrl =
  //               'assets/images/default_image.png'; // Default image
  //           if (playlistData['images'] != null &&
  //               (playlistData['images'] as List).isNotEmpty) {
  //             imageUrl = playlistData['images'][0]['url'] ?? imageUrl;
  //           }
  //           return PlaylistModel(
  //             id: playlistData['id'] ?? '',
  //             name: playlistData['name'] ?? 'Unknown Playlist',
  //             description: playlistData['description'] ??
  //                 '', // Web API might have null description
  //             imageUrl: imageUrl,
  //             uri: playlistData['uri'] ?? '',
  //           );
  //         }).toList();
  //       }
  //       _logger.w(
  //           'No playlists found in featured playlists response: ${response.body}');
  //       return [];
  //     }
  //     _logger.w(
  //         'Failed to get featured playlists: ${response.statusCode} ${response.body}');
  //     return [];
  //   } catch (e, s) {
  //     _logger.e(
  //         'Error getting featured playlists: ${e.toString()}\nStack trace:\n$s');
  //     return [];
  //   }
  // }

  static Future<List<Map<String, dynamic>>> getBrowseCategories(
      {int limit = 10, String? country}) async {
    try {
      if (_accessToken == null) {
        await _getOrRefreshAccessToken();
        if (_accessToken == null) {
          _logger.e(
              'Error getting browse categories: Could not get access token.');
          return [];
        }
      }

      final Map<String, String> queryParameters = {
        'limit': limit.toString(),
      };
      if (country != null) {
        queryParameters['country'] = country;
      }

      final uri = Uri.parse('$_baseUrl/browse/categories')
          .replace(queryParameters: queryParameters);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['categories'] != null && data['categories']['items'] != null) {
          final categoriesData = data['categories']['items'] as List;
          return categoriesData.cast<Map<String, dynamic>>();
        }
        _logger.w('No categories found in browse response: ${response.body}');
        return [];
      }
      _logger.w(
          'Failed to get browse categories: ${response.statusCode} ${response.body}');
      return [];
    } catch (e, s) {
      _logger.e(
          'Error getting browse categories: ${e.toString()}\nStack trace:\n$s');
      return [];
    }
  }

  static Future<List<PlaylistModel>> getCategoryPlaylists(String categoryId,
      {int limit = 10, String? country}) async {
    try {
      if (_accessToken == null) {
        await _getOrRefreshAccessToken();
        if (_accessToken == null) {
          _logger.e(
              'Error getting category playlists: Could not get access token.');
          return [];
        }
      }

      final Map<String, String> queryParameters = {
        'limit': limit.toString(),
      };
      if (country != null) {
        queryParameters['country'] = country;
      }

      final uri = Uri.parse('$_baseUrl/browse/categories/$categoryId/playlists')
          .replace(queryParameters: queryParameters);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // The featured-playlists endpoint nests items under "playlists", check if this is the same
        if (data['playlists'] != null && data['playlists']['items'] != null) {
          final playlistsData = data['playlists']['items'] as List;
          return playlistsData.map((playlistData) {
            String imageUrl = 'assets/images/default_image.png';
            if (playlistData['images'] != null &&
                (playlistData['images'] as List).isNotEmpty) {
              imageUrl = playlistData['images'][0]['url'] ?? imageUrl;
            }
            return PlaylistModel(
              id: playlistData['id'] ?? '',
              name: playlistData['name'] ?? 'Unknown Playlist',
              description: playlistData['description'] ?? '',
              imageUrl: imageUrl,
              uri: playlistData['uri'] ?? '',
            );
          }).toList();
        }
        _logger.w('No playlists found in category response: ${response.body}');
        return [];
      }
      _logger.w(
          'Failed to get category playlists: ${response.statusCode} ${response.body}');
      return [];
    } catch (e, s) {
      _logger.e(
          'Error getting category playlists for $categoryId: ${e.toString()}\nStack trace:\n$s');
      return [];
    }
  }

  static Future<List<PlaylistModel>> searchPlaylistsByName(String playlistName,
      {int limit = 1}) async {
    try {
      if (_accessToken == null) {
        await _getOrRefreshAccessToken();
        if (_accessToken == null) {
          _logger.e(
              'Error searching playlists by name: Could not get access token.');
          return [];
        }
      }

      final response = await http.get(
        Uri.parse(
            '$_baseUrl/search?type=playlist&q=${Uri.encodeComponent(playlistName)}&limit=$limit'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['playlists'] != null && data['playlists']['items'] != null) {
          final playlistsData = data['playlists']['items'] as List;
          return playlistsData.map((playlistData) {
            String imageUrl = 'assets/images/default_image.png';
            if (playlistData['images'] != null &&
                (playlistData['images'] as List).isNotEmpty) {
              imageUrl = playlistData['images'][0]['url'] ?? imageUrl;
            }
            return PlaylistModel(
              id: playlistData['id'] ?? '',
              name: playlistData['name'] ?? 'Unknown Playlist',
              description: playlistData['description'] ?? '',
              imageUrl: imageUrl,
              uri: playlistData['uri'] ?? '',
            );
          }).toList();
        }
        _logger
            .w('No playlists found when searching by name: ${response.body}');
        return [];
      }
      _logger.w(
          'Failed to search playlists by name: ${response.statusCode} ${response.body}');
      return [];
    } catch (e, s) {
      _logger.e(
          'Error searching playlists by name "$playlistName": ${e.toString()}\nStack trace:\n$s');
      return [];
    }
  }

  static Future<String?> getUserCountry() async {
    try {
      if (_accessToken == null) {
        await _getOrRefreshAccessToken();
        if (_accessToken == null) {
          _logger.e('Error getting user country: Could not get access token.');
          return null;
        }
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/me'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['country'] as String?;
      } else {
        _logger.w(
            'Failed to get user profile/country: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e, s) {
      _logger
          .e('Error getting user country: ${e.toString()}\nStack trace:\n$s');
      return null;
    }
  }

  static Future<List<String>> getAvailableGenreSeeds() async {
    try {
      if (_accessToken == null) {
        await _getOrRefreshAccessToken();
        if (_accessToken == null) {
          _logger.e('Error getting genre seeds: Could not get access token.');
          return [];
        }
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/recommendations/available-genre-seeds'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['genres'] != null && data['genres'] is List) {
          return List<String>.from(data['genres']);
        }
        _logger
            .w('No genres found in available seeds response: ${response.body}');
        return [];
      }
      _logger.w(
          'Failed to get available genre seeds: ${response.statusCode} ${response.body}');
      return [];
    } catch (e, s) {
      _logger.e(
          'Error getting available genre seeds: ${e.toString()}\nStack trace:\n$s');
      return [];
    }
  }

  static Future<List<Track>> getSavedTracks(
      {int limit = 20, int offset = 0}) async {
    try {
      if (_accessToken == null) {
        await _getOrRefreshAccessToken();
        if (_accessToken == null) {
          _logger.e('Error getting saved tracks: Could not get access token.');
          return [];
        }
      }

      final Map<String, String> queryParameters = {
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      final uri = Uri.parse('$_baseUrl/me/tracks')
          .replace(queryParameters: queryParameters);
      _logger.i("Fetching saved tracks from URI: $uri");

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && data['items'] is List) {
          final items = data['items'] as List;
          // Each item in the 'items' array for saved tracks contains a 'track' object
          return items
              .where((itemData) => itemData['track'] != null)
              .map((itemData) => Track.fromSpotifyTrack(itemData['track']))
              .toList();
        }
        _logger.w('No items found in saved tracks response: ${response.body}');
        return [];
      }
      _logger.w(
          'Failed to get saved tracks: ${response.statusCode} ${response.body}');
      return [];
    } catch (e, s) {
      _logger
          .e('Error getting saved tracks: ${e.toString()}\nStack trace:\n$s');
      return [];
    }
  }
}
