import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hku_guesser/image.dart';
import 'package:hku_guesser/question_database.dart';
import 'constants.dart';

class GamePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  var page_index = 0;
  final question_index = 15;
  var x = -100.0;
  var y = -100.0;
  var floor = 0;

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
    const zoomFactor = 0.2;
    const xTranslate = 0.0;
    const yTranslate = 0.0;
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
        title: const Text('Game'),
        backgroundColor: mainColor,
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
                  icon: const Icon(Icons.question_mark_rounded),
                  onPressed: () {
                    setState(() {
                      page_index = 0;
                    });
                  },
                ),
                IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.check_circle_rounded),
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

class QuestionPage extends StatefulWidget {
  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  var question_index;
  List<Question> questions = [];
  var n = 1;
  Future<void> _asyncWork = Future<void>.value(null);


  @override
  void initState() {
    super.initState();
    _asyncWork = _performAsyncWork();
  }

   Future<void> _performAsyncWork() async {
    final check = await QuestionDatabase.instance.getQuestions();
    if(check.isEmpty){
      await QuestionDatabase.instance.insertQuestion(jsonEncode({"x-coordinate": "1250.6396965865638","y-coordinate": "2192.9494311002054","floor": "G"}) , await saveImageToStorageFromAssets('assets/images/image1.jpg', n));
    }
    someAsyncOperation();
    setState(() {});
  }
  Future<void> someAsyncOperation() async {
    final loadedQuestions = await QuestionDatabase.instance.getQuestions();
      setState(() {
        questions = loadedQuestions;
      }
      );
  }

  


   @override
    Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _asyncWork,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while the work is in progress
            return const Center(child: CircularProgressIndicator());
          } else {
            var state = context.findAncestorStateOfType<_GamePageState>();
            var image = Image.file(File(questions[0].imagePath));
            question_index = state?.question_index;
            return Scaffold(
              body: Center(
                child: InteractiveViewer(
                  constrained: false,
                  child: image,
                ),
              ),
            );
          }
        },
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

    const List<(String, int)> floor_options = [
      ("G/F", 0),
      ("1/F", 1),
      ("2/F", 2),
      ("3/F", 3),
      ("4/F", 4),
      ("5/F+", 5),
    ];

    var image = Image.asset('assets/images/hku_image.jpg');
    x = state?.x;
    y = state?.y;

    print("x: " + x.toString() + " y: " + y.toString());
    return Stack(
      children: <Widget>[
        InteractiveViewer(
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
              foregroundPainter: CirclePainter(x, y),
              child: image,
            ),
          ),
        ),
        if (state!.x >= 0)
          Align(
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      width: 80,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: DropdownButton(
                          isDense: true,
                          borderRadius: BorderRadius.circular(5),
                          value: floor_options[state.floor].$2,
                          items: floor_options
                              .map((value) {
                                return DropdownMenuItem<int>(
                                  value: value.$2,
                                  alignment: Alignment.centerRight,
                                  child: Text(value.$1),
                                );
                              })
                              .toList()
                              .reversed
                              .toList(),
                          onChanged: (int? newValue) {
                            setState(() {
                              state.floor = newValue!;
                            });
                          },
                        ),
                      )),
                  Container(
                    //submit button
                    margin: const EdgeInsets.only(bottom: 5),
                    width: 80,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () {
                        // TODO: submit the answer
                        print("submit");
                      },
                      child: const Center(
                        child: Text(
                          'Submit',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  )
                ],
              ))
      ],
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

