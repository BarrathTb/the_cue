import 'package:flutter/material.dart';

class ZoomRoute extends PageRouteBuilder {
  final Widget page;

  ZoomRoute({required this.page})
      : super(
    // Duration of transition
    transitionDuration: const Duration(seconds: 1),
    // Animation for route transition
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.fastOutSlowIn,
          ),
        ),
        child: child,
      );
    },
    // Defining how the new screen will be built
    pageBuilder: (context, animation, secondaryAnimation) => page,
  );
}
