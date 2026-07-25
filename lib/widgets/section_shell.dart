// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';
import '../utils/responsive.dart';
import 'section_header.dart';

/// Page inset, content cap and header rhythm for every section, so none of the
/// three is retyped per file and nothing runs the full width of the viewport.
class SectionShell extends StatelessWidget {
  final String title;
  final Widget child;
  final double maxWidth;

  const SectionShell({
    super.key,
    required this.title,
    required this.child,
    this.maxWidth = Layout.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.pageInset(context),
        vertical: Responsive.sectionInset(context),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(title: title),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Caps running text near 70 characters. Cards and grids tolerate the full
/// [Layout.content] width; prose does not.
class ProseBlock extends StatelessWidget {
  final Widget child;
  final bool centered;

  const ProseBlock({super.key, required this.child, this.centered = false});

  @override
  Widget build(BuildContext context) {
    // No Align in the uncentred case: it reports the wrong intrinsic height
    // inside the timeline's IntrinsicHeight and the card then overflows.
    final block = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Layout.prose),
      child: child,
    );
    return centered ? Center(child: block) : block;
  }
}

/// Equal columns that fill the content width, and one height per row.
///
/// A [Wrap] of fixed-width children fits as many as go and abandons the rest of
/// the column, so the grid stopped short of the section header and cards in the
/// same run ended at different heights.
class SectionGrid extends StatelessWidget {
  final List<Widget> children;
  final int desktopColumns;
  final int tabletColumns;
  final double gutter;
  final double runGutter;

  const SectionGrid({
    super.key,
    required this.children,
    this.desktopColumns = 2,
    this.tabletColumns = 2,
    this.gutter = Space.md,
    double? runGutter,
  }) : runGutter = runGutter ?? gutter;

  @override
  Widget build(BuildContext context) {
    final columns = switch (Responsive.tierOf(context)) {
      ScreenTier.mobile => 1,
      ScreenTier.tablet => tabletColumns,
      ScreenTier.desktop => desktopColumns,
    };

    final rows = <Widget>[];
    for (var start = 0; start < children.length; start += columns) {
      final cells = children.sublist(
        start,
        math.min(start + columns, children.length),
      );
      if (rows.isNotEmpty) {
        rows.add(SizedBox(height: runGutter));
      }
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var column = 0; column < columns; column++) ...[
                if (column > 0) SizedBox(width: gutter),
                // The trailing cells of an incomplete row are still claimed, so
                // the columns keep their width instead of widening to fit.
                Expanded(
                  child: column < cells.length
                      ? cells[column]
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Column(children: rows);
  }
}
