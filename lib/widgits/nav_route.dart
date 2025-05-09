import 'package:flutter/material.dart';

class NavRoute extends StatefulWidget {
  final int currentIndex;
  final Function(int) valueChanged;
  final List<BottomNavigationBarItem> items; // Add items parameter

  const NavRoute(
      {super.key,
      required this.currentIndex,
      required this.valueChanged,
      required this.items}); // Require items

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
        items: widget.items, // Use the provided items
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.orange[400],
        backgroundColor: const Color(0xFF212121),
      ),
    );
  }
}
