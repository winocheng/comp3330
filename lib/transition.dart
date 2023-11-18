import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hku_guesser/constants.dart';
import 'package:hku_guesser/game.dart';
import 'package:hku_guesser/game_state.dart';


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
      return Countdown(gameState: gameState);
    }
  }
}

class Countdown extends StatefulWidget {
  final GameState gameState;
  const Countdown({Key? key, required this.gameState}) : super(key: key);

  @override
  State<Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  Timer? countdownTimer;
  late Duration _myDuration;
  @override
  void initState() {
    super.initState();
    _myDuration = Duration(seconds: widget.gameState.transitionTime);
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
        //nextRound();
      } else {
        _myDuration = Duration(seconds: seconds);
      }
    });
  }

  void nextRound() {
    setState(() => countdownTimer!.cancel());
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => GamePage(gameState: widget.gameState)));
  }

  @override
  Widget build(BuildContext context) {
    final seconds = _myDuration.inSeconds.toString();
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
                'You score ${widget.gameState.roundScore} this round!\n'
                'Total score: ${widget.gameState.totalScore}',
                style: TextStyle(fontSize: 25),
                textAlign: TextAlign.center,
              ),
              Text(
                'Round ${widget.gameState.roundNum} starts in:',
                style: TextStyle(fontSize: 25),
                textAlign: TextAlign.center,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 15),
                child: SizedBox(
                  width: 177,
                  height: 177,
                  child: Stack(
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
                  nextRound();
                },
              ),
            ],
          ),
        ));
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
                      'You score ${gameState.roundScore} this round!\n'
                      'In ${gameState.totalRound} rounds, you score ${gameState.totalScore}!',
                      style: TextStyle(fontSize: 22, height: 2)),
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
