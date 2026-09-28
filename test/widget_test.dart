import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flag_quiz/main.dart';
import 'package:flag_quiz/widgets/flag_display.dart';

void main() {
  testWidgets('FlagQuizApp renders HomeScreen and title', (WidgetTester tester) async {
    await tester.pumpWidget(const FlagQuizApp());
    await tester.pump();

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
}
