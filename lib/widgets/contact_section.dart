// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../theme/design_tokens.dart';
import 'section_shell.dart';

/// Named links rather than tinted circles holding stand-in Material glyphs:
/// `Icons.code` was not GitHub, `Icons.work` was not LinkedIn, and X was pure
/// black on a near-black ground. The labels already say where each one goes.
class ContactSection extends StatelessWidget {
  final Locale currentLocale;

  const ContactSection({super.key, required this.currentLocale});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final websiteUrl = currentLocale.languageCode == 'it'
        ? 'https://www.unibo.it/sitoweb/arcangelo.massari'
        : 'https://www.unibo.it/sitoweb/arcangelo.massari/en';

    final links = <_ContactLink>[
      _ContactLink(l10n.email, 'mailto:arcangelo.massari@unibo.it'),
      _ContactLink(l10n.professionalWebsite, websiteUrl),
      _ContactLink(l10n.github, 'https://github.com/arcangelo7'),
      _ContactLink(l10n.orcid, 'https://orcid.org/0000-0002-8420-0696'),
      _ContactLink(
        l10n.linkedin,
        'https://www.linkedin.com/in/arcangelo-massari-4a736822b/',
      ),
      _ContactLink(l10n.twitter, 'https://x.com/arcangelo_wd'),
    ];

    return SectionShell(
      title: l10n.getInTouch,
      // No run gutter: the hairline under each row is the separator, so a gap
      // between rows would read as a break in the list.
      child: SectionGrid(
        gutter: Space.xl,
        runGutter: 0,
        children: [for (final link in links) _ContactRow(link: link)],
      ),
    );
  }
}

class _ContactLink {
  final String label;
  final String url;

  const _ContactLink(this.label, this.url);
}

class _ContactRow extends StatelessWidget {
  final _ContactLink link;

  const _ContactRow({required this.link});

  Future<void> _launch() async {
    final uri = Uri.parse(link.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: _launch,
      borderRadius: Radii.pill,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: Space.md),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                link.label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.arrow_outward,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
