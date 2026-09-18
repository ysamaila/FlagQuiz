import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/country.dart';
import '../models/quiz_question.dart';
import '../models/quiz_session.dart';

class CountryRepository {
  static final CountryRepository instance = CountryRepository._internal();
  CountryRepository._internal();
  factory CountryRepository() => instance;

  List<Country> _countries = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  List<Country> get countries => List.unmodifiable(_countries);

  Future<void> loadCountries({String? jsonString}) async {
    final String content =
        jsonString ?? await rootBundle.loadString('assets/data/countries.json');
    final List<dynamic> jsonList = jsonDecode(content) as List<dynamic>;
    _countries = jsonList
        .map((e) => Country.fromJson(e as Map<String, dynamic>))
        .toList();
    _isLoaded = true;
  }

  QuizSession generateQuiz({
    required QuizMode mode,
    int questionCount = 10,
    Random? random,
  }) {
    if (_countries.isEmpty) {
      throw StateError(
          'Countries dataset has not been loaded. Call loadCountries() first.');
    }

    final rand = random ?? Random();
    final available = List<Country>.from(_countries)..shuffle(rand);
    final selectedCountries = available.take(questionCount).toList();

    final questions = <QuizQuestion>[];

    for (final target in selectedCountries) {
      // Find 3 distinct distractors from the remaining countries
      final distractors = _countries
          .where((c) => c.code != target.code)
          .toList()
        ..shuffle(rand);

      final chosenDistractors = distractors.take(3).toList();

      final optionsList = <String>[];
      final String correctAnswer;

      if (mode == QuizMode.flags) {
        correctAnswer = target.name;
        optionsList.add(target.name);
        for (final d in chosenDistractors) {
          optionsList.add(d.name);
        }
      } else {
        correctAnswer = target.capital;
        optionsList.add(target.capital);
        for (final d in chosenDistractors) {
          optionsList.add(d.capital);
        }
      }

      // Shuffle the 4 options
      optionsList.shuffle(rand);
      final correctIndex = optionsList.indexOf(correctAnswer);

      questions.add(
        QuizQuestion(
          country: target,
          mode: mode,
          options: optionsList,
          correctOptionIndex: correctIndex,
        ),
      );
    }

    return QuizSession(mode: mode, questions: questions);
  }
}
