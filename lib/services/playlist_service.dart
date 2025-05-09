import 'dart:convert';
import 'dart:math';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

import '../models/playlist.dart';
import '../models/track.dart'; // Import Track model

final Logger _logger = Logger();

class PlaylistService {
  static Future<List<PlaylistModel>> getUserPlaylists() async {
    try {
      final token = await SpotifySdk.getAccessToken(
        clientId: dotenv.env['SPOTIFY_CLIENT_ID']!,
        redirectUrl: dotenv.env['REDIRECT_URL']!,
        scope: 'playlist-read-private',
      );

      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/playlists'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['items'] as List).map((playlist) {
          String imageUrl = 'assets/images/default_image.png'; // Default image
          if (playlist['images'] != null &&
              (playlist['images'] as List).isNotEmpty) {
            imageUrl = playlist['images'][0]['url'] ?? imageUrl;
          }
          return PlaylistModel(
            id: playlist['id'],
            name: playlist['name'],
            description: playlist['description'] ?? '',
            imageUrl: imageUrl,
            uri: playlist['uri'],
          );
        }).toList();
      }
      return [];
    } catch (e) {
      _logger.e('Failed to fetch playlists: $e');
      return [];
    }
  }

  static Future<List<Track>> getPlaylistTracks(String playlistId) async {
    try {
      // Get access token
      final token = await SpotifySdk.getAccessToken(
        clientId: dotenv.env['SPOTIFY_CLIENT_ID']!,
        redirectUrl: dotenv.env['REDIRECT_URL']!,
        scope:
            'playlist-read-private', // Scope for reading user's private playlists
      );

      if (token.isEmpty) {
        // Check if token is empty
        _logger.e('Failed to get playlist tracks: No access token obtained.');
        return [];
      }

      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/playlists/$playlistId/tracks'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List?; // Make items nullable
        if (items == null) {
          _logger
              .w('No items found in playlist tracks response for $playlistId');
          return [];
        }
        return items
            .map((item) {
              // The track object is nested inside 'track' for playlist items
              if (item != null &&
                  item['track'] != null &&
                  item['track']['type'] == 'track') {
                return Track.fromSpotifyTrack(item['track']);
              }
              return null; // Or handle non-track items, or items where 'track' is null
            })
            .where((track) => track != null)
            .cast<Track>()
            .toList();
      }
      _logger.w(
          'Failed to fetch playlist tracks: ${response.statusCode} ${response.body}');
      return [];
    } catch (e, s) {
      _logger
          .e('Error fetching playlist tracks for $playlistId: $e\nStack: $s');
      return [];
    }
  }

  static Future<List<PlaylistModel>> getFeaturedPlaylists({
    int limit = 5,
    String? country,
    String? locale,
    String? timestamp,
  }) async {
    try {
      _logger.i('Fetching featured playlists with limit: $limit');

      final token = await SpotifySdk.getAccessToken(
          clientId: dotenv.env['SPOTIFY_CLIENT_ID']!,
          redirectUrl: dotenv.env['REDIRECT_URL']!,
          scope: 'user-read-private,playlist-read-public');

      // Log token (partially masked for security)
      final maskedToken = token.length > 10
          ? '${token.substring(0, 5)}...${token.substring(token.length - 5)}'
          : 'Invalid token';
      _logger.d('Got access token: $maskedToken');

      // Build query parameters
      final queryParams = {
        'limit': limit.toString(),
        if (country != null) 'country': country,
        if (locale != null) 'locale': locale,
        if (timestamp != null) 'timestamp': timestamp,
      };
      _logger.d('Query parameters: $queryParams');

      final uri = Uri.https(
          'api.spotify.com', '/v1/browse/featured-playlists', queryParams);
      _logger.d('Request URI: $uri');

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      _logger.d('Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        _logger.d('Response body: ${response.body}');
        final data = json.decode(response.body);

        // Log message title if available
        if (data['message'] != null) {
          _logger.i('Featured playlists message: ${data['message']}');
        }

        // Featured playlists are nested under 'playlists' object
        final playlistsData = data['playlists'];
        _logger.d(
            'Playlists data: ${playlistsData.toString().substring(0, min(100, playlistsData.toString().length))}...');
        _logger.i(
            'Found ${(playlistsData['items'] as List).length} featured playlists');

        final playlists = (playlistsData['items'] as List).map((playlist) {
          String imageUrl = 'assets/images/default_image.png'; // Default image
          if (playlist['images'] != null &&
              (playlist['images'] as List).isNotEmpty) {
            imageUrl = playlist['images'][0]['url'] ?? imageUrl;
          }

          final playlistModel = PlaylistModel(
            id: playlist['id'],
            name: playlist['name'],
            description: playlist['description'] ?? '',
            imageUrl: imageUrl,
            uri: playlist['uri'],
          );

          _logger.d(
              'Processed playlist: ${playlistModel.name} (${playlistModel.id})');
          return playlistModel;
        }).toList();

        _logger
            .i('Successfully processed ${playlists.length} featured playlists');
        return playlists;
      }

      _logger.w(
          'Failed to fetch featured playlists: ${response.statusCode} ${response.body}');
      return [];
    } catch (e, s) {
      _logger.e('Error fetching featured playlists: $e\nStack: $s');
      return [];
    }
  }
}
