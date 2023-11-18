import 'dart:convert';
import 'dart:io';

import 'package:hku_guesser/image.dart';
import 'package:hku_guesser/question_database.dart';
import 'dart:async';

Future<void> initailize_question(var n) async {
    QuestionDatabase.instance.insertQuestion(
      "6558b6fe5ca77f50e641484e",
          jsonEncode({
            "x-coordinate": "1250.6396965865638",
            "y-coordinate": "2192.9494311002054",
            "floor": "G"
          }),
    await saveImageToStorageFromAssets('assets/images/image1.jpg', n));
    n += 1;
    QuestionDatabase.instance.insertQuestion(
      "6558b6fe5ca77f50e641484f",
          jsonEncode({
            "x-coordinate": "756.0008071041827",
            "y-coordinate": "1779.2338975242087",
            "floor": "G"
          }),
    await saveImageToStorageFromAssets('assets/images/image2.jpg', n));
    n += 1;
    QuestionDatabase.instance.insertQuestion(
      "6558b6fe5ca77f50e6414850",
          jsonEncode({
            "x-coordinate": "1079.0698739572947",
            "y-coordinate": "1761.3012672814534",
            "floor": "G"
          }),
    await saveImageToStorageFromAssets('assets/images/image3.jpg', n));
    n += 1;
    QuestionDatabase.instance.insertQuestion(
      "6558b6fe5ca77f50e6414851",
          jsonEncode({
            "x-coordinate": "1316.161512420328",
            "y-coordinate": "1573.6029707893044",
            "floor": "G"
          }),
    await saveImageToStorageFromAssets('assets/images/image4.jpg', n));
    n += 1;
    QuestionDatabase.instance.insertQuestion(
      "6558b6fe5ca77f50e6414851",
          jsonEncode({
            "x-coordinate": "1838.7289309565551",
            "y-coordinate": "1693.0511053619784",
            "floor": "2"
          }),
    await saveImageToStorageFromAssets('assets/images/image5.jpg', n));

  }