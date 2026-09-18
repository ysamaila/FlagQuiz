import 'package:flutter_test/flutter_test.dart';
import 'package:flag_quiz/main.dart';

void main() {
  testWidgets('FlagQuizApp renders HomeScreen and title', (WidgetTester tester) async {
    await tester.pumpWidget(const FlagQuizApp());
    await tester.pump();

    // Verify app title is displayed
    expect(find.text('Flag Quiz'), findsOneWidget);
  });
}
