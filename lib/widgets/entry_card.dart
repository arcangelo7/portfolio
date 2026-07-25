// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';
import '../utils/responsive.dart';
import 'markdown_text.dart';
import 'section_shell.dart';

/// One card grammar for work, education and conferences, which were three
/// near-identical copies.
///
/// A card carries either a border or a shadow, never both: separating them by
/// one percent of luminance reads as noise rather than depth. The accent is
/// spent only on what is current, so it means something.
class EntryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String period;
  final String description;
  final bool isCurrent;
  final List<Widget> attachments;

  const EntryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.period,
    required this.description,
    required this.isCurrent,
    this.attachments = const [],
  });

  static double padding(bool isMobile) => isMobile ? Space.md : Space.lg;

  /// Where the timeline node lines up with the title, derived from the card's
  /// own padding and type scale instead of being tuned by hand.
  static double nodeCenter(BuildContext context, bool isMobile) {
    final style = Theme.of(context).textTheme.titleLarge!;
    return padding(isMobile) + (style.fontSize! * style.height!) / 2;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMobile = Responsive.isMobile(context);

    final titleText = SelectableText(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
    );
    final subtitleText = SelectableText(
      subtitle,
      style: theme.textTheme.titleMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    );
    final periodBadge = _PeriodBadge(period: period, isCurrent: isCurrent);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding(isMobile)),
      decoration: BoxDecoration(
        color: isCurrent
            ? colorScheme.surfaceContainerHigh
            : colorScheme.surfaceContainer,
        borderRadius: Radii.card,
        border: Border.all(
          color: isCurrent ? colorScheme.primary : colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleText,
                const SizedBox(height: Space.xxs),
                subtitleText,
                const SizedBox(height: Space.sm),
                Align(alignment: Alignment.centerLeft, child: periodBadge),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleText,
                      const SizedBox(height: Space.xxs),
                      subtitleText,
                    ],
                  ),
                ),
                const SizedBox(width: Space.md),
                periodBadge,
              ],
            ),
          const SizedBox(height: Space.md),
          ProseBlock(
            child: MarkdownText(
              text: description,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          if (attachments.isNotEmpty) ...[
            const SizedBox(height: Space.sm),
            Wrap(
              spacing: Space.xs,
              runSpacing: Space.xs,
              children: attachments,
            ),
          ],
        ],
      ),
    );
  }
}

class _PeriodBadge extends StatelessWidget {
  final String period;
  final bool isCurrent;

  const _PeriodBadge({required this.period, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.xs,
        vertical: Space.xxs,
      ),
      decoration: BoxDecoration(
        color: isCurrent
            ? colorScheme.primary.withValues(alpha: 0.12)
            : colorScheme.surfaceContainerHighest,
        borderRadius: Radii.pill,
      ),
      child: SelectableText(
        period,
        style: theme.textTheme.labelMedium?.copyWith(
          color: isCurrent ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
