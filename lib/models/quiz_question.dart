import 'country.dart';

enum QuizMode {
  flags,
  capitals;

  String get displayName {
    switch (this) {
      case QuizMode.flags:
        return 'Flags';
      case QuizMode.capitals:
        return 'Capitals';
    }
  }

  String get description {
    switch (this) {
      case QuizMode.flags:
        return 'Guess the country from the flag';
      case QuizMode.capitals:
        return 'Guess the capital city';
    }
  }
}

class QuizQuestion {
  final Country country;
  final QuizMode mode;
  final List<String> options;
  final int correctOptionIndex;
  int? userSelectedIndex;

  QuizQuestion({
    required this.country,
    required this.mode,
    required this.options,
    required this.correctOptionIndex,
    this.userSelectedIndex,
  });

  bool get isAnswered => userSelectedIndex != null;

  bool get isCorrect =>
      userSelectedIndex != null && userSelectedIndex == correctOptionIndex;

  String get correctAnswerText => options[correctOptionIndex];

  String get questionTitle {
    switch (mode) {
      case QuizMode.flags:
        return "Which country's flag is this?";
      case QuizMode.capitals:
        return 'What is the capital of ${country.name}?';
    }
  }
}
