import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hku_guesser/game.dart';
import 'constants.dart';

class TransitionPage extends StatefulWidget {
  final int score;
  final int maxT = 5;
  const TransitionPage({Key? key, this.score = 0}) : super(key: key);

  @override
  State<TransitionPage> createState() => _TransitionPageState();
}

class _TransitionPageState extends State<TransitionPage> {
  Timer? countdownTimer;
  Duration _myDuration = Duration(seconds: 5);
  @override
  void initState() {
    super.initState();
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
        nextRound();
      } else {
        _myDuration = Duration(seconds: seconds);
      }
    });
  }

  void nextRound() {
    setState(() => countdownTimer!.cancel());
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => GamePage()));
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
            child: Align(
              alignment: Alignment(0, -0.25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'You score ${widget.score} this round!',
                    style: TextStyle(fontSize: 25),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 15),
                    child: SizedBox(
                      width: 177,
                      height: 177,
                      child: Stack(
                        children: [
                          Image.asset('assets/images/location.png'),
                          Positioned(
                            left: 69,
                            top: 34,
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
            )));
  }
}
