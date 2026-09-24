import 'package:flutter/material.dart';
import '../data/country_repository.dart';
import '../models/quiz_session.dart';
import '../theme/app_theme.dart';
import 'quiz_screen.dart';

class ResultsScreen extends StatelessWidget {
  final QuizSession session;

  const ResultsScreen({super.key, required this.session});

  String _getPerformanceMessage(int score, int total) {
    final ratio = score / total;
    if (ratio == 1.0) {
      return 'Flawless Victory! You know your nations!';
    } else if (ratio >= 0.8) {
      return 'Outstanding! Impressive geographic knowledge!';
    } else if (ratio >= 0.6) {
      return 'Great job! You really know your way around the world.';
    } else if (ratio >= 0.4) {
      return 'Good effort! A little more practice and you will master it.';
    } else {
      return 'Keep studying! The world is full of wonders to learn.';
    }
  }

  IconData _getPerformanceIcon(int score, int total) {
    final ratio = score / total;
    if (ratio >= 0.8) {
      return Icons.emoji_events_rounded;
    } else if (ratio >= 0.5) {
      return Icons.thumb_up_alt_rounded;
    } else {
      return Icons.school_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final score = session.score;
    final total = session.totalQuestions;
    final percentage = ((score / total) * 100).round();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.space24,
              vertical: AppTheme.space24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                // Trophy / Icon
                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getPerformanceIcon(score, total),
                      size: 48,
                      color: AppTheme.primaryLight,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.space24),

                Text(
                  'Quiz Completed!',
                  textAlign: TextAlign.center,
                  style: AppTheme.heading(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.space8),

                Text(
                  'Mode: ${session.mode.displayName}',
                  textAlign: TextAlign.center,
                  style: AppTheme.body(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTheme.space24),

                // Score Card
                Container(
                  padding: const EdgeInsets.all(AppTheme.space24),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppTheme.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$score',
                            style: AppTheme.heading(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                          Text(
                            ' / $total',
                            style: AppTheme.heading(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.space8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: score >= (total * 0.7)
                              ? AppTheme.success.withValues(alpha: 0.2)
                              : AppTheme.warning.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: score >= (total * 0.7)
                                ? AppTheme.success.withValues(alpha: 0.4)
                                : AppTheme.warning.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          '$percentage% Correct',
                          style: AppTheme.heading(
                            color: score >= (total * 0.7)
                                ? AppTheme.success
                                : AppTheme.warning,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.space16),
                      const Divider(color: AppTheme.border),
                      const SizedBox(height: AppTheme.space16),
                      Text(
                        _getPerformanceMessage(score, total),
                        textAlign: TextAlign.center,
                        style: AppTheme.body(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Play Again Button
                ElevatedButton(
                  onPressed: () {
                    final newSession = CountryRepository.instance.generateQuiz(
                      mode: session.mode,
                      questionCount: 10,
                    );
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => QuizScreen(session: newSession),
                      ),
                    );
                  },
                  child: const Text('Play Again'),
                ),
                const SizedBox(height: AppTheme.space16),

                // Back to Home Button
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textPrimary,
                    side: const BorderSide(color: AppTheme.border),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: AppTheme.heading(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Back to Home'),
                ),
                const SizedBox(height: AppTheme.space16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
