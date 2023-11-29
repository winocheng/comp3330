import 'package:flutter/material.dart';
import 'package:hku_guesser/constants.dart';
import 'package:hku_guesser/game_start.dart';
import 'package:hku_guesser/ranking.dart';
import 'package:hku_guesser/camera.dart';

void main() {
  runApp(const HKUGuesserApp());
}

class HKUGuesserApp extends StatelessWidget {
  const HKUGuesserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HKU Guesser',
      theme: ThemeData(
        primaryColor: backgroundColor,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final logo = SizedBox(
    width: 274,
    height: 186,
    child: Text(
      'HKU\nGuesser',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: highlightColor1,
        fontSize: 64,
        fontFamily: 'LuckiestGuy',
        fontWeight: FontWeight.w400,
        height: 0,
      ),
    ),
  );

  GestureDetector buildButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 95,
        height: 60,
        padding: const EdgeInsets.all(10),
        decoration: ShapeDecoration(
          color: mainColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Center(
          child: Text(
          label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: fontColor,
              fontSize: 24,
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              height: 0,
            ),
          )
        ),
      ),
    );
  }


  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScrollConfiguration(
        behavior: NoOverscroll(),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(left: 24.0, right:24.0),
            children: <Widget>[
              logo,
              const SizedBox(height: 80),
              buildButton("Start", () {
                Navigator.push(
                  context,
                    MaterialPageRoute(
                        builder: (context) =>
                            LoadingPage())
                );
              }),
              const SizedBox(height: 20),
              buildButton("Leaderboard", () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RankingPage()));
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: mainColor,
        child: Container(height: 80.0),
      ),
      floatingActionButton: const CameraButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
