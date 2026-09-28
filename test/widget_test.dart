import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flag_quiz/main.dart';
import 'package:flag_quiz/services/preferences_service.dart';
import 'package:flag_quiz/widgets/flag_display.dart';
import 'package:flag_quiz/widgets/quiz_option_card.dart';

void main() {
  testWidgets('FlagQuizApp renders HomeScreen and title', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.instance.init();

    await tester.pumpWidget(const FlagQuizApp());
    await tester.pumpAndSettle();

    // Verify app title is displayed
    expect(find.text('Flag Quiz'), findsOneWidget);
  });

  testWidgets('FlagDisplay renders without crashing and supports fallback', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FlagDisplay(
            countryCode: 'JP',
            countryName: 'Japan',
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(FlagDisplay), findsOneWidget);

    // Test with empty code fallback
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FlagDisplay(
            countryCode: '',
            countryName: 'Unknown',
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
  });

  testWidgets('QuizOptionCard renders and displays correct feedback icons', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              QuizOptionCard(
                text: 'Paris',
                index: 0,
                isSelected: false,
                isCorrectAnswer: true,
                isAnswered: true,
              ),
              QuizOptionCard(
                text: 'London',
                index: 1,
                isSelected: true,
                isCorrectAnswer: false,
                isAnswered: true,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);
    expect(find.text('Paris'), findsOneWidget);
    expect(find.text('London'), findsOneWidget);
  });

  testWidgets('HomeScreen displays question count selector and switches count', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.instance.init();

    await tester.pumpWidget(const FlagQuizApp());
    await tester.pumpAndSettle();

    expect(find.text('25'), findsOneWidget);
    expect(find.text('50'), findsOneWidget);
    expect(find.text('All (195)'), findsOneWidget);

    await tester.tap(find.text('25'));
    await tester.pumpAndSettle();
    expect(PreferencesService.instance.getPreferredQuestionCount(), 25);
  });
}
