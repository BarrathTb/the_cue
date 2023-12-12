import 'package:flutter/material.dart';

class PlaylistCard extends StatelessWidget {
  const PlaylistCard({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
  });

  final String title;
  final String description;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      width: 157,
      height: 100,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
              Colors.blueGrey.shade900.withOpacity(0.7),
              BlendMode.srcOver
          ),
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),  // add some padding here
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,  // align text to the start
          children: <Widget>[
            Text(

              title,
              textAlign: TextAlign.center,

              style: const TextStyle(
                color: Colors.white,  // change this as needed
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            Text(

              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 12

              ),  // change this as needed
            ),
          ],
        ),
      ),
    );
  }
}

class CardList extends StatelessWidget {
  final List<String> titles = ['Title1', 'Title2', 'Title3'];
  final List<String> descriptions = ['Description1', 'Description2', 'Description3'];
  final List<String> imagePaths = ['imagePath1', 'imagePath2', 'imagePath3'];

  CardList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: titles.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: PlaylistCard(
            title: titles[index],
            description: descriptions[index],
            imagePath: imagePaths[index],
          ),
        );
      },
    );
  }
}

