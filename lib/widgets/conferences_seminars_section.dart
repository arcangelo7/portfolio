// SPDX-FileCopyrightText: 2025 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../l10n/localization_helper.dart';
import '../services/cv_data_service.dart';
import '../models/cv_data.dart';
import '../utils/responsive.dart';

class ConferencesSeminarsSection extends StatefulWidget {
  const ConferencesSeminarsSection({super.key});

  @override
  State<ConferencesSeminarsSection> createState() =>
      _ConferencesSeminarsSectionState();
}

class _ConferencesSeminarsSectionState
    extends State<ConferencesSeminarsSection> {
  List<ConferenceEntry>? _conferenceEntries;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConferences();
  }

  Future<void> _loadConferences() async {
    try {
      final conferenceEntries = await CVDataService.getConferences();
      if (mounted) {
        setState(() {
          _conferenceEntries = conferenceEntries;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _conferenceEntries = null;
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 64),
      child: Column(
        children: [
          Semantics(
            header: true,
            child: SelectableText(
              l10n.conferencesAndSeminars,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                fontSize: isMobile ? 28 : null,
              ),
              semanticsLabel: 'Section heading: ${l10n.conferencesAndSeminars}',
            ),
          ),
          const SizedBox(height: 32),
          _buildConferencesContent(l10n, isMobile),
        ],
      ),
    );
  }

  Widget _buildConferencesContent(AppLocalizations l10n, bool isMobile) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return SelectableText(l10n.sectionLoadError(_error!));
    }

    final conferenceEntries = _conferenceEntries ?? [];

    return Column(
      children:
          conferenceEntries.map((entry) {
            return Column(
              children: [
                _buildConferenceItem(context, l10n, entry, isMobile),
                if (entry != conferenceEntries.last) const SizedBox(height: 32),
              ],
            );
          }).toList(),
    );
  }

  Widget _buildConferenceItem(
    BuildContext context,
    AppLocalizations l10n,
    ConferenceEntry entry,
    bool isMobile,
  ) {
    final title = LocalizationHelper.getLocalizedText(l10n, entry.titleKey);
    final location = LocalizationHelper.getLocalizedText(
      l10n,
      entry.locationKey,
    );
    final period = LocalizationHelper.getLocalizedText(l10n, entry.periodKey);
    final description = LocalizationHelper.getLocalizedText(
      l10n,
      entry.descriptionKey,
    );
    final colorScheme = Theme.of(context).colorScheme;
    final neutralBorderColor = colorScheme.onSurface.withValues(alpha: 0.12);
    final neutralBackgroundColor = colorScheme.onSurface.withValues(
      alpha: 0.06,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: neutralBorderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobile
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    location,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: neutralBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: neutralBorderColor),
                      ),
                      child: SelectableText(
                        period,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              )
              : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          title,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          location,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: neutralBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: neutralBorderColor),
                    ),
                    child: SelectableText(
                      period,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
          const SizedBox(height: 16),
          _buildTextWithMarkdownLinks(
            context,
            description,
            Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              height: 1.5,
              fontSize: isMobile ? 14 : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextWithMarkdownLinks(
    BuildContext context,
    String text,
    TextStyle? style,
  ) {
    final markdownRegex = RegExp(r'\[([^\]]+)\]\(([^)]+)\)|\*([^*\n]+)\*');
    final matches = markdownRegex.allMatches(text);

    if (matches.isEmpty) {
      return SelectableText(text, style: style);
    }

    List<TextSpan> spans = [];
    int currentIndex = 0;

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
        final linkStyle =
            style == null
                ? TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                  fontStyle: isItalicLink ? FontStyle.italic : null,
                )
                : style.copyWith(
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
        final italicStyle =
            style == null
                ? const TextStyle(fontStyle: FontStyle.italic)
                : style.copyWith(fontStyle: FontStyle.italic);

        spans.add(TextSpan(text: match.group(3)!, style: italicStyle));
      }

      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex), style: style));
    }

    return SelectableText.rich(TextSpan(children: spans));
  }
}
