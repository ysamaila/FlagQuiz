import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flag_quiz/models/country.dart';
import 'package:flag_quiz/models/quiz_question.dart';
import 'package:flag_quiz/models/quiz_session.dart';
import 'package:flag_quiz/screens/review_mistakes_screen.dart';

void main() {
  testWidgets('ReviewMistakesScreen renders missed questions with icons and correct answers', (WidgetTester tester) async {
    const country = Country(
      name: 'Germany',
      capital: 'Berlin',
      code: 'DE',
      continent: 'Europe',
    );

    final question = QuizQuestion(
      country: country,
      mode: QuizMode.flags,
      options: ['Germany', 'Belgium', 'France', 'Austria'],
      correctOptionIndex: 0,
    );

    final mistakes = [
      QuizMistake(question: question, chosenAnswer: 'Belgium'),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: ReviewMistakesScreen(mistakes: mistakes),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Review Mistakes (1)'), findsOneWidget);
    expect(find.text('Germany'), findsWidgets);
    expect(find.text('Your answer: Belgium'), findsOneWidget);
    expect(find.text('Correct: Germany'), findsOneWidget);
    expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });
}
