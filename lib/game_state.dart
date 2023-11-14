class Question {
  final int id;
  final String jsonText;
  final String imagePath;

  Question({
    required this.id,
    required this.jsonText,
    required this.imagePath,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      jsonText: map['jsonText'],
      imagePath: map['imagePath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jsonText': jsonText,
      'imagePath': imagePath,
    };
  }
}

class GameState {
  List<Question> questions;
  int round;
  int totalScore;
  int roundScore;
  final roundTime = 60; // in seconds
  final transitionTime = 5; // in seconds

  GameState({
    required this.questions,
    this.round = 1,
    this.totalScore = 0,
    this.roundScore = 0,
  });
}
