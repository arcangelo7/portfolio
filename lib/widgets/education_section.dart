// SPDX-FileCopyrightText: 2025-2026 Arcangelo Massari <info@arcangelomassari.com>
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
import 'attachment_button.dart';

class EducationSection extends StatefulWidget {
  const EducationSection({super.key});

  @override
  State<EducationSection> createState() => _EducationSectionState();
}

class _EducationSectionState extends State<EducationSection> {
  List<EducationEntry>? _educationEntries;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEducation();
  }

  Future<void> _loadEducation() async {
    try {
      final educationEntries = await CVDataService.getEducation();
      if (mounted) {
        setState(() {
          _educationEntries = educationEntries;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _educationEntries = null;
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
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: EdgeInsets.all(isMobile ? 20 : 64),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Column(
        children: [
          Semantics(
            header: true,
            child: SelectableText(
              l10n.education,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                fontSize: isMobile ? 28 : null,
              ),
              semanticsLabel: 'Section heading: ${l10n.education}',
            ),
          ),
          const SizedBox(height: 32),
          _buildEducationContent(l10n, isMobile),
        ],
      ),
    );
  }

  Widget _buildEducationContent(AppLocalizations l10n, bool isMobile) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return SelectableText(l10n.sectionLoadError(_error!));
    }

    final educationEntries = _educationEntries ?? [];

    return Column(
      children:
          educationEntries.map((entry) {
            return Column(
              children: [
                _buildEducationItem(context, l10n, entry, isMobile),
                if (entry != educationEntries.last) const SizedBox(height: 24),
              ],
            );
          }).toList(),
    );
  }

  Widget _buildEducationItem(
    BuildContext context,
    AppLocalizations l10n,
    EducationEntry entry,
    bool isMobile,
  ) {
    final degree = LocalizationHelper.getLocalizedText(l10n, entry.titleKey);
    final institution = LocalizationHelper.getLocalizedText(
      l10n,
      entry.institutionKey,
    );
    final period = LocalizationHelper.getLocalizedText(l10n, entry.periodKey);
    final description = LocalizationHelper.getLocalizedText(
      l10n,
      entry.descriptionKey,
    );
    final isOngoing = entry.current;
    final colorScheme = Theme.of(context).colorScheme;
    final neutralBorderColor = colorScheme.onSurface.withValues(alpha: 0.12);
    final neutralBackgroundColor = colorScheme.onSurface.withValues(
      alpha: 0.06,
    );
    final currentBorderColor = colorScheme.primary.withValues(alpha: 0.3);
    final periodBackgroundColor =
        isOngoing
            ? colorScheme.primary.withValues(alpha: 0.1)
            : neutralBackgroundColor;
    final periodBorderColor =
        isOngoing ? currentBorderColor : neutralBorderColor;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOngoing ? currentBorderColor : neutralBorderColor,
          width: isOngoing ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isOngoing ? colorScheme.primary : colorScheme.onSurface)
                .withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isOngoing)
                        Container(
                          margin: const EdgeInsets.only(right: 8, top: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      Expanded(
                        child: SelectableText(
                          degree,
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                isOngoing
                                    ? colorScheme.primary
                                    : colorScheme.onSurface,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    institution,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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
                        color: periodBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: periodBorderColor),
                      ),
                      child: SelectableText(
                        period,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              isOngoing
                                  ? colorScheme.primary
                                  : colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              )
              : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isOngoing)
                    Container(
                      margin: const EdgeInsets.only(right: 8, top: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          degree,
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                isOngoing
                                    ? colorScheme.primary
                                    : colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          institution,
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
                      color: periodBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: periodBorderColor),
                    ),
                    child: SelectableText(
                      period,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            isOngoing
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
          const SizedBox(height: 12),
          _buildTextWithMarkdownLinks(
            context,
            description,
            Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              height: 1.5,
              fontSize: isMobile ? 13 : null,
            ),
          ),
          if (entry.attachments.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  entry.attachments
                      .map((a) => AttachmentButton(attachment: a))
                      .toList(),
            ),
          ],
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
