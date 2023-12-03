import 'package:flutter/material.dart';
import 'package:hku_guesser/game.dart';
import 'package:hku_guesser/game_state.dart';
import 'package:hku_guesser/question_database.dart';
import 'package:hku_guesser/sync_db.dart';

class LoadingPage extends StatelessWidget {
  final String gameMode;
  const LoadingPage({required this.gameMode, super.key});

  Future<List<Question>> _loadQuestion() async {
    final check = await QuestionDatabase.instance.getQuestions();

    if (check.isEmpty) {
      await initQuestion();
    } else {
      await updateQuestion();
    }

    final loadedQuestions = await QuestionDatabase.instance.getQuestions();
    loadedQuestions.shuffle();
    return loadedQuestions;
  }

  Future<List<Question>> _loadDaily() async {
    final question = await getDailyQuestion();
    if (question == null) {
      var loadedQuestions = await QuestionDatabase.instance.getQuestions();
      if (loadedQuestions.isEmpty) {
        await initQuestion();
        loadedQuestions = await QuestionDatabase.instance.getQuestions();
      }
      return [loadedQuestions[0]];
    }
    return question;
  }

  @override
  Widget build(BuildContext context) {
    if (gameMode == "Daily") {
      return FutureBuilder<List<Question>>(
        future: _loadDaily(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingWidget();
          } else if (snapshot.hasData) {
            return GamePage(
                gameState: GameState(
                    gameType: GameState.daily,
                    totalRound: 1,
                    questions: snapshot.data!));
          } else if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString());
          } else {
            return Container(); // Placeholder widget if none of the above conditions are met
          }
        },
      );
    }
    return FutureBuilder<List<Question>>(
      future: _loadQuestion(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        } else if (snapshot.hasData) {
          return GamePage(
              gameState: GameState(
                  gameType: GameState.general,
                  totalRound: 5,
                  questions: snapshot.data!));
        } else if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        } else {
          return Container(); // Placeholder widget if none of the above conditions are met
        }
      },
    );
  }

  Widget _buildLoadingWidget() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator()
      )
    );
    
    
  }

  Widget _buildErrorWidget(String error) {
    return Scaffold(
      body: Center(
        child: Text('Error: $error')
      )
    );
  }
}