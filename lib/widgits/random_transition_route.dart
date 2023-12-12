import 'package:flutter/material.dart';

import 'dart:math';
import 'package:the_cue/widgits/zoom_route.dart';
import 'package:the_cue/widgits/slide_route.dart';



class RandomTransitionRoute extends PageRouteBuilder {
  final Widget page;

  // Make it static and don't pass 'page' here
  static final List<Function> animations = [
        (Widget page) => ZoomRoute(page: page),
        (Widget page) => SlideRoute(page: page),

    // Add more animations here,
  ];

  RandomTransitionRoute({required this.page})
      : super(
    transitionDuration: const Duration(seconds: 1),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Generate a random index between 0 and length of animations list.
      int randomIndex = Random().nextInt(animations.length);
      // Use the function at 'randomIndex' to create the appropriate route
      return animations[randomIndex](page).transitionsBuilder!(context, animation, secondaryAnimation, child);
    },
    pageBuilder: (context, animation, secondaryAnimation) => page,
  );
}


