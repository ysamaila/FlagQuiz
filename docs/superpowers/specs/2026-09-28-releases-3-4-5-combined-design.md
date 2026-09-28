# Combined Release (Releases 3, 4, 5) Design Specification — Flag Quiz

## 1. Overview
This specification details the combined release (v1.1.0+3) of Flag Quiz, consolidating Releases 3, 4, and 5 into a single coherent upgrade:
- **Release 3 (Motion & Feedback):** `flutter_animate` integration, haptic feedback, animated option feedback, animated question transitions, animated score counter, and animated progress bar. Icons (not emojis) for all feedback and tiers.
- **Release 4 (Smarter Quiz Logic & Edge Cases):** Continent-biased distractor selection, observer states verification (Vatican City `VA`, Palestine `PS`), non-UN state exclusion (Kosovo), and graceful flag image fallback rendering.
- **Release 5 (Persistence & Replayability):** `shared_preferences` storage, configurable question count selector (`10`, `25`, `50`, `195 Marathon`), persistent high scores per mode & count, mistake tracking, and a dedicated Review Mistakes screen.

---

## 2. Dependencies & Versioning
- **`pubspec.yaml` updates:**
  - `version: 1.1.0+3`
  - `flutter_animate: ^4.5.2`
  - `shared_preferences: ^2.5.3`

---

## 3. Architecture & Data Layer

### 3.1 Persistence Service (`lib/services/preferences_service.dart`)
- **Key Schema:**
  - `preferred_question_count`: integer (`10`, `25`, `50`, `195`, default: `10`)
  - `high_score_${mode.name}_${questionCount}`: integer (e.g. `high_score_flags_10`, `high_score_capitals_25`)
- **Methods:**
  - `Future<void> init()`: Pre-caches preferences.
  - `int getPreferredQuestionCount({int fallback = 10})`
  - `Future<void> setPreferredQuestionCount(int count)`
  - `int getHighScore(QuizMode mode, int questionCount)`
  - `Future<bool> updateHighScoreIfBest(QuizMode mode, int questionCount, int score)`: returns true if new personal best was recorded.

### 3.2 Domain Models (`lib/models/quiz_models.dart`)
- **`QuizMistake`:**
  ```dart
  class QuizMistake {
    final QuizQuestion question;
    final String chosenAnswer;
    const QuizMistake({required this.question, required this.chosenAnswer});
  }
  ```
- **`QuizSession` Extensions:**
  - `final List<QuizMistake> mistakes;`
  - Records wrong answers inside `answerCurrentQuestion(String answer)`.
  - Exposes `int get mistakesCount => mistakes.length;`.

### 3.3 Regional Distractor Generation (`lib/data/country_repository.dart`)
- Signature: `QuizSession generateSession(QuizMode mode, {int questionCount = 10})`
- Selects `questionCount` unique target countries at random.
- For each target country:
  1. Retrieve all other countries with `c.continent == target.continent`.
  2. Shuffle candidates and select up to 3 distractors.
  3. If fewer than 3 regional candidates exist, fill remaining slots from the general pool (`otherContinents.shuffle()`).
  4. Shuffle target and distractors into 4 options.
- Verifies edge cases: Vatican City (`VA`) and Palestine (`PS`) have valid continent assignments; Kosovo remains excluded.

---

## 4. UI & Motion Components

### 4.1 Home Screen (`lib/screens/home_screen.dart`)
- **Question Count Selector:**
  - Horizontal segmented pill selector: `10`, `25`, `50`, `All (195)`.
  - Instant tactile feedback (`HapticFeedback.lightImpact()`) on selection.
  - Persists preference via `PreferencesService`.
- **High Score Display Pill:**
  - Displays best score for selected `(QuizMode, count)`:
    - If score exists: `Best Score: X / Y (Z%)` with `Icons.emoji_events` icon.
    - If unplayed: `Best: None yet` with `Icons.timer_outlined`.

### 4.2 Quiz Screen & Option Cards (`lib/screens/quiz_screen.dart`, `lib/widgets/quiz_option_card.dart`)
- **Option Feedback Animations (`flutter_animate`):**
  - Correct tap: `.scaleXY(begin: 1.0, end: 1.03, duration: 250.ms)` with green border glow (`AppColors.success`).
  - Wrong tap: `.shakeX(amount: 6, duration: 300.ms)` with red border (`AppColors.error`).
  - Reveal: If the player picks the wrong answer, the true correct option card illuminates in green.
- **Haptics:**
  - `HapticFeedback.lightImpact()` on card tap.
  - `HapticFeedback.mediumImpact()` on answer reveal.
- **Question Transition:**
  - Wrapped in `AnimatedSwitcher` with smooth slide & fade animation between questions.
- **Header Motion:**
  - Score counter pill pulses (`.scaleXY()`) on increment.
  - Smooth animated linear progress bar.

### 4.3 Flag Display Fallback (`lib/widgets/flag_display.dart`)
- Graceful error boundary: if a vector flag fails, render an elegant slate container displaying the 2-letter ISO code and country name with an `Icons.flag_outlined` icon.

### 4.4 Results & Review Mistakes Screens (`lib/screens/results_screen.dart`, `lib/screens/review_mistakes_screen.dart`)
- **Results Screen:**
  - Animated count-up from `0` to final score (`flutter_animate`).
  - Tiered performance badge with Material Icons (no emojis):
    - 100%: "Perfect Score!" with `Icons.emoji_events`
    - 80%+: "Flag Master!" with `Icons.military_tech`
    - 60%+: "Great Effort!" with `Icons.thumb_up`
    - <60%: "Keep Practicing!" with `Icons.menu_book`
  - New High Score highlight badge if `isNewHighScore` is true.
  - "Review Mistakes (N)" button (shown when `mistakes.isNotEmpty`).
- **Review Mistakes Screen:**
  - App bar with back navigation.
  - Scrollable list of mistake cards:
    - Country flag (or name in capitals mode).
    - Question prompt.
    - Player's incorrect answer: highlighted with red text and `Icons.cancel_rounded`.
    - Correct answer: highlighted with green text and `Icons.check_circle_rounded`.

---

## 5. Verification & Testing Strategy
- Unit tests for `PreferencesService` (mocking `SharedPreferences`).
- Unit tests for `CountryRepository` (continent bias, 195 marathon, observer states).
- Unit tests for `QuizSession` mistake recording.
- Widget tests for `HomeScreen` (count selector, high score badge).
- Widget tests for `QuizOptionCard` (animation triggers, correct answer reveal).
- Widget tests for `ReviewMistakesScreen` (rendering missed questions and icons).
- Zero issues with `flutter analyze`.
