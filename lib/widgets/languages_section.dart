// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../l10n/localization_helper.dart';
import '../models/language_data.dart';
import '../services/cv_data_service.dart';

class LanguagesSection extends StatefulWidget {
  const LanguagesSection({super.key});

  @override
  State<LanguagesSection> createState() => _LanguagesSectionState();
}

class _LanguagesSectionState extends State<LanguagesSection> {
  LanguageData? _languageData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLanguages();
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

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: EdgeInsets.all(isMobile ? 20 : 64),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Column(
        children: [
          Semantics(
            header: true,
            child: SelectableText(
              l10n.languages,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                fontSize: isMobile ? 28 : null,
              ),
              semanticsLabel: 'Section heading: ${l10n.languages}',
            ),
          ),
          const SizedBox(height: 32),
          _buildContent(context, l10n, isMobile),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    bool isMobile,
  ) {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }

    if (_error != null) {
      return Text('Error loading languages: $_error');
    }

    if (_languageData == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        _buildMotherTongue(context, l10n, isMobile),
        const SizedBox(height: 24),
        ..._languageData!.otherLanguages.map(
          (lang) => _buildOtherLanguage(context, l10n, lang, isMobile),
        ),
      ],
    );
  }

  Widget _buildMotherTongue(
    BuildContext context,
    AppLocalizations l10n,
    bool isMobile,
  ) {
    final languageName = LocalizationHelper.getLocalizedText(
      l10n,
      _languageData!.motherTongue.name,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.home,
            color: Theme.of(context).colorScheme.primary,
            size: isMobile ? 20 : 24,
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  l10n.languagesMotherTongue,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(
                      alpha: 0.6,
                    ),
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 11 : 12,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  languageName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: isMobile ? 16 : 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherLanguage(
    BuildContext context,
    AppLocalizations l10n,
    OtherLanguage lang,
    bool isMobile,
  ) {
    final languageName = LocalizationHelper.getLocalizedText(l10n, lang.name);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(
          color:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.translate,
                color: Theme.of(context).colorScheme.primary,
                size: isMobile ? 20 : 24,
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: SelectableText(
                  languageName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: isMobile ? 16 : 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCefrGrid(context, l10n, lang, isMobile),
          const SizedBox(height: 8),
          SelectableText(
            l10n.languagesCefrReference,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(
                alpha: 0.5,
              ),
              fontStyle: FontStyle.italic,
              fontSize: isMobile ? 10 : 11,
            ),
          ),
          if (lang.badgeUrl != null) ...[
            const SizedBox(height: 12),
            _buildBadgeButton(context, l10n, lang.badgeUrl!),
          ],
        ],
      ),
    );
  }

  Widget _buildCefrGrid(
    BuildContext context,
    AppLocalizations l10n,
    OtherLanguage lang,
    bool isMobile,
  ) {
    final skills = [
      (l10n.languagesListening, lang.listening),
      (l10n.languagesReading, lang.reading),
      (l10n.languagesSpokenInteraction, lang.spokenInteraction),
      (l10n.languagesSpokenProduction, lang.spokenProduction),
      (l10n.languagesWriting, lang.writing),
    ];

    return Wrap(
      spacing: isMobile ? 8 : 12,
      runSpacing: isMobile ? 8 : 12,
      children: skills.map((skill) {
        return _buildCefrChip(context, skill.$1, skill.$2, isMobile);
      }).toList(),
    );
  }

  Widget _buildCefrChip(
    BuildContext context,
    String label,
    String level,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
        border: Border.all(
          color:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SelectableText(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(
                alpha: 0.6,
              ),
              fontSize: isMobile ? 10 : 11,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            level,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              fontSize: isMobile ? 16 : 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeButton(
    BuildContext context,
    AppLocalizations l10n,
    String badgeUrl,
  ) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => _launchUrl(badgeUrl),
        icon: Icon(
          Icons.verified_outlined,
          size: 18,
          color: Theme.of(context).colorScheme.primary,
        ),
        label: Text(
          l10n.verifyCredential,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
