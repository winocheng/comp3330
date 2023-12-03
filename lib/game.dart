import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hku_guesser/constants.dart';
import 'package:hku_guesser/transition.dart';
import 'package:hku_guesser/game_state.dart';

class GamePage extends StatefulWidget {
  final GameState gameState;
  const GamePage({super.key, required this.gameState});

  @override
  State<StatefulWidget> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late GameState gameState;
  late List<Widget> pages;
  var _pageIndex = 0;
  Answer playerAnswer = Answer(x: -100.0, y: -100.0, floor: 0);
  TransformationController mapController = TransformationController();

  @override
  void initState() {
    super.initState();
    const zoomFactor = 0.31;
    const xTranslate = 32.0;
    const yTranslate = 50.0;
    mapController.value.setEntry(0, 0, zoomFactor);
    mapController.value.setEntry(1, 1, zoomFactor);
    mapController.value.setEntry(2, 2, zoomFactor);
    mapController.value.setEntry(0, 3, -xTranslate);
    mapController.value.setEntry(1, 3, -yTranslate);
    gameState = widget.gameState;
    pages = [
      QuestionPage(gameState: gameState),
      AnswerPage(
          gameState: gameState,
          answer: playerAnswer,
          controller: mapController),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: ExitDialogBuilder(context).build,
        child: Scaffold(
          appBar: AppBar(
            title: Text(gameState.gameType == GameState.daily
                ? "Daily Challenge"
                : "Round ${gameState.roundNum}"),
            backgroundColor: mainColor,
          ),

          // main game page and a bottom navigation bar
          body: Column(
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.only(left: 10.0),
                  color: highlightColor1,
                  child: Row(children: [
                    Text(
                      '${gameState.roundNum}/${gameState.totalRound}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Expanded(
                        child: Text(
                      'Score: ${gameState.totalScore}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    )),
                    TimerWidget(gameState: widget.gameState),
                  ])),
              Expanded(child: pages[_pageIndex]),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
              currentIndex: _pageIndex,
              onTap: (int index) {
                setState(() {
                  _pageIndex = index;
                });
              },
              iconSize: 36.0,
              selectedItemColor: highlightColor1,
              unselectedItemColor: highlightColor2,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.question_mark_rounded),
                  label: "Question",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle_rounded),
                  label: "Map",
                ),
              ]),
        ));
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
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => TransitionPage(
                        gameState: widget.gameState,
                      )),
              ModalRoute.withName('/'));
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
    return Container(
        height: 30,
        width: 70,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 2.0,
                blurRadius: 3.0,
                offset: Offset(0, 3),
              )
            ]),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.alarm),
          const SizedBox(width: 5.0),
          Text(
            "$_start",
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
          ),
        ]));
  }
}


class QuestionPage extends StatefulWidget {
  final GameState gameState;
  const QuestionPage({super.key, required this.gameState});

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  final viewTransformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    const zoomFactor = 1.0;
    const xTranslate = 0.0;
    const yTranslate = 200.0;
    viewTransformationController.value.setEntry(0, 0, zoomFactor);
    viewTransformationController.value.setEntry(1, 1, zoomFactor);
    viewTransformationController.value.setEntry(2, 2, zoomFactor);
    viewTransformationController.value.setEntry(0, 3, -xTranslate);
    viewTransformationController.value.setEntry(1, 3, -yTranslate);
  }

  @override
  Widget build(BuildContext context) {
    var imagefile = File(
        widget.gameState.questions[widget.gameState.roundNum - 1].imagePath);
    var image = Image.file(
      imagefile,
      height: 900,
    );
    return Center(
        child: InteractiveViewer(
      transformationController: viewTransformationController,
      minScale: 0.01,
      constrained: false,
      child: image,
      )
    );
  }
}


class AnswerPage extends StatefulWidget {
  final GameState gameState;
  final Answer answer;
  final TransformationController controller;
  const AnswerPage(
      {super.key,
      required this.gameState,
      required this.answer,
      required this.controller});

  @override
  State<AnswerPage> createState() => _AnswerPageState();
}

class _AnswerPageState extends State<AnswerPage> {
  late GameState state;
  late Answer playerAnswer;

  static const List<(String, int)> floorOptions = [
    ("G/F", 0),
    ("1/F", 1),
    ("2/F", 2),
    ("3/F", 3),
    ("4/F", 4),
    ("5/F+", 5),
  ];

  void updateScore() {
    var score = calculateScore(state, playerAnswer);
    state.roundScore = score;
    state.totalScore += score;
  }

  static int calculateScore(GameState state, Answer answer) {
    var jsonData = jsonDecode(state.questions[state.roundNum - 1].jsonText);
    var tx = jsonData['x-coordinate'];
    var ty = jsonData['y-coordinate'];
    var tf = jsonData['floor'];
    if (tf == "G") {
      tf = 0;
    }

    int base = 500; // base points

    // distance penalty: distance / 2
    var dx = (tx - answer.x).abs();
    var dy = (ty - answer.y).abs();
    double dp = pow(pow(dx, 2) + pow(dy, 2), 0.5) / 2;
    dp = dp > 500 ? 500 : dp;

    // floor bonus: if correct floor then +100 points
    int fp = 0;
    if (answer.floor == tf) {
      fp = 100;
    }

    // time factor:  % of remaining time + 0.5 -> [0.5 - 1.5]
    double tp = state.remainingTime / state.roundTime + 0.5;

    return ((base - dp + fp) * tp).toInt();
  }

  @override
  void initState() {
    super.initState();
    state = widget.gameState;
    playerAnswer = widget.answer;
  }

  @override
  Widget build(BuildContext context) {
    // print('x: ${playerAnswer.x}, y: ${playerAnswer.y}');
    return Stack(
      children: <Widget>[
        InteractiveViewer(
        transformationController: widget.controller,
          constrained: false,
          minScale: 0.1,
          maxScale: 3,
          child: GestureDetector(
            // store the position of the tap
            onTapUp: (details) {
              setState(() {
              playerAnswer.x = details.localPosition.dx;
              playerAnswer.y = details.localPosition.dy;
              });
            // print(widget.controller.value);
            },
            child: CustomPaint(
            foregroundPainter: CirclePainter(playerAnswer.x, playerAnswer.y),
            child: Image.asset('assets/images/hku_image.jpg'),
            ),
          ),
        ),
      if (playerAnswer.x >= 0)
          Align(
            alignment: Alignment.bottomRight,
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
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
                      )
                    ],
                  ),
                  child: Center(
                      child: DropdownButton(
                    isDense: true,
                    borderRadius: BorderRadius.circular(5),
                    value: floorOptions[playerAnswer.floor].$2,
                    items: floorOptions
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
                        playerAnswer.floor = newValue!;
                      });
                    },
                  ))),
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
                      )
                    ],
                  ),
                  child: GestureDetector(
                      onTap: () {
                        // print("Submit");
                        updateScore();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    TransitionPage(gameState: state)));
                      },
                      child: const Center(
                          child: Text(
                        'Submit',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )))
                ),
            ]))
    ]
    );
  }
}

class Answer {
  double x;
  double y;
  int floor;

  Answer({
    required this.x,
    required this.y,
    required this.floor,
  });
}
