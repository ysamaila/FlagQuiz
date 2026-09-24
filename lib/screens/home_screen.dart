import 'package:flutter/material.dart';
import '../data/country_repository.dart';
import '../models/quiz_question.dart';
import '../theme/app_theme.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  QuizMode _selectedMode = QuizMode.flags;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      if (!CountryRepository.instance.isLoaded) {
        await CountryRepository.instance.loadCountries();
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load countries: $e';
        });
      }
    }
  }

  void _startQuiz() {
    if (_isLoading || _errorMessage != null) return;

    final session = CountryRepository.instance.generateQuiz(
      mode: _selectedMode,
      questionCount: 10,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(session: session),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                )
              : _errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.space24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppTheme.error,
                              size: 48,
                            ),
                            const SizedBox(height: AppTheme.space16),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: AppTheme.body(color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: AppTheme.space16),
                            ElevatedButton(
                              onPressed: _loadData,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.space24,
                        vertical: AppTheme.space24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Spacer(),
                          // App Logo & Title
                          Center(
                            child: Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.16),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.primary.withValues(alpha: 0.45),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppTheme.primary.withValues(alpha: 0.22),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.flag_rounded,
                                size: 42,
                                color: AppTheme.primaryLight,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppTheme.space24),
                          Text(
                            'Flag Quiz',
                            textAlign: TextAlign.center,
                            style: AppTheme.heading(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: AppTheme.space8),
                          Text(
                            'Challenge yourself across all 195 UN member and observer states',
                            textAlign: TextAlign.center,
                            style: AppTheme.body(
                              fontSize: 15,
                              color: AppTheme.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const Spacer(),

                          // Mode Selector Card
                          Container(
                            padding: const EdgeInsets.all(AppTheme.space16),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppTheme.border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SELECT MODE',
                                  style: AppTheme.heading(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textMuted,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.space16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _ModeOptionCard(
                                        title: 'Flags',
                                        subtitle: 'Guess by flag',
                                        icon: Icons.public_rounded,
                                        isSelected:
                                            _selectedMode == QuizMode.flags,
                                        onTap: () => setState(() =>
                                            _selectedMode = QuizMode.flags),
                                      ),
                                    ),
                                    const SizedBox(width: AppTheme.space16),
                                    Expanded(
                                      child: _ModeOptionCard(
                                        title: 'Capitals',
                                        subtitle: 'Guess capital city',
                                        icon: Icons.location_city_rounded,
                                        isSelected:
                                            _selectedMode == QuizMode.capitals,
                                        onTap: () => setState(() =>
                                            _selectedMode = QuizMode.capitals),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppTheme.space16),

                          // Round Information Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.space16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceVariant
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color:
                                      AppTheme.border.withValues(alpha: 0.7)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _InfoItem(
                                  icon: Icons.quiz_outlined,
                                  text: '10 Questions',
                                ),
                                _InfoItem(
                                  icon: Icons.timer_outlined,
                                  text: 'Self-paced',
                                ),
                                _InfoItem(
                                  icon: Icons.stars_rounded,
                                  text: '195 Nations',
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // Start Button
                          ElevatedButton(
                            onPressed: _startQuiz,
                            child:
                                Text('Start ${_selectedMode.displayName} Quiz'),
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

class _ModeOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: AppTheme.space16,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.16)
              : AppTheme.surfaceVariant.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryLight : AppTheme.textSecondary,
              size: 28,
            ),
            const SizedBox(height: AppTheme.space8),
            Text(
              title,
              style: AppTheme.heading(
                color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTheme.body(
                color: isSelected ? AppTheme.textSecondary : AppTheme.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryLight),
        const SizedBox(width: 6),
        Text(
          text,
          style: AppTheme.body(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
