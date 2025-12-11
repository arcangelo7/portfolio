import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../l10n/localization_helper.dart';
import '../services/cv_data_service.dart';
import '../models/cv_data.dart';
import '../main.dart';
import 'flutter_modal.dart';

class SkillsSection extends StatefulWidget {
  const SkillsSection({super.key});

  @override
  State<SkillsSection> createState() => _SkillsSectionState();
}

class _SkillsSectionState extends State<SkillsSection> {
  SkillsData? _skillsData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    try {
      final skillsData = await CVDataService.getSkills();
      if (mounted) {
        setState(() {
          _skillsData = skillsData;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _skillsData = null;
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: EdgeInsets.all(isMobile ? 20 : 64),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Column(
        children: [
          Semantics(
            header: true,
            child: SelectableText(
              l10n.skills,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                fontSize: isMobile ? 28 : null,
              ),
              semanticsLabel: 'Section heading: ${l10n.skills}',
            ),
          ),
          const SizedBox(height: 32),
          _buildContent(context, l10n, isMobile),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n, bool isMobile) {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }

    if (_error != null) {
      return Text('Error loading skills: $_error');
    }

    if (_skillsData == null) {
      return const Text('No skills data available');
    }

    final skillsCategories = <String, List<String>>{};

    for (final category in _skillsData!.categories) {
      final categoryName = LocalizationHelper.getLocalizedText(
        l10n,
        category.nameKey,
      );
      final skillNames = category.skills
          .map((skill) => LocalizationHelper.getLocalizedText(
                l10n,
                skill.nameKey,
              ))
          .toList();
      skillsCategories[categoryName] = skillNames;
    }

    return SkillsBubbleChart(
      skillsCategories: skillsCategories,
      isMobile: isMobile,
    );
  }
}

class SkillsBubbleChart extends StatelessWidget {
  final Map<String, List<String>> skillsCategories;
  final bool isMobile;

  const SkillsBubbleChart({
    super.key,
    required this.skillsCategories,
    required this.isMobile,
  });

  List<Color> get _categoryColors => [
    const Color(0xFFEF4444), // Red
    const Color(0xFFF97316), // Orange
    const Color(0xFFEAB308), // Yellow
    const Color(0xFF10B981), // Green/Emerald
    const Color(0xFF059669), // Teal
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFF6366F1), // Blue/Indigo
    const Color(0xFF8B5CF6), // Violet
    const Color(0xFFEC4899), // Pink/Magenta
    const Color(0xFF6B7280), // Gray
  ];

  Color _getCategoryColor(int index, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = _categoryColors[index % _categoryColors.length];
    return isDark ? baseColor.withValues(alpha: 0.8) : baseColor;
  }

  Color _getDarkerCategoryColor(Color categoryColor, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hsl = HSLColor.fromColor(categoryColor);

    if (isDark) {
      return hsl
          .withLightness((hsl.lightness * 1.5).clamp(0.0, 1.0))
          .withSaturation((hsl.saturation * 1.3).clamp(0.0, 1.0))
          .toColor();
    } else {
      return hsl
          .withLightness((hsl.lightness * 0.4).clamp(0.0, 1.0))
          .withSaturation((hsl.saturation * 1.2).clamp(0.0, 1.0))
          .toColor();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : 16,
              vertical: 16,
            ),
            child: _buildBubbleLayout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBubbleLayout(BuildContext context) {
    final categoryEntries = skillsCategories.entries.toList();

    return Wrap(
      spacing: isMobile ? 8 : 12,
      runSpacing: isMobile ? 12 : 16,
      alignment: WrapAlignment.center,
      children:
          categoryEntries.asMap().entries.map((mapEntry) {
            final index = mapEntry.key;
            final categoryEntry = mapEntry.value;
            final categoryColor = _getCategoryColor(index, context);

            return _buildCategoryBubble(
              context,
              categoryEntry.key,
              categoryEntry.value,
              categoryColor,
            );
          }).toList(),
    );
  }

  Widget _buildCategoryBubble(
    BuildContext context,
    String category,
    List<String> skills,
    Color categoryColor,
  ) {
    return Container(
      margin: EdgeInsets.all(isMobile ? 4 : 8),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            categoryColor.withValues(alpha: 0.15),
            categoryColor.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.7),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        border: Border.all(
          color: categoryColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isMobile ? 8 : 10,
                height: isMobile ? 8 : 10,
                decoration: BoxDecoration(
                  color: categoryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: SelectableText(
                  category,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: _getDarkerCategoryColor(categoryColor, context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Wrap(
            spacing: isMobile ? 6 : 8,
            runSpacing: isMobile ? 6 : 8,
            alignment: WrapAlignment.center,
            children:
                skills
                    .map(
                      (skill) =>
                          _buildSkillBubble(context, skill, categoryColor),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillBubble(
    BuildContext context,
    String skill,
    Color categoryColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final isFlutter = skill == l10n.skillFlutter;

    if (isFlutter) {
      return _buildFlutterSkillBubble(context, skill);
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 8 : 10,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [categoryColor, categoryColor.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SelectableText(
        skill,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: isMobile ? 13 : 14,
        ),
      ),
    );
  }

  Widget _buildFlutterSkillBubble(BuildContext context, String skill) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () => _showFlutterModal(context),
        borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 14 : 18,
            vertical: isMobile ? 10 : 12,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                PortfolioTheme.cobaltBlue,
                PortfolioTheme.cobaltBlue.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
            boxShadow: [
              BoxShadow(
                color: PortfolioTheme.cobaltBlue.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
              BoxShadow(
                color: PortfolioTheme.cobaltBlue.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.flutter_dash,
                color: Colors.white,
                size: isMobile ? 16 : 18,
              ),
              const SizedBox(width: 6),
              SelectableText(
                skill,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: isMobile ? 13 : 14,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.open_in_new,
                color: Colors.white.withValues(alpha: 0.8),
                size: isMobile ? 12 : 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFlutterModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const FlutterModal(),
    );
  }
}
