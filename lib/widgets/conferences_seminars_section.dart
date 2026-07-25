// SPDX-FileCopyrightText: 2025 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/localization_helper.dart';
import '../models/cv_data.dart';
import '../services/cv_data_service.dart';
import '../theme/design_tokens.dart';
import 'entry_card.dart';
import 'section_shell.dart';

class ConferencesSeminarsSection extends StatefulWidget {
  final List<ConferenceEntry>? entries;

  const ConferencesSeminarsSection({super.key, this.entries});

  @override
  State<ConferencesSeminarsSection> createState() =>
      _ConferencesSeminarsSectionState();
}

class _ConferencesSeminarsSectionState
    extends State<ConferencesSeminarsSection> {
  List<ConferenceEntry>? _conferenceEntries;
  late bool _isLoading;
  String? _error;

  @override
  void initState() {
    super.initState();
    _conferenceEntries = widget.entries;
    _isLoading = widget.entries == null;
    if (_isLoading) {
      _loadConferences();
    }
  }

  @override
  void didUpdateWidget(ConferencesSeminarsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entries != null && oldWidget.entries != widget.entries) {
      _conferenceEntries = widget.entries;
      _isLoading = false;
      _error = null;
    }
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SectionShell(
      title: l10n.conferencesAndSeminars,
      child: _buildContent(l10n),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return SelectableText(l10n.sectionLoadError(_error!));
    }

    final entries = _conferenceEntries!;

    return Column(
      children: [
        for (var i = 0; i < entries.length; i++)
          Padding(
            padding: EdgeInsets.only(
              bottom: i == entries.length - 1 ? 0 : Space.xl,
            ),
            child: EntryCard(
              title: LocalizationHelper.getLocalizedText(
                l10n,
                entries[i].titleKey,
              ),
              subtitle: LocalizationHelper.getLocalizedText(
                l10n,
                entries[i].locationKey,
              ),
              period: LocalizationHelper.getLocalizedText(
                l10n,
                entries[i].periodKey,
              ),
              description: LocalizationHelper.getLocalizedText(
                l10n,
                entries[i].descriptionKey,
              ),
              isCurrent: false,
            ),
          ),
      ],
    );
  }
}
