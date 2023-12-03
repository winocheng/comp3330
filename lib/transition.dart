import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hku_guesser/constants.dart';
import 'package:hku_guesser/game_state.dart';
import 'package:hku_guesser/game.dart';
import 'package:hku_guesser/ranking.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class TransitionPage extends StatefulWidget {
  final GameState gameState;
  const TransitionPage({Key? key, required this.gameState}) : super(key: key);

  @override
  State<TransitionPage> createState() => _TransitionPageState();
}

class _TransitionPageState extends State<TransitionPage> {
  @override
  void initState() {
    super.initState();
    widget.gameState.roundNum++;
  }

  @override
  Widget build(BuildContext context) {
    final gameState = widget.gameState;
    if (gameState.roundNum > gameState.totalRound) {
      return Result(gameState: gameState);
    } else {
      return Transition(gameState: gameState);
    }
  }
}


class Transition extends StatelessWidget {
  final GameState gameState;
  const Transition({Key? key, required this.gameState}) : super(key: key);

  void nextRound(BuildContext context) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => GamePage(gameState: gameState)),
        ModalRoute.withName('/'));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
        style: const TextStyle(
          color: fontColor,
          fontFamily: 'Inter',
          height: 0,
        ),
        child: WillPopScope(
            onWillPop: ExitDialogBuilder(context).build,
            child: Container(
              color: mainColor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'You score ${gameState.roundScore} this round!\n'
                    'Total score: ${gameState.totalScore}',
                    style: const TextStyle(fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                  MapLocation(q: gameState.questions[gameState.roundNum - 2]),
                  Text(
                    'Round ${gameState.roundNum} starts in:',
                    style: const TextStyle(fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    child: SizedBox(
                      width: 177,
                      height: 177,
                      child: Countdown(
                        duration: gameState.transitionTime,
                        nextRound: nextRound,
                      ),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      nextRound(context);
                    },
                    child: const Text(
                      "Next Question",
                      style: TextStyle(color: fontColor, fontSize: 20),
                    ),
                  ),
                ],
              ),
            )));
  }
}

class Countdown extends StatefulWidget {
  final int duration; // in seconds
  final Function(BuildContext) nextRound;
  const Countdown({Key? key, required this.duration, required this.nextRound})
      : super(key: key);

  @override
  State<Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  Timer? countdownTimer;
  late Duration _myDuration;

  @override
  void initState() {
    super.initState();
    _myDuration = Duration(seconds: widget.duration);
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  @override
  void dispose() {
    super.dispose();
    countdownTimer!.cancel();
  }

  void setCountDown() {
    setState(() {
      final seconds = _myDuration.inSeconds - 1;
      if (seconds < 0) {
        print("Next round");
        widget.nextRound(context);
      } else {
        _myDuration = Duration(seconds: seconds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final seconds = _myDuration.inSeconds.toString();
    return Stack(
      alignment: const Alignment(0, -0.3),
      children: [
        Image.asset('assets/images/location.png'),
        Text(
            seconds,
          style: const TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.w700,
            ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}


class Result extends StatelessWidget {
  final GameState gameState;
  const Result({Key? key, required this.gameState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final resultText = gameState.gameType == GameState.general
        //  Normal game finished text
        ? <Widget>[
            const Text('Game Finished!',
                style: TextStyle(
                    fontFamily: 'LuckiestGuy',
                    color: highlightColor1,
                    fontSize: 45)),
            Text('You scored ${gameState.roundScore} this round!',
                style: const TextStyle(fontSize: 22, height: 2)),
            MapLocation(q: gameState.questions[gameState.roundNum - 2]),
            Text(
                'In ${gameState.totalRound} rounds, you scored ${gameState.totalScore}!',
                style: const TextStyle(fontSize: 22)),
          ]
        //  Daily challenge finished text
        : <Widget>[
            const Text('You have completed\nthe daily challenge!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'LuckiestGuy',
                    color: highlightColor1,
                    fontSize: 32)),
            Text('You scored ${gameState.totalScore}!',
                style: const TextStyle(fontSize: 22, height: 2)),
            MapLocation(q: gameState.questions[gameState.roundNum - 2]),
          ];

    return DefaultTextStyle(
        style: const TextStyle(
          color: fontColor,
          fontFamily: 'Inter',
          height: 2,
        ),
        child: Container(
            color: mainColor,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ...resultText,
                  Container(
                      margin: const EdgeInsets.only(top: 50),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.all(5.0),
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Return",
                                style:
                                    TextStyle(color: fontColor, fontSize: 20),
                              ),
                            ),
                            const SizedBox(width: 20.0),
                            TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.all(5.0),
                                  backgroundColor: Colors.green,
                                ),
                                onPressed: () {
                                  _rankingDialogBuilder(context).then((name) {
                                    if (name == null) {
                                      return;
                                    }
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => RankingPage(
                                                gameType: gameState.gameType,
                                                name: name,
                                                score: gameState.totalScore)));
                                  });
                                },
                                child: const Text(
                                  "Upload my score",
                                  style:
                                      TextStyle(color: fontColor, fontSize: 20),
                                )),
                          ])
                  ),
                ])));
  }

  Future<String?> _rankingDialogBuilder(BuildContext context) {
    TextEditingController textController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Player name'),
          content: TextField(
            controller: textController,
            maxLength: 16,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Enter your name:',
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.pop(context, textController.text);
              },
            )
          ],
        );
      },
    );
  }
}


class MapLocation extends StatelessWidget {
  final Question q;
  MapLocation({Key? key, required this.q}) : super(key: key);

  final width = 500; // Width of the crop region
  final height = 500; // Height of the crop region
  final GlobalKey _boxKey = GlobalKey();

  Future<img.Image> _cropImage(double x, double y) async {
    int toPosInt(double n) => n < 0 ? 0 : n.toInt();

    List<int> imageBytes = await rootBundle
        .load('assets/images/hku_image.jpg')
        .then((data) => data.buffer.asUint8List());

    img.Image? originalImage = img.decodeImage(imageBytes);

    int dx = toPosInt(x - width / 2);
    int dy = toPosInt(y - height / 2);
    return img.copyCrop(originalImage!, dx, dy, width, height);
  }

  CirclePainter paintCircle(double x, double y) {
    final RenderBox renderBox =
        _boxKey.currentContext!.findRenderObject() as RenderBox;
    double toOffset(double n, double dn) => n - dn < 0 ? n : dn;

    double dx = toOffset(x, width / 2) * renderBox.size.width / width;
    double dy = toOffset(y, height / 2) * renderBox.size.height / height;

    return CirclePainter(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    final jsonData = jsonDecode(q.jsonText);
    final x = jsonData['x-coordinate'];
    final y = jsonData['y-coordinate'];
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: SizedBox(
            key: _boxKey,
            width: 250,
            height: 250,
            child: FutureBuilder<img.Image>(
                future: _cropImage(x, y),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasData) {
                    return CustomPaint(
                        foregroundPainter: paintCircle(x, y),
                        child: Image.memory(
                            Uint8List.fromList(img.encodeJpg(snapshot.data!))));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return const CircularProgressIndicator();
                  }
                })));       
  }
}
