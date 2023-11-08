import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  var page_index = 0;
  final question_index = 15;

  var pages = [
    QuestionPage(),
    AnswerPage(),
  ];

  page() {
    if (page_index == 0) {
      return pages[0];
    } else {
      return pages[1];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game'),
        backgroundColor: Colors.blue,
      ),

      // main game page and a bottom navigation bar
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.white,
              child: Center(
                child: page(),
              ),
            ),
          ),
          Container(
            color: Colors.grey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                //two buttons (question, answer) in the bottom navigation bar
                IconButton(
                  color: Colors.white,
                  icon: Icon(Icons.question_mark_rounded),
                  onPressed: () {
                    setState(() {
                      page_index = 0;
                    });
                  },
                ),
                IconButton(
                  color: Colors.white,
                  icon: Icon(Icons.check_circle_rounded),
                  onPressed: () {
                    setState(() {
                      page_index = 1;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QuestionPage extends StatelessWidget {
  var question_index;

  @override
  Widget build(BuildContext context) {
    var state = context.findAncestorStateOfType<_GamePageState>();
    var image = Image.asset('assets/images/circle.png');
    question_index = state?.question_index;
    return Scaffold(
      body: Center(
        child: InteractiveViewer(
          child: image,
          constrained: false,
        ),
      ),
    );
  }
}

class AnswerPage extends StatelessWidget {
  var question_index;
  final x = ValueNotifier<double>(0);
  final y = ValueNotifier<double>(0);

  @override
  Widget build(BuildContext context) {
    var state = context.findAncestorStateOfType<_GamePageState>();
    question_index = state?.question_index;
    var image = Image.asset('assets/images/circle.png');
    print("x: " + x.value.toString() + " y: " + y.value.toString());
    return InteractiveViewer(
      constrained: false,
      child: GestureDetector(
        // store the position of the tap
        onTapDown: (details) {
          x.value = details.localPosition.dx;
          y.value = details.localPosition.dy;
          print("x: " + x.value.toString() + " y: " + y.value.toString());
          
        },
        child: CustomPaint(
          child: image,
          foregroundPainter: CirclePainter(x, y),
        ),
      )
    );
  }
}

class CirclePainter extends CustomPainter {
  ValueNotifier<double> x;
  ValueNotifier<double> y;

  CirclePainter(this.x, this.y): super(repaint: x);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(x.value, y.value), 5, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
