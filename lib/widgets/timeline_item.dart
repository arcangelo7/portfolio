// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// The rail is stacked behind the card rather than sized next to it with an
/// `IntrinsicHeight`: intrinsic sizing mis-measures the selectable rich text in
/// the card body, and it costs an extra layout pass per entry.
class TimelineItem extends StatelessWidget {
  final Widget child;
  final bool isFirst;
  final bool isLast;
  final bool isCurrent;
  final bool isMobile;
  final double spacing;
  final double? nodeCenter;

  const TimelineItem({
    super.key,
    required this.child,
    required this.isFirst,
    required this.isLast,
    required this.isCurrent,
    required this.isMobile,
    this.spacing = Space.xl,
    this.nodeCenter,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final railWidth = isMobile ? 16.0 : 24.0;
    final center = nodeCenter ?? (isMobile ? 28.0 : 36.0);
    final showLine = !(isFirst && isLast);

    return Stack(
      children: [
        if (showLine)
          Positioned(
            left: railWidth / 2 - 1,
            top: isFirst ? center : 0,
            bottom: isLast ? null : 0,
            height: isLast ? center : null,
            width: 2,
            child: ColoredBox(color: colorScheme.outlineVariant),
          ),
        Positioned(
          top: center - 10,
          left: railWidth / 2 - 10,
          width: 20,
          height: 20,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCurrent
                  ? colorScheme.primary.withValues(alpha: 0.2)
                  : Colors.transparent,
            ),
            child: Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrent ? colorScheme.primary : colorScheme.surface,
                  border: isCurrent
                      ? null
                      : Border.all(color: colorScheme.outline, width: 2),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: railWidth + Space.sm,
            bottom: isLast ? 0 : spacing,
          ),
          child: child,
        ),
      ],
    );
  }
}
