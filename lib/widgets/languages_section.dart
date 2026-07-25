// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../l10n/localization_helper.dart';
import '../models/language_data.dart';
import '../services/cv_data_service.dart';
import '../theme/design_tokens.dart';
import '../utils/responsive.dart';
import 'entry_card.dart';
import 'section_shell.dart';

class LanguagesSection extends StatefulWidget {
  final LanguageData? data;

  const LanguagesSection({super.key, this.data});

  @override
  State<LanguagesSection> createState() => _LanguagesSectionState();
}

class _LanguagesSectionState extends State<LanguagesSection> {
  LanguageData? _languageData;
  late bool _isLoading;
  String? _error;

  @override
  void initState() {
    super.initState();
    _languageData = widget.data;
    _isLoading = widget.data == null;
    if (_isLoading) {
      _loadLanguages();
    }
  }

  @override
  void didUpdateWidget(LanguagesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != null && oldWidget.data != widget.data) {
      _languageData = widget.data;
      _isLoading = false;
      _error = null;
    }
  }

  Future<void> _loadLanguages() async {
    try {
      final data = await CVDataService.getLanguages();
      if (mounted) {
        setState(() {
          _languageData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SectionShell(title: l10n.languages, child: _buildContent(l10n));
  }

  Widget _buildContent(AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Text(l10n.errorLoadingLanguages(_error!));
    }

    if (_languageData == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LanguageCard(
          label: l10n.languagesMotherTongue,
          name: LocalizationHelper.getLocalizedText(
            l10n,
            _languageData!.motherTongue.name,
          ),
        ),
        for (final lang in _languageData!.otherLanguages) ...[
          const SizedBox(height: Space.md),
          _LanguageCard(
            name: LocalizationHelper.getLocalizedText(l10n, lang.name),
            levels: [
              (l10n.languagesListening, lang.listening),
              (l10n.languagesReading, lang.reading),
              (l10n.languagesSpokenInteraction, lang.spokenInteraction),
              (l10n.languagesSpokenProduction, lang.spokenProduction),
              (l10n.languagesWriting, lang.writing),
            ],
            footnote: l10n.languagesCefrReference,
            certificate: l10n.languageCertificateDate(lang.certificateDate),
            badgeUrl: lang.badgeUrl,
            badgeLabel: l10n.verifyCredential,
          ),
        ],
      ],
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String? label;
  final String name;
  final List<(String, String)> levels;
  final String? footnote;
  final String? certificate;
  final String? badgeUrl;
  final String? badgeLabel;

  const _LanguageCard({
    required this.name,
    this.label,
    this.levels = const [],
    this.footnote,
    this.certificate,
    this.badgeUrl,
    this.badgeLabel,
  });

  Future<void> _launchBadge() async {
    final uri = Uri.parse(badgeUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(EntryCard.padding(Responsive.isMobile(context))),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: Radii.card,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            SelectableText(
              label!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Space.xxs),
          ],
          SelectableText(
            name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          if (levels.isNotEmpty) ...[
            const SizedBox(height: Space.md),
            Wrap(
              spacing: Space.xs,
              runSpacing: Space.xs,
              children: [
                for (final level in levels)
                  _CefrChip(label: level.$1, level: level.$2),
              ],
            ),
          ],
          if (footnote != null) ...[
            const SizedBox(height: Space.xs),
            SelectableText(
              footnote!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (certificate != null) ...[
            const SizedBox(height: Space.xs),
            SelectableText(
              certificate!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (badgeUrl != null) ...[
            const SizedBox(height: Space.xs),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _launchBadge,
                icon: const Icon(Icons.verified_outlined, size: 18),
                label: Text(badgeLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CefrChip extends StatelessWidget {
  final String label;
  final String level;

  const _CefrChip({required this.label, required this.level});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.sm,
        vertical: Space.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: Radii.pill,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Space.xxs),
          SelectableText(
            level,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
