import 'quiz_question.dart';

class QuizMistake {
  final QuizQuestion question;
  final String chosenAnswer;

  const QuizMistake({
    required this.question,
    required this.chosenAnswer,
  });
}

class QuizSession {
  final QuizMode mode;
  final List<QuizQuestion> questions;
  int currentIndex;
  final List<QuizMistake> mistakes;

  QuizSession({
    required this.mode,
    required this.questions,
    this.currentIndex = 0,
    List<QuizMistake>? mistakes,
  }) : mistakes = mistakes ?? [];

  QuizQuestion get currentQuestion => questions[currentIndex];

  int get totalQuestions => questions.length;

  int get questionNumber => currentIndex + 1;

  int get score => questions.where((q) => q.isCorrect).length;

  int get mistakesCount => mistakes.length;

  bool get isCurrentAnswered => currentQuestion.isAnswered;

  bool get isLastQuestion => currentIndex == questions.length - 1;

  void answerCurrent(int selectedIndex) {
    if (!isCurrentAnswered) {
      currentQuestion.userSelectedIndex = selectedIndex;
      if (!currentQuestion.isCorrect) {
        mistakes.add(QuizMistake(
          question: currentQuestion,
          chosenAnswer: currentQuestion.options[selectedIndex],
        ));
      }
    }
  }

  bool nextQuestion() {
    if (currentIndex < questions.length - 1) {
      currentIndex++;
      return true;
    }
    return false;
  }

  void reset() {
    currentIndex = 0;
    mistakes.clear();
    for (final q in questions) {
      q.userSelectedIndex = null;
    }
  }
}
