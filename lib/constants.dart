import 'package:flutter/material.dart';

// Colors
const Color backgroundColor = Colors.white;
const Color highlightColor1 = Color(0xFFFE5726);
const Color highlightColor2 = Color(0xFF3493D0);
const Color mainColor = Color(0xFF00B8CD);
const Color fontColor = Colors.white;
const String serverIP = "http://winoc3330.ap-southeast-1.elasticbeanstalk.com";
//const String serverIP = "http://192.168.1.254:9090";
const String timeZoneName = 'Asia/Hong_Kong';

// Custom Components
class NoOverscroll extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class CirclePainter extends CustomPainter {
  final double x;
  final double y;

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

class ExitDialogBuilder {
  final BuildContext context;
  const ExitDialogBuilder(this.context);

  Future<bool> build() async {
    return (await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Quit?'),
              content: const Text('Do you want to exit the current game?'),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: const Text('No'),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: const Text('Yes'),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                ),
              ],
            );
          },
        )) ??
        false;
  }
}
