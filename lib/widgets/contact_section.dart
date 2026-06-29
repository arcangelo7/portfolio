// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../utils/responsive.dart';

class ContactSection extends StatelessWidget {
  final Locale currentLocale;

  const ContactSection({super.key, required this.currentLocale});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final l10n = AppLocalizations.of(context)!;
    final professionalWebsiteUrl =
        currentLocale.languageCode == 'it'
            ? 'https://www.unibo.it/sitoweb/arcangelo.massari'
            : 'https://www.unibo.it/sitoweb/arcangelo.massari/en';

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 64),
      child: Column(
        children: [
          Semantics(
            header: true,
            child: SelectableText(
              l10n.getInTouch,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                fontSize: isMobile ? 28 : null,
              ),
              semanticsLabel: 'Section heading: ${l10n.getInTouch}',
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: isMobile ? 16 : 24,
            runSpacing: isMobile ? 16 : 24,
            children: [
              _ContactButton(
                icon: Icons.email,
                label: l10n.email,
                url: 'mailto:arcangelo.massari@unibo.it',
                color: Theme.of(context).colorScheme.tertiary,
                isMobile: isMobile,
              ),
              _ContactButton(
                icon: Icons.web,
                label: l10n.professionalWebsite,
                url: professionalWebsiteUrl,
                color: Theme.of(context).colorScheme.secondary,
                isMobile: isMobile,
              ),
              _ContactButton(
                icon: Icons.code,
                label: l10n.github,
                url: 'https://github.com/arcangelo7',
                color: Theme.of(context).colorScheme.primary,
                isMobile: isMobile,
              ),
              _ContactButton(
                icon: Icons.science,
                label: l10n.orcid,
                url: 'https://orcid.org/0000-0002-8420-0696',
                color: const Color(0xFFA6CE39),
                isMobile: isMobile,
              ),
              _ContactButton(
                icon: Icons.work,
                label: l10n.linkedin,
                url: 'https://www.linkedin.com/in/arcangelo-massari-4a736822b/',
                color: const Color(0xFF0077B5),
                isMobile: isMobile,
              ),
              _ContactButton(
                icon: Icons.alternate_email,
                label: l10n.twitter,
                url: 'https://x.com/arcangelo_wd',
                color: const Color(0xFF000000),
                isMobile: isMobile,
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;
  final Color color;
  final bool isMobile;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.url,
    required this.color,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _launchUrl(url),
            borderRadius: BorderRadius.circular(50),
            child: Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                border: Border.all(color: color.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(icon, size: isMobile ? 24 : 28, color: color),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SelectableText(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.8),
            fontSize: isMobile ? 11 : 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
