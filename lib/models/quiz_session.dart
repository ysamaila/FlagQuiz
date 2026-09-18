import 'quiz_question.dart';

class QuizSession {
  final QuizMode mode;
  final List<QuizQuestion> questions;
  int currentIndex;

  QuizSession({
    required this.mode,
    required this.questions,
    this.currentIndex = 0,
  });

  QuizQuestion get currentQuestion => questions[currentIndex];

  int get totalQuestions => questions.length;

  int get questionNumber => currentIndex + 1;

  int get score => questions.where((q) => q.isCorrect).length;

  bool get isCurrentAnswered => currentQuestion.isAnswered;

  bool get isLastQuestion => currentIndex == questions.length - 1;

  void answerCurrent(int selectedIndex) {
    if (!isCurrentAnswered) {
      currentQuestion.userSelectedIndex = selectedIndex;
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
    for (final q in questions) {
      q.userSelectedIndex = null;
    }
  }
}
