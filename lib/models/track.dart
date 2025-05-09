// // track.dart
//
// class Song {
//   String image;
//   String artist;
//   String title;
//
//   Song({required this.image, required this.artist, required this.title});
// }
//
//
// const List<Map<String, String>> songsData = [
//   {
//     'image': 'assets/images/playlist_card_one.png',
//     'title': 'Blinding Lights',
//     'artist': 'The Weeknd'
//   },
//   {
//     'image': 'assets/images/playlist_card_two.png',
//     'title': 'Save Your Tears',
//     'artist': 'The Weeknd & Ariana Grande'
//   },
//   {
//     'image': 'assets/images/playlist_card_three.png',
//     'title': 'Good 4 U',
//     'artist': 'Olivia Rodrigo'
//   },
//   {
//     'image': 'assets/images/playlist_card_four.png',
//     'title': 'Peaches',
//     'artist': 'Justin Bieber, Daniel Caesar & Giveon'
//   },
//   {
//     'image': 'assets/images/playlist_card_five.png',
//     'title': 'Stay',
//     'artist': 'The Kid LAROI & Justin Bieber'
//   },
//   {
//     'image': 'assets/images/card_image_one.png',
//     'title': 'Levitating',
//     'artist': 'Dua Lipa Featuring DaBaby'
//   },
//   {
//     'image': 'assets/images/card_image_two.png',
//     'title': 'Kiss Me More',
//     'artist': 'Doja Cat Featuring SZA'
//   },
//   {
//     'image': 'assets/images/card_image_three.png',
//     'title': 'Astronaut In The Ocean',
//     'artist': 'Masked Wolf'
//   },
//   {
//     'image': 'assets/images/card_image_four.png',
//     'title': 'Montero (Call Me By Your Name)',
//     'artist': 'Lil Nas X'
//   },
//   {
//     'image': 'assets/images/card_image_five.png',
//     'title': 'Rapstar',
//     'artist': 'Polo G'
//   },
//   {
//     'image': 'assets/images/card_image_six.png',
//     'title': 'Leave The Door Open',
//     'artist': 'Silk Sonic (Bruno Mars & Anderson .Paak)'
//   },
//   {
//     'image': 'assets/images/the_cue_cali.png',
//     'title': 'Drivers License',
//     'artist': 'Olivia Rodrigo'
//   },
// ];
//
// List<Song> songs = songsData.map((map) => Song(
//   image: map['image']!,
//   title: map['title']!,
//   artist: map['artist']!,
// )).toList();
//
class Track {
  final String id;
  final String uri;
  final String imageUrl;
  final String artist;
  final String title;
  final int duration;
  final String? previewUrl; // Added for preview functionality

  Track({
    required this.id,
    required this.uri,
    required this.imageUrl,
    required this.artist,
    required this.title,
    required this.duration,
    this.previewUrl,
  });

  factory Track.fromSpotifyTrack(dynamic trackData) {
    // Safely access nested data from the JSON map
    String imageUrl = 'assets/images/default_image.png'; // Default image
    if (trackData['album'] != null &&
        trackData['album']['images'] != null &&
        (trackData['album']['images'] as List).isNotEmpty) {
      imageUrl = trackData['album']['images'][0]['url'] ?? imageUrl;
    }

    String artistName = 'Unknown Artist';
    if (trackData['artists'] != null &&
        (trackData['artists'] as List).isNotEmpty) {
      artistName = trackData['artists'][0]['name'] ?? artistName;
    }

    return Track(
      id: trackData['id'] ?? 'unknown_id',
      uri: trackData['uri'] ?? '',
      imageUrl: imageUrl,
      artist: artistName,
      title: trackData['name'] ?? 'Unknown Title',
      duration: trackData['duration_ms'] ?? 0,
      previewUrl: trackData['preview_url'], // Get preview_url
    );
  }
}
