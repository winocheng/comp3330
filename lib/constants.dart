import 'package:flutter/material.dart';

// Colors
Color backgroundColor = Colors.white;
Color highlightColor1 = const Color(0xFFFE5726);
Color highlightColor2 = const Color(0xFF3493D0);
Color mainColor = const Color(0xFF00B8CD);
Color fontColor = Colors.white;

// Custom Components
class NoOverscroll extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
