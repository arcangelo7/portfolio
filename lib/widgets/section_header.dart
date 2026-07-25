// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';
import '../utils/responsive.dart';

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = Responsive.isMobile(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: Space.xl),
      child: Column(
        crossAxisAlignment: isMobile
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: SelectableText(
              title,
              style: theme.textTheme.displaySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontSize: isMobile ? 30 : null,
              ),
              textAlign: isMobile ? TextAlign.center : TextAlign.start,
              semanticsLabel: 'Section heading: $title',
            ),
          ),
          const SizedBox(height: Space.md),
          _HorizonRule(centered: isMobile),
        ],
      ),
    );
  }
}

/// A hairline that fades out like the horizon in the star field. It is the only
/// structural mark the headers carry, so the page reads as sections rather than
/// a continuous stack of text.
class _HorizonRule extends StatelessWidget {
  final bool centered;

  const _HorizonRule({required this.centered});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final transparent = accent.withValues(alpha: 0);

    return SizedBox(
      width: centered ? 120 : 96,
      height: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: centered
                ? [transparent, accent, transparent]
                : [accent, transparent],
          ),
        ),
      ),
    );
  }
}
