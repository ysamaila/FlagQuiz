import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FlagDisplay extends StatelessWidget {
  final String countryCode;
  final String? countryName;
  final double width;
  final double height;
  final double borderRadius;

  const FlagDisplay({
    super.key,
    required this.countryCode,
    this.countryName,
    this.width = 160,
    this.height = 100,
    this.borderRadius = 16,
  });

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      color: AppTheme.surfaceVariant,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.flag_outlined,
            size: 28,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 4),
          Text(
            countryCode.isNotEmpty ? countryCode.toUpperCase() : 'FLAG',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

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
        child: countryCode.trim().length == 2
            ? CountryFlag.fromCountryCode(
                countryCode,
                theme: ImageTheme(
                  width: width,
                  height: height,
                  shape: RoundedRectangle(borderRadius - 1.5),
                ),
              )
            : _buildFallback(),
      ),
    );
  }
}
