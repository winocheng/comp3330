import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hku_guesser/constants.dart';
import 'package:hku_guesser/game.dart';
import 'package:hku_guesser/game_state.dart';
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
  final Function nextRound;
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
      children: [
        Image.asset('assets/images/location.png'),
        Align(
          alignment: Alignment(0, -0.3),
          child: Text(
            seconds,
            style: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
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
                  Text('Game Finished!',
                      style: TextStyle(
                          fontFamily: 'LuckiestGuy',
                          color: highlightColor1,
                          fontSize: 45)),
                  Text(
                      'You score ${gameState.roundScore} this round!',
                      style: TextStyle(fontSize: 22, height: 2)),
                  Text(
                      'In ${gameState.totalRound} rounds, you score ${gameState.totalScore}!',
                      style: TextStyle(fontSize: 22)),
                  Container(
                    margin: EdgeInsets.only(top: 50),
                    child: TextButton(
                      child: Text(
                        "Return",
                        style: TextStyle(color: fontColor, fontSize: 20),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () {
                        print("Quit");
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ])));
  }
}

class MapLocation extends StatefulWidget {
  final Question q;
  const MapLocation({Key? key, required this.q}) : super(key: key);

  @override
  State<MapLocation> createState() => _MapLocationState();
}

class _MapLocationState extends State<MapLocation> {
  img.Image? croppedImage;

  @override
  void initState() {
    super.initState();
    var jsonData = jsonDecode(widget.q.jsonText);
    var x = double.parse(jsonData['x-coordinate']);
    var y = double.parse(jsonData['y-coordinate']);
    cropImage(x, y);
  }

  Future<void> cropImage(double x, double y) async {
    const width = 500; // Width of the crop region
    const height = 500; // Height of the crop region
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 250,
        height: 250,
        child: croppedImage != null
            ? Image.memory(Uint8List.fromList(img.encodeJpg(croppedImage!)))
            : CircularProgressIndicator());
  }
}
