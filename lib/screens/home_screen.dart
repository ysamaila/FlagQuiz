import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/country_repository.dart';
import '../models/quiz_question.dart';
import '../services/preferences_service.dart';
import '../theme/app_theme.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  QuizMode _selectedMode = QuizMode.flags;
  int _questionCount = 10;
  int _highScore = 0;
  bool _isLoading = true;
  String? _errorMessage;

  static const List<int> _countOptions = [10, 25, 50, 195];

  @override
  void initState() {
    super.initState();
    _loadDataAndPreferences();
  }

  Future<void> _loadDataAndPreferences() async {
    try {
      await PreferencesService.instance.init();
      final preferredCount =
          PreferencesService.instance.getPreferredQuestionCount(fallback: 10);
      _questionCount = _countOptions.contains(preferredCount) ? preferredCount : 10;
      _updateHighScore();

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

  void _updateHighScore() {
    final best =
        PreferencesService.instance.getHighScore(_selectedMode, _questionCount);
    if (mounted) {
      setState(() {
        _highScore = best;
      });
    } else {
      _highScore = best;
    }
  }

  void _onCountSelected(int count) {
    if (_questionCount == count) return;
    HapticFeedback.lightImpact();
    setState(() {
      _questionCount = count;
      _updateHighScore();
    });
    PreferencesService.instance.setPreferredQuestionCount(count);
  }

  void _onModeSelected(QuizMode mode) {
    if (_selectedMode == mode) return;
    HapticFeedback.lightImpact();
    setState(() {
      _selectedMode = mode;
      _updateHighScore();
    });
  }

  Future<void> _startQuiz() async {
    if (_isLoading || _errorMessage != null) return;
    HapticFeedback.mediumImpact();

    final session = CountryRepository.instance.generateQuiz(
      mode: _selectedMode,
      questionCount: _questionCount,
    );

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(session: session),
      ),
    );

    // Refresh high score when returning to Home screen
    _updateHighScore();
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
                              onPressed: _loadDataAndPreferences,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.space24,
                        vertical: AppTheme.space16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: AppTheme.space16),
                          // App Logo & Title
                          Center(
                            child: Container(
                              width: 72,
                              height: 72,
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
                                size: 38,
                                color: AppTheme.primaryLight,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppTheme.space16),
                          Text(
                            'Flag Quiz',
                            textAlign: TextAlign.center,
                            style: AppTheme.heading(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: AppTheme.space8),
                          Text(
                            'Challenge yourself across all 195 UN member and observer states',
                            textAlign: TextAlign.center,
                            style: AppTheme.body(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: AppTheme.space24),

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
                                        onTap: () =>
                                            _onModeSelected(QuizMode.flags),
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
                                        onTap: () =>
                                            _onModeSelected(QuizMode.capitals),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppTheme.space16),

                          // Question Count Selector Card
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
                                  'QUESTIONS PER ROUND',
                                  style: AppTheme.heading(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textMuted,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: _countOptions.map((count) {
                                    final isSelected = _questionCount == count;
                                    final label = count == 195 ? 'All (195)' : '$count';
                                    return Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 3),
                                        child: InkWell(
                                          onTap: () => _onCountSelected(count),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 180),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppTheme.primary
                                                      .withValues(alpha: 0.22)
                                                  : AppTheme.surfaceVariant
                                                      .withValues(alpha: 0.6),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppTheme.primary
                                                    : AppTheme.border,
                                                width: isSelected ? 1.8 : 1,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              label,
                                              style: AppTheme.heading(
                                                fontSize: count == 195 ? 12 : 14,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                                color: isSelected
                                                    ? AppTheme.primaryLight
                                                    : AppTheme.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppTheme.space16),

                          // Best Score Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.space16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceVariant.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: AppTheme.border.withValues(alpha: 0.7)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _highScore > 0
                                        ? AppTheme.warning.withValues(alpha: 0.16)
                                        : AppTheme.surface,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _highScore > 0
                                        ? Icons.emoji_events_rounded
                                        : Icons.military_tech_outlined,
                                    size: 20,
                                    color: _highScore > 0
                                        ? AppTheme.warning
                                        : AppTheme.textMuted,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Personal Best (${_selectedMode.displayName} • $_questionCount Qs)',
                                        style: AppTheme.body(
                                          fontSize: 11,
                                          color: AppTheme.textMuted,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _highScore > 0
                                            ? '$_highScore / $_questionCount (${((_highScore / _questionCount) * 100).round()}%)'
                                            : 'No attempts yet',
                                        style: AppTheme.heading(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: _highScore > 0
                                              ? AppTheme.textPrimary
                                              : AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppTheme.space24),

                          // Start Button
                          ElevatedButton(
                            onPressed: _startQuiz,
                            child: Text(
                                'Start ${_selectedMode.displayName} Quiz ($_questionCount Qs)'),
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
