// song.dart

class Song {
  String image;
  String artist;
  String title;

  Song({required this.image, required this.artist, required this.title});
}


const List<Map<String, String>> songsData = [
  {
    'image': 'assets/images/playlist_card_one.png',
    'title': 'Blinding Lights',
    'artist': 'The Weeknd'
  },
  {
    'image': 'assets/images/playlist_card_two.png',
    'title': 'Save Your Tears',
    'artist': 'The Weeknd & Ariana Grande'
  },
  {
    'image': 'assets/images/playlist_card_three.png',
    'title': 'Good 4 U',
    'artist': 'Olivia Rodrigo'
  },
  {
    'image': 'assets/images/playlist_card_four.png',
    'title': 'Peaches',
    'artist': 'Justin Bieber, Daniel Caesar & Giveon'
  },
  {
    'image': 'assets/images/playlist_card_five.png',
    'title': 'Stay',
    'artist': 'The Kid LAROI & Justin Bieber'
  },
  {
    'image': 'assets/images/card_image_one.png',
    'title': 'Levitating',
    'artist': 'Dua Lipa Featuring DaBaby'
  },
  {
    'image': 'assets/images/card_image_two.png',
    'title': 'Kiss Me More',
    'artist': 'Doja Cat Featuring SZA'
  },
  {
    'image': 'assets/images/card_image_three.png',
    'title': 'Astronaut In The Ocean',
    'artist': 'Masked Wolf'
  },
  {
    'image': 'assets/images/card_image_four.png',
    'title': 'Montero (Call Me By Your Name)',
    'artist': 'Lil Nas X'
  },
  {
    'image': 'assets/images/card_image_five.png',
    'title': 'Rapstar',
    'artist': 'Polo G'
  },
  {
    'image': 'assets/images/card_image_six.png',
    'title': 'Leave The Door Open',
    'artist': 'Silk Sonic (Bruno Mars & Anderson .Paak)'
  },
  {
    'image': 'assets/images/the_cue_cali.png',
    'title': 'Drivers License',
    'artist': 'Olivia Rodrigo'
  },
];

List<Song> songs = songsData.map((map) => Song(
  image: map['image']!,
  title: map['title']!,
  artist: map['artist']!,
)).toList();

