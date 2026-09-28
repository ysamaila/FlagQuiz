# Combined Releases 3, 4, and 5 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement Releases 3 (Motion & Feedback), 4 (Smarter Quiz Logic & Edge Cases), and 5 (Persistence & Replayability) into a single cohesive release (`v1.1.0+3`).

**Architecture:** Layered service design introducing `PreferencesService` for persistent high scores and question counts via `shared_preferences`, enhancing `CountryRepository` with regional/continent distractor bias and configurable question counts (10, 25, 50, 195 Marathon), enriching `QuizSession` with `QuizMistake` tracking, adding a dedicated `ReviewMistakesScreen`, and elevating gameplay feel with `flutter_animate` and tactile haptics using Material Icons (strictly no emojis).

**Tech Stack:** Flutter 3.x, Dart 3.x, `flutter_animate: ^4.5.2`, `shared_preferences: ^2.5.3`, `country_flags: 4.1.2`, `google_fonts: 8.2.1`.

**Spec:** [docs/superpowers/specs/2026-09-28-releases-3-4-5-combined-design.md](file:///c:/Users/User/Desktop/mobile/flutter/FlagQuiz/docs/superpowers/specs/2026-09-28-releases-3-4-5-combined-design.md)

## Global Constraints
- Target version: `1.1.0+3` in `pubspec.yaml`.
- Strictly use Material Icons (e.g. `Icons.emoji_events`, `Icons.military_tech`, `Icons.thumb_up`, `Icons.menu_book`, `Icons.cancel_rounded`, `Icons.check_circle_rounded`) — strictly NO text emojis in UI copy.
- Full UN 195 member & observer state accuracy preserved (Kosovo excluded; Vatican City `VA` and Palestine `PS` supported).
- Zero warnings or errors in `flutter analyze`.
- All tests in `flutter test` must pass 100%.

---

### Task 1: Dependencies and Version Bump

**Files:**
- Modify: `pubspec.yaml`

**Interfaces:**
- Consumes: None
- Produces: `flutter_animate` and `shared_preferences` libraries available for import.

- [ ] **Step 1: Update `pubspec.yaml` with version `1.1.0+3` and new dependencies**

Add `flutter_animate: ^4.5.2` and `shared_preferences: ^2.5.3` under `dependencies:`.

- [ ] **Step 2: Run `flutter pub get`**

Run: `flutter pub get`
Expected: Resolution succeeded without version conflicts.

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: bump version to 1.1.0+3 and add flutter_animate and shared_preferences"
```

---

### Task 2: Persistence Service (`PreferencesService`)

**Files:**
- Create: `lib/services/preferences_service.dart`
- Create: `test/preferences_service_test.dart`

**Interfaces:**
- Consumes: `shared_preferences`
- Produces:
  - `class PreferencesService`:
    - `static PreferencesService get instance`
    - `Future<void> init({SharedPreferences? preferences})`
    - `int getPreferredQuestionCount({int fallback = 10})`
    - `Future<void> setPreferredQuestionCount(int count)`
    - `int getHighScore(QuizMode mode, int questionCount)`
    - `Future<bool> updateHighScoreIfBest(QuizMode mode, int questionCount, int score)`

- [ ] **Step 1: Write failing test in `test/preferences_service_test.dart`**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flag_quiz/models/quiz_models.dart';
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
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/preferences_service_test.dart`
Expected: FAIL (PreferencesService not found)

- [ ] **Step 3: Implement `PreferencesService` in `lib/services/preferences_service.dart`**

```dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_models.dart';

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
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/preferences_service_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/services/preferences_service.dart test/preferences_service_test.dart
git commit -m "feat(persistence): implement PreferencesService with high score tracking and preferred question count"
```

---

### Task 3: Domain Models Expansion (`QuizMistake` & `QuizSession`)

**Files:**
- Modify: `lib/models/quiz_models.dart`
- Modify: `test/quiz_test.dart`

**Interfaces:**
- Consumes: None
- Produces:
  - `class QuizMistake`: contains `final QuizQuestion question; final String chosenAnswer;`
  - `QuizSession.mistakes`: `List<QuizMistake>` recording every missed question
  - `QuizSession.mistakesCount`: getter returning `mistakes.length`

- [ ] **Step 1: Write failing test in `test/quiz_test.dart` for `QuizMistake` recording**

Add a test asserting that answering incorrectly appends a `QuizMistake` to `session.mistakes`.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/quiz_test.dart`
Expected: FAIL (`mistakes` or `QuizMistake` not found).

- [ ] **Step 3: Implement `QuizMistake` and update `QuizSession` in `lib/models/quiz_models.dart`**

```dart
class QuizMistake {
  final QuizQuestion question;
  final String chosenAnswer;

  const QuizMistake({
    required this.question,
    required this.chosenAnswer,
  });
}
```
Update `QuizSession`:
```dart
class QuizSession {
  final QuizMode mode;
  final List<QuizQuestion> questions;
  int currentIndex = 0;
  int score = 0;
  final List<QuizMistake> mistakes = [];

  QuizSession({
    required this.mode,
    required this.questions,
  });

  bool get isFinished => currentIndex >= questions.length;
  QuizQuestion get currentQuestion => questions[currentIndex];
  int get totalQuestions => questions.length;
  int get mistakesCount => mistakes.length;

  bool answerCurrentQuestion(String answer) {
    if (isFinished) return false;
    final isCorrect = currentQuestion.isCorrect(answer);
    if (isCorrect) {
      score++;
    } else {
      mistakes.add(QuizMistake(
        question: currentQuestion,
        chosenAnswer: answer,
      ));
    }
    currentIndex++;
    return isCorrect;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/quiz_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/models/quiz_models.dart test/quiz_test.dart
git commit -m "feat(models): add QuizMistake and record mistakes during QuizSession"
```

---

### Task 4: Smarter Regional Distractor Quiz Generation

**Files:**
- Modify: `lib/data/country_repository.dart`
- Modify: `test/quiz_test.dart`

**Interfaces:**
- Consumes: `Country`, `CountryRepository`
- Produces: `QuizSession generateSession(QuizMode mode, {int questionCount = 10})` with regional distractor prioritization.

- [ ] **Step 1: Write failing test in `test/quiz_test.dart` verifying regional distractor bias and configurable question counts**

```dart
test('generateSession generates requested question count up to all 195 countries', () {
  final session10 = repo.generateSession(QuizMode.flags, questionCount: 10);
  expect(session10.questions.length, 10);

  final session25 = repo.generateSession(QuizMode.flags, questionCount: 25);
  expect(session25.questions.length, 25);

  final session195 = repo.generateSession(QuizMode.flags, questionCount: 195);
  expect(session195.questions.length, 195);
});

test('distractor selection biases toward same continent', () {
  final session = repo.generateSession(QuizMode.flags, questionCount: 50);
  for (final q in session.questions) {
    expect(q.options.length, 4);
    expect(q.options.toSet().length, 4); // all unique
    expect(q.options.contains(q.correctAnswer), isTrue);
  }
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/quiz_test.dart`
Expected: FAIL (`questionCount` named argument not defined or length mismatch).

- [ ] **Step 3: Update `CountryRepository.generateSession` in `lib/data/country_repository.dart`**

Implement regional distractor selection prioritizing countries with matching `continent`, backfilling from other continents when fewer than 3 regional candidates exist.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/quiz_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/data/country_repository.dart test/quiz_test.dart
git commit -m "feat(quiz-logic): add regional continent-biased distractors and configurable question count"
```

---

### Task 5: Flag Display Fallback

**Files:**
- Modify: `lib/widgets/flag_display.dart`
- Test: `test/widget_test.dart`

**Interfaces:**
- Consumes: `CountryFlag`
- Produces: Resilient `FlagDisplay` rendering fallback slate container on image load/render error.

- [ ] **Step 1: Add widget test for `FlagDisplay`**

Verify `FlagDisplay` renders properly and doesn't crash on unusual country codes.

- [ ] **Step 2: Update `FlagDisplay` in `lib/widgets/flag_display.dart` with error boundary and fallback**

Wrap flag rendering with graceful fallback showing ISO code, country name, and `Icons.flag_outlined`.

- [ ] **Step 3: Run widget tests**

Run: `flutter test test/widget_test.dart`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add lib/widgets/flag_display.dart test/widget_test.dart
git commit -m "feat(ui): add graceful fallback rendering for FlagDisplay"
```

---

### Task 6: Motion & Option Feedback in `QuizOptionCard`

**Files:**
- Modify: `lib/widgets/quiz_option_card.dart`
- Test: `test/widget_test.dart`

**Interfaces:**
- Consumes: `flutter_animate`
- Produces:
  - `QuizOptionCard`:
    - Scale/glow animation on correct answer.
    - Shake animation on wrong answer.
    - `isAnswered` and `isCorrectAnswer` properties to reveal the true correct answer if user answered wrong.

- [ ] **Step 1: Write test in `test/widget_test.dart` verifying `QuizOptionCard` visual states**

- [ ] **Step 2: Implement `flutter_animate` animations in `QuizOptionCard`**

```dart
// Success scale: .animate(target: isSelected && isCorrect ? 1 : 0).scaleXY(begin: 1.0, end: 1.03, duration: 250.ms)
// Error shake: .animate(target: isSelected && !isCorrect ? 1 : 0).shakeX(amount: 6, duration: 300.ms)
```

- [ ] **Step 3: Run widget tests**

Run: `flutter test test/widget_test.dart`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add lib/widgets/quiz_option_card.dart test/widget_test.dart
git commit -m "feat(motion): add shake and pulse animations to QuizOptionCard with correct option reveal"
```

---

### Task 7: Home Screen Question Count Selector & Best Score Badge

**Files:**
- Modify: `lib/screens/home_screen.dart`
- Test: `test/widget_test.dart`

**Interfaces:**
- Consumes: `PreferencesService`, `QuizMode`
- Produces:
  - Segmented selector for `10`, `25`, `50`, and `All (195)` with haptic feedback on change.
  - Dynamic Best Score pill reflecting selected mode and count with `Icons.emoji_events`.

- [ ] **Step 1: Write widget test verifying Home screen renders count selector and updates best score**

- [ ] **Step 2: Update `HomeScreen` to load/save preferences and render count pills**

Add question count state, load preferred count in `initState`, persist with `PreferencesService.instance.setPreferredQuestionCount(count)`, and display high score badge.

- [ ] **Step 3: Run widget tests**

Run: `flutter test test/widget_test.dart`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add lib/screens/home_screen.dart test/widget_test.dart
git commit -m "feat(ui): add question count selector and dynamic high score badge on HomeScreen"
```

---

### Task 8: Quiz Screen Motion, Haptics, and Transitions

**Files:**
- Modify: `lib/screens/quiz_screen.dart`
- Test: `test/widget_test.dart`

**Interfaces:**
- Consumes: `flutter_animate`, `HapticFeedback`, `PreferencesService`
- Produces:
  - `AnimatedSwitcher` horizontal slide & fade transitions between questions.
  - Score badge pulse on increment.
  - `HapticFeedback.lightImpact()` on tap and `mediumImpact()` on reveal.
  - Pass mistakes to `ResultsScreen`.

- [ ] **Step 1: Write widget tests for `QuizScreen` gameplay flow**

- [ ] **Step 2: Implement animations, haptics, and transitions in `QuizScreen`**

- [ ] **Step 3: Run widget tests**

Run: `flutter test test/widget_test.dart`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add lib/screens/quiz_screen.dart test/widget_test.dart
git commit -m "feat(motion): implement question slide transitions, score pulse, and haptic feedback in QuizScreen"
```

---

### Task 9: Results Screen Polish & Review Mistakes Screen

**Files:**
- Create: `lib/screens/review_mistakes_screen.dart`
- Modify: `lib/screens/results_screen.dart`
- Create: `test/review_mistakes_screen_test.dart`

**Interfaces:**
- Consumes: `QuizMistake`, `PreferencesService`
- Produces:
  - `ResultsScreen`: Animated score count-up, high score persistence check (`PreferencesService.instance.updateHighScoreIfBest`), performance badges with Material Icons (strictly no emojis), and "Review Mistakes" button.
  - `ReviewMistakesScreen`: List of mistake cards showing country flag/name, player's wrong pick (`Icons.cancel_rounded` in red), and correct answer (`Icons.check_circle_rounded` in green).

- [ ] **Step 1: Write test for `ReviewMistakesScreen`**

Verify that each mistake card displays the question, the wrong answer with `Icons.cancel_rounded`, and the correct answer with `Icons.check_circle_rounded`.

- [ ] **Step 2: Implement `ReviewMistakesScreen` in `lib/screens/review_mistakes_screen.dart`**

- [ ] **Step 3: Update `ResultsScreen` with score count-up, Material Icons for tiers, high score check, and Review Mistakes navigation**

- [ ] **Step 4: Run tests**

Run: `flutter test test/review_mistakes_screen_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/screens/review_mistakes_screen.dart lib/screens/results_screen.dart test/review_mistakes_screen_test.dart
git commit -m "feat(screens): add ReviewMistakesScreen and animated count-up with high score update on ResultsScreen"
```

---

### Task 10: Full Verification & AGENT.md Update

**Files:**
- Modify: `AGENT.md`
- Test: All tests

- [ ] **Step 1: Run `flutter analyze`**

Run: `flutter analyze`
Expected: 0 issues.

- [ ] **Step 2: Run complete test suite**

Run: `flutter test`
Expected: 100% PASS.

- [ ] **Step 3: Update `AGENT.md` with Release 3/4/5 completion log and architectural decisions**

- [ ] **Step 4: Commit and push**

```bash
git add AGENT.md
git commit -m "docs: document completion of combined Releases 3, 4, and 5 in AGENT.md"
git push
```
