import 'package:flutter/material.dart';

class RecentPlaylistCard extends StatelessWidget {
  const RecentPlaylistCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });

  final String title;
  final String subtitle;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(14), // adjust amount for desired space between items
      width: 101,
      height: 110,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
              Colors.blueGrey.shade900.withOpacity(0.7), BlendMode.srcOver), // change the blend mode here
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            textAlign: TextAlign.center,
            title,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Source Sans Pro',
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            textAlign: TextAlign.center,
            subtitle,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'Source Sans Pro',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}


class CardList extends StatelessWidget {
  final List<String> titles = ['Title1', 'Title2', 'Title3'];
  final List<String> subtitles = ['Subtitle1', 'Subtitle2', 'Subtitle3'];
  final List<String> images = [
    'assets/images/card_image_one.png',
    'assets/images/card_image_two.png',
    'assets/images/card_image_three.png',
    'assets/images/card_image_four.png',
    'assets/images/card_image_five.png',
    'assets/images/card_image_six.png',

  ];
   CardList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: titles.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return RecentPlaylistCard(
          title: titles[index],
          subtitle: subtitles[index],
          imagePath: images[index],
        );
      },
    );
  }
}

