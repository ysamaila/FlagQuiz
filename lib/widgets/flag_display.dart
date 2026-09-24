import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FlagDisplay extends StatelessWidget {
  final String countryCode;
  final double width;
  final double height;
  final double borderRadius;

  const FlagDisplay({
    super.key,
    required this.countryCode,
    this.width = 160,
    this.height = 100,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppTheme.border.withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 18,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 1.5),
        child: CountryFlag.fromCountryCode(
          countryCode,
          theme: ImageTheme(
            width: width,
            height: height,
            shape: RoundedRectangle(borderRadius - 1.5),
          ),
        ),
      ),
    );
  }
}
