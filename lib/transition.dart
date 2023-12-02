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
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => GamePage(gameState: gameState)));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
        style: const TextStyle(
          color: fontColor,
          fontFamily: 'Inter',
          height: 0,
        ),
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
                style: TextStyle(fontSize: 25),
                textAlign: TextAlign.center,
              ),
              MapLocation(q: gameState.questions[gameState.roundNum - 2]),
              Text(
                'Round ${gameState.roundNum} starts in:',
                style: TextStyle(fontSize: 25),
                textAlign: TextAlign.center,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 15),
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
                child: Text(
                  "Next Question",
                  style: TextStyle(color: fontColor, fontSize: 20),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  print("Next round");
                  nextRound(context);
                },
              ),
            ],
          ),
        ));
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
        Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
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
      alignment: Alignment(0, -0.3),
      children: [
        Image.asset('assets/images/location.png'),
        Text(
            seconds,
            style: TextStyle(
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
            Text('Game Finished!',
                style: TextStyle(
                    fontFamily: 'LuckiestGuy',
                    color: highlightColor1,
                    fontSize: 45)),
            Text('You scored ${gameState.roundScore} this round!',
                style: TextStyle(fontSize: 22, height: 2)),
            MapLocation(q: gameState.questions[gameState.roundNum - 2]),
            Text(
                'In ${gameState.totalRound} rounds, you scored ${gameState.totalScore}!',
                style: TextStyle(fontSize: 22)),
          ]
        //  Daily challenge finished text
        : <Widget>[
            Text('You have completed the daily challenge!',
                style: TextStyle(
                    fontFamily: 'LuckiestGuy',
                    color: highlightColor1,
                    fontSize: 30)),
            Text('You scored ${gameState.totalScore}!',
                style: TextStyle(fontSize: 22, height: 2)),
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
                    margin: EdgeInsets.only(top: 50),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              child: Text(
                                "Return",
                                style:
                                    TextStyle(color: fontColor, fontSize: 20),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.all(5.0),
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () {
                                print("Quit");
                                Navigator.pop(context);
                              },
                            ),
                            SizedBox(
                              width: 20.0,
                            ),
                            TextButton(
                                child: Text(
                                  "Upload my score",
                                  style:
                                      TextStyle(color: fontColor, fontSize: 20),
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.all(5.0),
                                  backgroundColor: Colors.green,
                                ),
                                onPressed: () {
                                  print("Upload score");
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
                                }
                        ),
                          ])
                  ),
                ])));
  }

  // Future<bool?> _exitDialogBuilder(BuildContext context) {
  //   return showDialog<bool>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Ranking'),
  //         content: const Text(
  //           'Do you want to upload your score?\n'
  //           'You can see how well you performed against other players!',
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             style: TextButton.styleFrom(
  //               textStyle: Theme.of(context).textTheme.labelLarge,
  //             ),
  //             child: const Text('No'),
  //             onPressed: () {
  //               Navigator.pop(context, false);
  //             },
  //           ),
  //           TextButton(
  //             style: TextButton.styleFrom(
  //               textStyle: Theme.of(context).textTheme.labelLarge,
  //             ),
  //             child: const Text('Yes'),
  //             onPressed: () {
  //               Navigator.pop(context, true);
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

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

class MapLocation extends StatefulWidget {
  final Question q;
  const MapLocation({Key? key, required this.q}) : super(key: key);

  @override
  State<MapLocation> createState() => _MapLocationState();
}

class _MapLocationState extends State<MapLocation> {
  final width = 500; // Width of the crop region
  final height = 500; // Height of the crop region
  late double x, y;
  final GlobalKey _boxKey = GlobalKey();

  img.Image? croppedImage;
  CirclePainter? circleDot;

  @override
  void initState() {
    super.initState();
    var jsonData = jsonDecode(widget.q.jsonText);
    x = jsonData['x-coordinate'];
    y = jsonData['y-coordinate'];
    cropImage();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      paintCircle();
    });
  }

  Future<void> cropImage() async {
    int toPosInt(double n) => n < 0 ? 0 : n.toInt();

    List<int> imageBytes = await rootBundle
        .load('assets/images/hku_image.jpg')
        .then((data) => data.buffer.asUint8List());

    img.Image? originalImage = img.decodeImage(imageBytes);

    int dx = toPosInt(x - width / 2);
    int dy = toPosInt(y - height / 2);
    croppedImage = img.copyCrop(originalImage!, dx, dy, width, height);

    setState(() {});
  }

  void paintCircle() {
    final RenderBox renderBox =
        _boxKey.currentContext!.findRenderObject() as RenderBox;
    double toOffset(double n, double dn) => n - dn < 0 ? n : dn;

    double dx = toOffset(x, width / 2) * renderBox.size.width / width;
    double dy = toOffset(y, height / 2) * renderBox.size.height / height;

    setState(() {
      circleDot = CirclePainter(dx, dy);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        child: SizedBox(
            key: _boxKey,
            width: 250,
            height: 250,
            child: CustomPaint(
                foregroundPainter: circleDot,
                child: croppedImage != null
                    ? Image.memory(
                        Uint8List.fromList(img.encodeJpg(croppedImage!)))
                    : CircularProgressIndicator())));
  }
}
