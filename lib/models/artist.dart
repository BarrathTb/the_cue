class Artist {
  final String id;
  final String name;
  final String uri;
  final String? imageUrl; // Artists might not always have images, or multiple

  Artist({
    required this.id,
    required this.name,
    required this.uri,
    this.imageUrl,
  });

  factory Artist.fromSpotifyApi(Map<String, dynamic> data) {
    String? imgUrl;
    if (data['images'] != null && (data['images'] as List).isNotEmpty) {
      imgUrl = data['images'][0]['url'];
    }
    return Artist(
      id: data['id'] ?? '',
      name: data['name'] ?? 'Unknown Artist',
      uri: data['uri'] ?? '',
      imageUrl: imgUrl,
    );
  }
}
