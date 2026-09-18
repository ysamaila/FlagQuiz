import 'package:flutter/material.dart';
import '../models/quiz_question.dart';
import '../models/quiz_session.dart';
import '../theme/app_theme.dart';
import '../widgets/flag_display.dart';
import '../widgets/quiz_option_card.dart';
import 'results_screen.dart';

class QuizScreen extends StatefulWidget {
  final QuizSession session;

  const QuizScreen({super.key, required this.session});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _isTransitioning = false;

  void _onOptionSelected(int optionIndex) {
    if (_isTransitioning || widget.session.isCurrentAnswered) return;

    setState(() {
      widget.session.answerCurrent(optionIndex);
      _isTransitioning = true;
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;

      if (widget.session.isLastQuestion) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ResultsScreen(session: widget.session),
          ),
        );
      } else {
        setState(() {
          widget.session.nextQuestion();
          _isTransitioning = false;
        });
      }
    });
  }

  Future<bool> _onWillPop() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Quit Quiz?'),
        content: const Text(
            'Are you sure you want to exit? Your progress in this round will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continue Quiz',
                style: TextStyle(color: AppTheme.primaryLight)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Quit', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
    return shouldLeave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = widget.session.currentQuestion;
    final total = widget.session.totalQuestions;
    final currentNumber = widget.session.questionNumber;
    final progress = (currentNumber - 1) / total;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text('Question $currentNumber of $total'),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: AppTheme.warning, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.session.score}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Linear Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppTheme.surfaceVariant,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
                ),
                const SizedBox(height: 20),

                // Question Prompt Area
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (currentQ.mode == QuizMode.flags) ...[
                          FlagDisplay(
                            countryCode: currentQ.country.code,
                            width: 170,
                            height: 110,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            currentQ.questionTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ] else ...[
                          // Capitals Mode
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FlagDisplay(
                                countryCode: currentQ.country.code,
                                width: 56,
                                height: 38,
                                borderRadius: 6,
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  currentQ.country.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'What is the capital city?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Answer Options
                Expanded(
                  flex: 4,
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: currentQ.options.length,
                    itemBuilder: (context, index) {
                      final optionText = currentQ.options[index];
                      final isSelected = currentQ.userSelectedIndex == index;
                      final isCorrect = currentQ.correctOptionIndex == index;

                      return QuizOptionCard(
                        text: optionText,
                        index: index,
                        isSelected: isSelected,
                        isCorrectAnswer: isCorrect,
                        isAnswered: currentQ.isAnswered,
                        onTap: () => _onOptionSelected(index),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
