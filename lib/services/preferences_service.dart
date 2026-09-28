import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_question.dart';

class PreferencesService {
  PreferencesService._();
  static final PreferencesService instance = PreferencesService._();

  SharedPreferences? _prefs;

  Future<void> init({SharedPreferences? preferences}) async {
    _prefs = preferences ?? await SharedPreferences.getInstance();
  }

  static const String _keyQuestionCount = 'preferred_question_count';

  int getPreferredQuestionCount({int fallback = 10}) {
    return _prefs?.getInt(_keyQuestionCount) ?? fallback;
  }

  Future<void> setPreferredQuestionCount(int count) async {
    await _prefs?.setInt(_keyQuestionCount, count);
  }

  String _highScoreKey(QuizMode mode, int questionCount) =>
      'high_score_${mode.name}_$questionCount';

  int getHighScore(QuizMode mode, int questionCount) {
    return _prefs?.getInt(_highScoreKey(mode, questionCount)) ?? 0;
  }

  Future<bool> updateHighScoreIfBest(
    QuizMode mode,
    int questionCount,
    int score,
  ) async {
    final currentBest = getHighScore(mode, questionCount);
    if (score > currentBest) {
      await _prefs?.setInt(_highScoreKey(mode, questionCount), score);
      return true;
    }
    return false;
  }
}
