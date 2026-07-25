// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'markdown_text.dart';
import 'section_shell.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SectionShell(
      title: l10n.aboutMe,
      child: ProseBlock(
        child: MarkdownText(
          text: l10n.aboutMeDescription,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
