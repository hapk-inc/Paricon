import 'package:flutter/material.dart';

class ShadedLine extends StatelessWidget {
  const ShadedLine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white70,
            Colors.white54,
            Colors.white30,
            Colors.white30,
            Colors.white12,
            Colors.transparent
          ],
        ).createShader(bounds),
        child: Divider(
          color: Colors.white60,
          thickness: 4,
          indent: 16,
        ),
      ),
    );
  }
}
