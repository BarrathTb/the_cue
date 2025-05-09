import 'package:flutter/material.dart';

class SectionHeading extends StatelessWidget {
  final String heading;

  const SectionHeading({
    super.key,
    required this.heading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        heading,
        style: const TextStyle(
          color: Colors.white, // defined color #ffffff
          fontSize: 16, // defined font size 20px
          fontFamily: "Source Sans Pro", // defined font family
          fontWeight: FontWeight.w600, // defined font weight 600
          height: 1.5, // (30/20), gives the lineHeight of about 30px
        ),
      ),
    );
  }
}
