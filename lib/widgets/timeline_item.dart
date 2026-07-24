// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/material.dart';

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
    this.spacing = 32,
    this.nodeCenter,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final railWidth = isMobile ? 16.0 : 24.0;
    final center = nodeCenter ?? (isMobile ? 28.0 : 36.0);
    final lineColor = colorScheme.onSurface.withValues(alpha: 0.15);
    final showLine = !(isFirst && isLast);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: railWidth,
            child: Stack(
              children: [
                if (showLine)
                  Positioned(
                    left: railWidth / 2 - 1,
                    top: isFirst ? center : 0,
                    bottom: isLast ? null : 0,
                    height: isLast ? center : null,
                    child: Container(width: 2, color: lineColor),
                  ),
                Positioned(
                  top: center - 10,
                  left: railWidth / 2 - 10,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCurrent
                          ? colorScheme.primary.withValues(alpha: 0.2)
                          : null,
                    ),
                    child: Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCurrent
                              ? colorScheme.primary
                              : colorScheme.surface,
                          border: isCurrent
                              ? null
                              : Border.all(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.35,
                                  ),
                                  width: 2,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : spacing),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
