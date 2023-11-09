import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  var page_index = 0;
  final question_index = 15;
  var x = -100.0;
  var y = -100.0;

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

  final viewTransformationController = TransformationController();

  @override
  void initState() {
    final zoomFactor = 0.2;
    final xTranslate = 0.0;
    final yTranslate = 0.0;
    viewTransformationController.value.setEntry(0, 0, zoomFactor);
    viewTransformationController.value.setEntry(1, 1, zoomFactor);
    viewTransformationController.value.setEntry(2, 2, zoomFactor);
    viewTransformationController.value.setEntry(0, 3, -xTranslate);
    viewTransformationController.value.setEntry(1, 3, -yTranslate);
    super.initState();
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

class AnswerPage extends StatefulWidget {
  @override
  State<AnswerPage> createState() => _AnswerPageState();
}

class _AnswerPageState extends State<AnswerPage> {
  var question_index;
  var x;
  var y;

  @override
  Widget build(BuildContext context) {
    var state = context.findAncestorStateOfType<_GamePageState>();
    question_index = state?.question_index;

    var image = Image.asset('assets/images/hku_image.jpg');
    x = state?.x;
    y = state?.y;
    

    print("x: " + x.toString() + " y: " + y.toString());
    return InteractiveViewer(
      transformationController: state?.viewTransformationController,
      constrained: false,
      minScale: 0.1,
      maxScale: 3,
      child: GestureDetector(
        // store the position of the tap
        onTapDown: (details) {
          setState(() {
            x = details.localPosition.dx;
            y = details.localPosition.dy;
            state?.x = x;
            state?.y = y;
          });
          print("x: " + x.toString() + " y: " + y.toString());
          
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
