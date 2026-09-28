import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/country_repository.dart';
import '../models/quiz_session.dart';
import '../services/preferences_service.dart';
import '../theme/app_theme.dart';
import 'quiz_screen.dart';
import 'review_mistakes_screen.dart';

class ResultsScreen extends StatefulWidget {
  final QuizSession session;

  const ResultsScreen({super.key, required this.session});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _isNewHighScore = false;

  @override
  void initState() {
    super.initState();
    _checkHighScore();
  }

  Future<void> _checkHighScore() async {
    final session = widget.session;
    final isNew = await PreferencesService.instance.updateHighScoreIfBest(
      session.mode,
      session.totalQuestions,
      session.score,
    );
    if (mounted && isNew) {
      setState(() {
        _isNewHighScore = true;
      });
    }
  }

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

  String _getPerformanceTitle(int score, int total) {
    final ratio = score / total;
    if (ratio == 1.0) {
      return 'Perfect Score!';
    } else if (ratio >= 0.8) {
      return 'Flag Master!';
    } else if (ratio >= 0.6) {
      return 'Great Effort!';
    } else {
      return 'Keep Practicing!';
    }
  }

  IconData _getPerformanceIcon(int score, int total) {
    final ratio = score / total;
    if (ratio == 1.0) {
      return Icons.emoji_events;
    } else if (ratio >= 0.8) {
      return Icons.military_tech;
    } else if (ratio >= 0.6) {
      return Icons.thumb_up;
    } else {
      return Icons.menu_book;
    }
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.session.score;
    final total = widget.session.totalQuestions;
    final percentage = ((score / total) * 100).round();
    final hasMistakes = widget.session.mistakes.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.space24,
              vertical: AppTheme.space24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppTheme.space16),
                // Performance Trophy / Icon with Entrance Pulse
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
                )
                    .animate()
                    .scaleXY(
                        begin: 0.7,
                        end: 1.0,
                        duration: 400.ms,
                        curve: Curves.easeOutBack)
                    .fadeIn(),
                const SizedBox(height: AppTheme.space24),

                Text(
                  _getPerformanceTitle(score, total),
                  textAlign: TextAlign.center,
                  style: AppTheme.heading(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: AppTheme.space8),

                Text(
                  'Mode: ${widget.session.mode.displayName} • $total Questions',
                  textAlign: TextAlign.center,
                  style: AppTheme.body(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: AppTheme.space16),

                // New High Score Banner
                if (_isNewHighScore) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.warning.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.emoji_events_rounded,
                          color: AppTheme.warning,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'New Personal Best!',
                          style: AppTheme.heading(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.warning,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .scaleXY(begin: 0.9, end: 1.0, duration: 300.ms)
                      .fadeIn(),
                  const SizedBox(height: AppTheme.space16),
                ],

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
                      // Animated count-up score display
                      TweenAnimationBuilder<int>(
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        tween: IntTween(begin: 0, end: score),
                        builder: (context, animatedScore, _) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '$animatedScore',
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
                          );
                        },
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
                ).animate().slideY(begin: 0.1, end: 0, duration: 350.ms).fadeIn(),

                const SizedBox(height: AppTheme.space24),

                // Review Mistakes Button (if mistakes exist)
                if (hasMistakes) ...[
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryLight,
                      side: BorderSide(
                        color: AppTheme.primary.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                      backgroundColor:
                          AppTheme.primary.withValues(alpha: 0.08),
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
                    icon: const Icon(Icons.fact_check_outlined, size: 20),
                    label: Text(
                        'Review Mistakes (${widget.session.mistakesCount})'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ReviewMistakesScreen(
                            mistakes: widget.session.mistakes,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppTheme.space16),
                ],

                // Play Again Button
                ElevatedButton(
                  onPressed: () {
                    final newSession = CountryRepository.instance.generateQuiz(
                      mode: widget.session.mode,
                      questionCount: widget.session.totalQuestions,
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
