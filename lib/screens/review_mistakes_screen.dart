import 'package:flutter/material.dart';
import '../models/quiz_question.dart';
import '../models/quiz_session.dart';
import '../theme/app_theme.dart';
import '../widgets/flag_display.dart';

class ReviewMistakesScreen extends StatelessWidget {
  final List<QuizMistake> mistakes;

  const ReviewMistakesScreen({super.key, required this.mistakes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Review Mistakes (${mistakes.length})',
          style: AppTheme.heading(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.space24,
              vertical: AppTheme.space16,
            ),
            itemCount: mistakes.length,
            itemBuilder: (context, index) {
              final mistake = mistakes[index];
              final q = mistake.question;

              return Container(
                margin: const EdgeInsets.only(bottom: AppTheme.space16),
                padding: const EdgeInsets.all(AppTheme.space16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Flag and Country Info
                    Row(
                      children: [
                        FlagDisplay(
                          countryCode: q.country.code,
                          countryName: q.country.name,
                          width: q.mode == QuizMode.flags ? 76 : 56,
                          height: q.mode == QuizMode.flags ? 50 : 38,
                          borderRadius: 10,
                        ),
                        const SizedBox(width: AppTheme.space16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                q.country.name,
                                style: AppTheme.heading(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${q.country.continent} • Capital: ${q.country.capital}',
                                style: AppTheme.body(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.space16),
                    const Divider(color: AppTheme.border, height: 1),
                    const SizedBox(height: AppTheme.space16),

                    // User Incorrect Answer
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.error.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.cancel_rounded,
                            color: AppTheme.error,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your answer: ${mistake.chosenAnswer}',
                              style: AppTheme.body(
                                fontSize: 13,
                                color: AppTheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Correct Answer
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.success.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppTheme.success,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Correct: ${q.correctAnswerText}',
                              style: AppTheme.body(
                                fontSize: 13,
                                color: AppTheme.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
