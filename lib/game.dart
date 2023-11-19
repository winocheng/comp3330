import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hku_guesser/sync_db.dart';
import 'package:hku_guesser/transition.dart';
import 'package:hku_guesser/image.dart';
import 'package:hku_guesser/question_database.dart';
import 'package:hku_guesser/game_state.dart';
import 'constants.dart';
import 'dart:async';
import 'dart:math';

class GamePage extends StatefulWidget {
  final GameState gameState;
  const GamePage({Key? key, required this.gameState}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late GameState gameState;
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
    super.initState();
    const zoomFactor = 0.31;
    const xTranslate = 32.0;
    const yTranslate = 50.0;
    viewTransformationController.value.setEntry(0, 0, zoomFactor);
    viewTransformationController.value.setEntry(1, 1, zoomFactor);
    viewTransformationController.value.setEntry(2, 2, zoomFactor);
    viewTransformationController.value.setEntry(0, 3, -xTranslate);
    viewTransformationController.value.setEntry(1, 3, -yTranslate);
    gameState = widget.gameState;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Round ${widget.gameState.roundNum}'),
        backgroundColor: mainColor,
      ),

      // main game page and a bottom navigation bar
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.white,
              child: Center(
                child: Stack(
                  children: <Widget>[
                    page(),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: TimerWidget(
                        gameState: widget.gameState,
                      ),
                    ),
                  ],
                ),
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
  var n = 1;
  Future<void> _asyncWork = Future<void>.value(null);

  final viewTransformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _asyncWork = _performAsyncWork();
    const zoomFactor = 1.0;
    const xTranslate = 0.0;
    const yTranslate = 200.0;
    viewTransformationController.value.setEntry(0, 0, zoomFactor);
    viewTransformationController.value.setEntry(1, 1, zoomFactor);
    viewTransformationController.value.setEntry(2, 2, zoomFactor);
    viewTransformationController.value.setEntry(0, 3, -xTranslate);
    viewTransformationController.value.setEntry(1, 3, -yTranslate);
  }

  Future<void> _performAsyncWork() async {
    final check = await QuestionDatabase.instance.getQuestions();
    if (check.isEmpty) {
      await initailize_question(n);
    } else {
      await updateQuestion();
    }

    await someAsyncOperation();
    setState(() {});
  }

  Future<void> someAsyncOperation() async {
    if (!context.findAncestorStateOfType<_GamePageState>()!.gameState.shuffle) {
      final loadedQuestions = await QuestionDatabase.instance.getQuestions();
      loadedQuestions.shuffle();
      setState(() {
        context.findAncestorStateOfType<_GamePageState>()!.gameState.questions =
            loadedQuestions;
        context.findAncestorStateOfType<_GamePageState>()!.gameState.shuffle =
            true;
      });
    }
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
            var imagefile = File(state!.gameState.questions[state.gameState.roundNum - 1].imagePath);
            var image = Image.file(imagefile,height: 900,);
            question_index = state.question_index;
            return Scaffold(
              body: Center(
                child: InteractiveViewer(
                  transformationController: viewTransformationController,
                  minScale: 0.01,
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

  void calculateScore(GameState gameState, var gameFloor) {
    var base = 1000;
    var jsonData =
        jsonDecode(gameState.questions[gameState.roundNum - 1].jsonText);
    var xCoordinate = jsonData['x-coordinate'];
    var yCoordinate = jsonData['y-coordinate'];
    var floor = jsonData['floor'];
    var xp = (xCoordinate - x).abs() / 10;
    var yp = (yCoordinate - y).abs() / 10;
    var fp;
    if(floor == "G"){
      floor = 0;
    }
    if (gameFloor == floor) {
      fp = 100;
    } else {
      fp = -100;
    }
    gameState.roundScore =
        ((base - xp - yp + fp) * (gameState.remainingTime / 100)).toInt();
    gameState.totalScore += gameState.roundScore;
  }

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
            onTapUp: (details) {
              setState(() {
                x = details.localPosition.dx;
                y = details.localPosition.dy;
                state?.x = x;
                state?.y = y;
              });
              print("x: " + x.toString() + " y: " + y.toString());
              // print(state?.viewTransformationController.value);
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
                        print("submit");
                        calculateScore(state.gameState, state.floor);
                        print(state.gameState.questions.length);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TransitionPage(
                                      gameState: state.gameState,
                                    )));
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

class TimerWidget extends StatefulWidget {
  final GameState gameState;

  const TimerWidget({Key? key, required this.gameState}) : super(key: key);

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late Timer _timer;
  late int _start;

  @override
  void initState() {
    super.initState();
    _start = widget.gameState.roundTime;
    startTimer();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          _timer.cancel();
          widget.gameState.roundScore = 0;
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => TransitionPage(
                        gameState: widget.gameState,
                      )));
        } else {
          setState(() {
            _start--;
            widget.gameState.remainingTime = _start;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topRight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
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
              alignment: Alignment.center,
              child: Text(
                "$_start",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black),
              ),
            ),
          ],
        ));
  }
}
