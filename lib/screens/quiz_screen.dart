import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

    // Immediate tactile feedback on touch
    HapticFeedback.lightImpact();

    setState(() {
      widget.session.answerCurrent(optionIndex);
      _isTransitioning = true;
    });

    // Evaluation haptic feedback
    HapticFeedback.mediumImpact();

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
    final targetProgress = currentNumber / total;

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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(
            'Question $currentNumber of $total',
            style: AppTheme.heading(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: AppTheme.space16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.border.withValues(alpha: 0.8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: AppTheme.warning, size: 18),
                  const SizedBox(width: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Text(
                      '${widget.session.score}',
                      key: ValueKey<int>(widget.session.score),
                      style: AppTheme.heading(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: AppBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.space24,
                vertical: AppTheme.space16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Smooth animated linear progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      tween: Tween<double>(begin: 0.0, end: targetProgress),
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        minHeight: 6,
                        backgroundColor: AppTheme.surfaceVariant,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.space24),

                  // Animated question content with slide & fade
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.06, 0.0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey<int>(currentNumber),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Question Prompt Area
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: const EdgeInsets.all(AppTheme.space16),
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppTheme.border),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.28),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (currentQ.mode == QuizMode.flags) ...[
                                      FlagDisplay(
                                        countryCode: currentQ.country.code,
                                        countryName: currentQ.country.name,
                                        width: 175,
                                        height: 115,
                                      ),
                                      const SizedBox(height: AppTheme.space16),
                                      Text(
                                        currentQ.questionTitle,
                                        textAlign: TextAlign.center,
                                        style: AppTheme.heading(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ] else ...[
                                      // Capitals Mode
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          FlagDisplay(
                                            countryCode: currentQ.country.code,
                                            countryName: currentQ.country.name,
                                            width: 60,
                                            height: 40,
                                            borderRadius: 8,
                                          ),
                                          const SizedBox(
                                              width: AppTheme.space16),
                                          Flexible(
                                            child: Text(
                                              currentQ.country.name,
                                              style: AppTheme.heading(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppTheme.space16),
                                      Text(
                                        'What is the capital city?',
                                        textAlign: TextAlign.center,
                                        style: AppTheme.body(
                                          fontSize: 16,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppTheme.space24),

                            // Answer Options
                            Expanded(
                              flex: 4,
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: currentQ.options.length,
                                itemBuilder: (context, index) {
                                  final optionText = currentQ.options[index];
                                  final isSelected =
                                      currentQ.userSelectedIndex == index;
                                  final isCorrect =
                                      currentQ.correctOptionIndex == index;

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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
