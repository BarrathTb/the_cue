import 'package:flutter/material.dart';

class RotateRoute extends PageRouteBuilder {
  final Widget page;

  RotateRoute({required this.page})
      : super(
    transitionDuration: const Duration(seconds: 1),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return RotationTransition(
        turns: Tween<double>(
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
    pageBuilder: (context, animation, secondaryAnimation) => page,
  );
}
