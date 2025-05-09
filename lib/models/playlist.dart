class PlaylistModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String uri;

  PlaylistModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.uri,
  });

  factory PlaylistModel.fromSpotifyPlaylist(dynamic playlist) {
    return PlaylistModel(
      id: playlist.id,
      name: playlist.name,
      description: playlist.description ?? '',
      imageUrl: playlist.images.first.url,
      uri: playlist.uri,
    );
  }
}
