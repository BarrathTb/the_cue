class Album {
  final String id;
  final String name;
  final String uri;
  final String? imageUrl;
  final String artistName; // Albums usually have a primary artist

  Album({
    required this.id,
    required this.name,
    required this.uri,
    this.imageUrl,
    required this.artistName,
  });

  factory Album.fromSpotifyApi(Map<String, dynamic> data) {
    String? imgUrl;
    if (data['images'] != null && (data['images'] as List).isNotEmpty) {
      imgUrl = data['images'][0]['url']; // Typically, first image is suitable
    }

    String mainArtistName = 'Unknown Artist';
    if (data['artists'] != null && (data['artists'] as List).isNotEmpty) {
      mainArtistName = data['artists'][0]['name'] ?? mainArtistName;
    }

    return Album(
      id: data['id'] ?? '',
      name: data['name'] ?? 'Unknown Album',
      uri: data['uri'] ?? '',
      imageUrl: imgUrl,
      artistName: mainArtistName,
    );
  }
}
