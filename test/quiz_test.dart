import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flag_quiz/models/country.dart';
import 'package:flag_quiz/models/quiz_question.dart';
import 'package:flag_quiz/data/country_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Dataset & Country Model Tests', () {
    test('Country model parses correctly from JSON', () {
      final json = {
        'name': 'Japan',
        'capital': 'Tokyo',
        'code': 'jp',
        'continent': 'Asia',
      };
      final country = Country.fromJson(json);
      expect(country.name, 'Japan');
      expect(country.capital, 'Tokyo');
      expect(country.code, 'JP'); // uppercase normalization
      expect(country.continent, 'Asia');
    });

    test('countries.json has exactly 195 UN member and observer states', () async {
      final file = File('assets/data/countries.json');
      expect(file.existsSync(), isTrue);

      final content = await file.readAsString();
      final repo = CountryRepository();
      await repo.loadCountries(jsonString: content);

      expect(repo.countries.length, 195);

      final codes = repo.countries.map((c) => c.code).toSet();
      expect(codes.length, 195, reason: 'All ISO codes must be unique');

      // Check UN observer states
      expect(codes.contains('VA'), isTrue, reason: 'Vatican City must be present');
      expect(codes.contains('PS'), isTrue, reason: 'Palestine must be present');

      // Check non-UN state excluded
      expect(codes.contains('XK'), isFalse, reason: 'Kosovo must be excluded (non-UN)');

      // Verify no empty names or capitals
      for (final country in repo.countries) {
        expect(country.name.trim().isNotEmpty, isTrue);
        expect(country.capital.trim().isNotEmpty, isTrue);
        expect(country.code.length, 2);
        expect(country.continent.trim().isNotEmpty, isTrue);
      }
    });
  });

  group('Quiz Generation & Session Logic Tests', () {
    late CountryRepository repo;

    setUp(() async {
      final file = File('assets/data/countries.json');
      final content = await file.readAsString();
      repo = CountryRepository();
      await repo.loadCountries(jsonString: content);
    });

    test('generateQuiz creates 10 questions for Flags mode', () {
      final session = repo.generateQuiz(mode: QuizMode.flags, questionCount: 10);
      expect(session.totalQuestions, 10);
      expect(session.mode, QuizMode.flags);
      expect(session.currentIndex, 0);
      expect(session.score, 0);

      for (final q in session.questions) {
        expect(q.options.length, 4);
        expect(q.correctOptionIndex, inInclusiveRange(0, 3));
        expect(q.options[q.correctOptionIndex], q.country.name);
        expect(q.options.toSet().length, 4, reason: 'All 4 options must be distinct');
        expect(q.isAnswered, isFalse);
      }
    });

    test('generateQuiz creates 10 questions for Capitals mode', () {
      final session = repo.generateQuiz(mode: QuizMode.capitals, questionCount: 10);
      expect(session.totalQuestions, 10);
      expect(session.mode, QuizMode.capitals);

      for (final q in session.questions) {
        expect(q.options.length, 4);
        expect(q.options[q.correctOptionIndex], q.country.capital);
        expect(q.options.toSet().length, 4, reason: 'All 4 options must be distinct');
      }
    });

    test('QuizSession tracking, scoring, and progression', () {
      final session = repo.generateQuiz(mode: QuizMode.flags, questionCount: 10);

      // Question 1: Answer correctly
      final q0 = session.currentQuestion;
      session.answerCurrent(q0.correctOptionIndex);
      expect(q0.isCorrect, isTrue);
      expect(session.score, 1);
      expect(session.isCurrentAnswered, isTrue);

      // Advance
      final advanced = session.nextQuestion();
      expect(advanced, isTrue);
      expect(session.currentIndex, 1);
      expect(session.questionNumber, 2);

      // Question 2: Answer incorrectly
      final q1 = session.currentQuestion;
      final wrongIndex = (q1.correctOptionIndex + 1) % 4;
      session.answerCurrent(wrongIndex);
      expect(q1.isCorrect, isFalse);
      expect(session.score, 1); // score remains 1
      expect(session.mistakesCount, 1);
      expect(session.mistakes.length, 1);
      expect(session.mistakes.first.question, q1);
      expect(session.mistakes.first.chosenAnswer, q1.options[wrongIndex]);
    });
  });
}
