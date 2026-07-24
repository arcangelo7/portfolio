// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/material.dart';

import '../utils/responsive.dart';

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Semantics(
      header: true,
      child: SelectableText(
        title,
        style: Theme.of(context).textTheme.displaySmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontSize: isMobile ? 28 : null,
        ),
        textAlign: isMobile ? TextAlign.center : null,
        semanticsLabel: 'Section heading: $title',
      ),
    );
  }
}
