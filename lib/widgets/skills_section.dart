// SPDX-FileCopyrightText: 2025 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/localization_helper.dart';
import '../models/cv_data.dart';
import '../services/cv_data_service.dart';
import '../theme/design_tokens.dart';
import 'flutter_modal.dart';
import 'section_shell.dart';

class SkillsSection extends StatefulWidget {
  final SkillsData? data;

  const SkillsSection({super.key, this.data});

  @override
  State<SkillsSection> createState() => _SkillsSectionState();
}

class _SkillsSectionState extends State<SkillsSection> {
  SkillsData? _skillsData;
  late bool _isLoading;
  String? _error;

  @override
  void initState() {
    super.initState();
    _skillsData = widget.data;
    _isLoading = widget.data == null;
    if (_isLoading) {
      _loadSkills();
    }
  }

  @override
  void didUpdateWidget(SkillsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != null && oldWidget.data != widget.data) {
      _skillsData = widget.data;
      _isLoading = false;
      _error = null;
    }
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

    return SectionShell(title: l10n.skills, child: _buildContent(l10n));
  }

  Widget _buildContent(AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Text(l10n.errorLoadingSkills(_error!));
    }

    if (_skillsData == null) {
      return Text(l10n.noSkillsDataAvailable);
    }

    return SectionGrid(
      children: [
        for (final category in _skillsData!.categories)
          _CategoryCard(
            name: LocalizationHelper.getLocalizedText(l10n, category.nameKey),
            skills: [
              for (final skill in category.skills)
                LocalizationHelper.getLocalizedText(l10n, skill.nameKey),
            ],
          ),
      ],
    );
  }
}

/// Categories used to be told apart by ten Tailwind hues applied in list
/// order, which encoded nothing. The card and its name already group them, so
/// the colour is gone and the accent is kept for the one chip that does
/// something when clicked.
class _CategoryCard extends StatelessWidget {
  final String name;
  final List<String> skills;

  const _CategoryCard({required this.name, required this.skills});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(Space.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: Radii.card,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            name,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Space.sm),
          Wrap(
            spacing: Space.xs,
            runSpacing: Space.xs,
            children: [
              for (final skill in skills)
                if (skill == l10n.skillFlutter)
                  _ShiningSkillChip(
                    label: skill,
                    onTap: () => showDialog<void>(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) => const FlutterModal(),
                    ),
                  )
                else
                  _SkillChip(label: skill),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;

  const _SkillChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: _chipPadding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: Radii.pill,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

const EdgeInsets _chipPadding = EdgeInsets.symmetric(
  horizontal: Space.sm,
  vertical: Space.xxs,
);

/// The one chip that opens something, so it advertises itself with a slow
/// diagonal sheen instead of relying on colour alone.
class _ShiningSkillChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _ShiningSkillChip({required this.label, required this.onTap});

  @override
  State<_ShiningSkillChip> createState() => _ShiningSkillChipState();
}

class _ShiningSkillChipState extends State<_ShiningSkillChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: Radii.pill,
        child: ClipRRect(
          borderRadius: Radii.pill,
          child: Stack(
            children: [
              Container(
                padding: _chipPadding,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: Radii.pill,
                ),
                child: Text(
                  widget.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final sweep = const Interval(
                        0,
                        0.3,
                        curve: Curves.easeInOut,
                      ).transform(_controller.value);
                      return FractionalTranslation(
                        translation: Offset(-1.5 + sweep * 3, 0),
                        child: Transform(
                          transform: Matrix4.identity()
                            ..rotateZ(0.4)
                            ..scaleByDouble(1.0, 3.0, 1.0, 1.0),
                          alignment: Alignment.center,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.onPrimary.withValues(alpha: 0),
                                  colorScheme.onPrimary.withValues(alpha: 0),
                                  colorScheme.onPrimary.withValues(alpha: 0.45),
                                  colorScheme.onPrimary.withValues(alpha: 0),
                                  colorScheme.onPrimary.withValues(alpha: 0),
                                ],
                                stops: const [0, 0.4, 0.5, 0.6, 1],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
