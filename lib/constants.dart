import 'package:flutter/material.dart';

// Colors
const Color backgroundColor = Colors.white;
const Color highlightColor1 = Color(0xFFFE5726);
const Color highlightColor2 = Color(0xFF3493D0);
const Color mainColor = Color(0xFF00B8CD);
const Color fontColor = Colors.white;
const String serverIP = "http://172.20.0.3:9090";

// Custom Components
class NoOverscroll extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class CirclePainter extends CustomPainter {
  var x;
  var y;

  CirclePainter(this.x, this.y);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x, y), 10, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
