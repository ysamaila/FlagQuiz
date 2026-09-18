import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QuizOptionCard extends StatelessWidget {
  final String text;
  final int index;
  final bool isSelected;
  final bool isCorrectAnswer;
  final bool isAnswered;
  final VoidCallback? onTap;

  const QuizOptionCard({
    super.key,
    required this.text,
    required this.index,
    required this.isSelected,
    required this.isCorrectAnswer,
    required this.isAnswered,
    this.onTap,
  });

  static const _optionLabels = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    Color cardColor = AppTheme.surface;
    Color borderColor = AppTheme.border;
    Color badgeBgColor = AppTheme.surfaceVariant;
    Color badgeTextColor = AppTheme.textSecondary;
    Color textColor = AppTheme.textPrimary;
    Widget? trailingIcon;

    if (isAnswered) {
      if (isCorrectAnswer) {
        cardColor = AppTheme.success.withValues(alpha: 0.18);
        borderColor = AppTheme.success;
        badgeBgColor = AppTheme.success;
        badgeTextColor = Colors.white;
        trailingIcon = const Icon(Icons.check_circle, color: AppTheme.success, size: 22);
      } else if (isSelected && !isCorrectAnswer) {
        cardColor = AppTheme.error.withValues(alpha: 0.18);
        borderColor = AppTheme.error;
        badgeBgColor = AppTheme.error;
        badgeTextColor = Colors.white;
        trailingIcon = const Icon(Icons.cancel, color: AppTheme.error, size: 22);
      } else {
        textColor = AppTheme.textMuted;
        badgeTextColor = AppTheme.textMuted;
      }
    }

    final label = index < _optionLabels.length ? _optionLabels[index] : '${index + 1}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: isAnswered ? null : onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: isAnswered && (isCorrectAnswer || isSelected) ? 2 : 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: badgeTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: isAnswered && (isCorrectAnswer || isSelected)
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
                ?trailingIcon,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
