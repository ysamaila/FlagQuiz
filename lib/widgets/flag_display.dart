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
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppTheme.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 1),
        child: CountryFlag.fromCountryCode(
          countryCode,
          theme: ImageTheme(
            width: width,
            height: height,
            shape: RoundedRectangle(borderRadius - 1),
          ),
        ),
      ),
    );
  }
}
