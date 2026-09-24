import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    List<BoxShadow> shadows = [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.28),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];
    Widget? trailingIcon;

    if (isAnswered) {
      if (isCorrectAnswer) {
        cardColor = AppTheme.success.withValues(alpha: 0.16);
        borderColor = AppTheme.success;
        badgeBgColor = AppTheme.success;
        badgeTextColor = Colors.white;
        shadows = [
          BoxShadow(
            color: AppTheme.success.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ];
        trailingIcon = const Icon(Icons.check_circle_rounded,
            color: AppTheme.success, size: 22);
      } else if (isSelected && !isCorrectAnswer) {
        cardColor = AppTheme.error.withValues(alpha: 0.16);
        borderColor = AppTheme.error;
        badgeBgColor = AppTheme.error;
        badgeTextColor = Colors.white;
        shadows = [
          BoxShadow(
            color: AppTheme.error.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ];
        trailingIcon =
            const Icon(Icons.cancel_rounded, color: AppTheme.error, size: 22);
      } else {
        textColor = AppTheme.textMuted;
        badgeTextColor = AppTheme.textMuted;
        shadows = [];
      }
    }

    final label =
        index < _optionLabels.length ? _optionLabels[index] : '${index + 1}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: shadows,
        ),
        child: Material(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: isAnswered ? null : onTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: borderColor,
                  width: isAnswered && (isCorrectAnswer || isSelected) ? 2 : 1.2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: badgeBgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      style: GoogleFonts.sora(
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
                      style: GoogleFonts.inter(
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
      ),
    );
  }
}
