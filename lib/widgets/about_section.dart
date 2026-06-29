// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../utils/responsive.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 64),
      child: Column(
        children: [
          Semantics(
            header: true,
            child: SelectableText(
              l10n.aboutMe,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                fontSize: isMobile ? 28 : null,
              ),
              textAlign: isMobile ? TextAlign.center : null,
              semanticsLabel: 'Section heading: ${l10n.aboutMe}',
            ),
          ),
          const SizedBox(height: 32),
          _MarkdownText(
            text: l10n.aboutMeDescription,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: isMobile ? 16 : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkdownText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const _MarkdownText({required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    final markdownRegex = RegExp(r'\[([^\]]+)\]\(([^)]+)\)|\*([^*\n]+)\*');
    final matches = markdownRegex.allMatches(text);

    if (matches.isEmpty) {
      return SelectableText(text, style: style, textAlign: TextAlign.center);
    }

    final spans = <TextSpan>[];
    var currentIndex = 0;

    for (final match in matches) {
      if (match.start > currentIndex) {
        spans.add(
          TextSpan(
            text: text.substring(currentIndex, match.start),
            style: style,
          ),
        );
      }

      final linkText = match.group(1);
      if (linkText != null) {
        final isItalicLink =
            linkText.length > 2 &&
            linkText.startsWith('*') &&
            linkText.endsWith('*');
        final displayText =
            isItalicLink
                ? linkText.substring(1, linkText.length - 1)
                : linkText;
        final linkStyle = (style ?? const TextStyle()).copyWith(
          color: Theme.of(context).colorScheme.primary,
          decoration: TextDecoration.underline,
          fontStyle: isItalicLink ? FontStyle.italic : null,
        );

        spans.add(
          TextSpan(
            text: displayText,
            style: linkStyle,
            recognizer:
                TapGestureRecognizer()
                  ..onTap = () => _launchUrl(match.group(2)!),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: match.group(3)!,
            style: (style ?? const TextStyle()).copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      }

      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex), style: style));
    }

    return SelectableText.rich(
      TextSpan(children: spans),
      textAlign: TextAlign.center,
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
