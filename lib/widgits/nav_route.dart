import 'package:flutter/material.dart';

class NavRoute extends StatefulWidget {
  final int currentIndex;
  final Function(int) valueChanged;

  const NavRoute({super.key, required this.currentIndex, required this.valueChanged});

  @override
  NavRouteState createState() => NavRouteState();
}


class NavRouteState extends State<NavRoute> {
  int _currentIndex = 0;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: const Color(0xFF212121),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
        widget.valueChanged(index);
        onTabTapped(index);
        },
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_fill_outlined),
            label: 'Player',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          // Add more icons as per your need
        ],
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.orange[400],
        backgroundColor: const Color(0xFF212121),

      ),
    );
  }
}
