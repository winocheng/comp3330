import 'package:flutter/material.dart';

// Colors
const Color backgroundColor = Colors.white;
const Color highlightColor1 = Color(0xFFFE5726);
const Color highlightColor2 = Color(0xFF3493D0);
const Color mainColor = Color(0xFF00B8CD);
const Color fontColor = Colors.white;

int questionTime = 1000;

// Custom Components
class NoOverscroll extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
