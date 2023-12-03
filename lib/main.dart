import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hku_guesser/constants.dart';
import 'package:hku_guesser/game_start.dart';
import 'package:hku_guesser/ranking.dart';
import 'package:hku_guesser/question_database.dart';
import 'package:hku_guesser/camera.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
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
    width: 200,
    height: 200,
    child: Image.asset('assets/images/icon.png'),
  );

  final appTitle = const SizedBox(
    width: 250,
    height: 150,
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
          style: const TextStyle(
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
              appTitle,
              const SizedBox(height: 10),
              buildButton("Start", () {
                Navigator.push(
                  context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const LoadingPage(gameMode: "Normal"))
                );
              }),
              const SizedBox(height: 20),
              buildButton("Daily Challenge", () async {
                final day = await QuestionDatabase.instance.doQuery("SELECT * FROM daily");
                initializeTimeZones();
                final hk = tz.getLocation(timeZoneName);
                final now = tz.TZDateTime.now(hk);
                if (day.isNotEmpty && day[0]["date"] == DateFormat('dd/MM/yy').format(now)) {
                  Fluttertoast.showToast(msg: "You have already attempted today's challenge!");
                } else {
                  // ignore: use_build_context_synchronously
                  Navigator.push(
                    context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const LoadingPage(gameMode: "Daily"))
                  );
                }
              }),
              const SizedBox(height: 20),
              buildButton("Leaderboard", () {
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (context) => const RankingPage()));
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
