import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flag_quiz/models/quiz_question.dart';
import 'package:flag_quiz/services/preferences_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PreferencesService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('getPreferredQuestionCount defaults to 10 and updates correctly', () async {
      final service = PreferencesService.instance;
      await service.init();
      expect(service.getPreferredQuestionCount(), 10);

      await service.setPreferredQuestionCount(25);
      expect(service.getPreferredQuestionCount(), 25);

      await service.setPreferredQuestionCount(195);
      expect(service.getPreferredQuestionCount(), 195);
    });

    test('high score tracking updates only when higher', () async {
      final service = PreferencesService.instance;
      await service.init();
      expect(service.getHighScore(QuizMode.flags, 10), 0);

      final isBest1 = await service.updateHighScoreIfBest(QuizMode.flags, 10, 8);
      expect(isBest1, isTrue);
      expect(service.getHighScore(QuizMode.flags, 10), 8);

      final isBest2 = await service.updateHighScoreIfBest(QuizMode.flags, 10, 7);
      expect(isBest2, isFalse);
      expect(service.getHighScore(QuizMode.flags, 10), 8);

      final isBest3 = await service.updateHighScoreIfBest(QuizMode.flags, 10, 10);
      expect(isBest3, isTrue);
      expect(service.getHighScore(QuizMode.flags, 10), 10);

      // Verify separate keys for different modes & lengths
      expect(service.getHighScore(QuizMode.capitals, 10), 0);
      expect(service.getHighScore(QuizMode.flags, 25), 0);
    });
  });
}
