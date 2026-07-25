// SPDX-FileCopyrightText: 2025-2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/localization_helper.dart';
import '../models/cv_data.dart';
import '../services/cv_data_service.dart';
import '../theme/design_tokens.dart';
import '../utils/responsive.dart';
import 'attachment_button.dart';
import 'entry_card.dart';
import 'section_shell.dart';
import 'timeline_item.dart';

class EducationSection extends StatefulWidget {
  final List<EducationEntry>? entries;

  const EducationSection({super.key, this.entries});

  @override
  State<EducationSection> createState() => _EducationSectionState();
}

class _EducationSectionState extends State<EducationSection> {
  List<EducationEntry>? _educationEntries;
  late bool _isLoading;
  String? _error;

  @override
  void initState() {
    super.initState();
    _educationEntries = widget.entries;
    _isLoading = widget.entries == null;
    if (_isLoading) {
      _loadEducation();
    }
  }

  @override
  void didUpdateWidget(EducationSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entries != null && oldWidget.entries != widget.entries) {
      _educationEntries = widget.entries;
      _isLoading = false;
      _error = null;
    }
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SectionShell(title: l10n.education, child: _buildContent(l10n));
  }

  Widget _buildContent(AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return SelectableText(l10n.sectionLoadError(_error!));
    }

    final entries = _educationEntries!;
    final isMobile = Responsive.isMobile(context);

    return Column(
      children: [
        for (var i = 0; i < entries.length; i++)
          TimelineItem(
            isFirst: i == 0,
            isLast: i == entries.length - 1,
            isCurrent: entries[i].current,
            isMobile: isMobile,
            spacing: Space.lg,
            nodeCenter: EntryCard.nodeCenter(context, isMobile),
            child: EntryCard(
              title: LocalizationHelper.getLocalizedText(
                l10n,
                entries[i].titleKey,
              ),
              subtitle: LocalizationHelper.getLocalizedText(
                l10n,
                entries[i].institutionKey,
              ),
              period: LocalizationHelper.getLocalizedText(
                l10n,
                entries[i].periodKey,
              ),
              description: LocalizationHelper.getLocalizedText(
                l10n,
                entries[i].descriptionKey,
              ),
              isCurrent: entries[i].current,
              attachments: entries[i].attachments
                  .map((a) => AttachmentButton(attachment: a))
                  .toList(),
            ),
          ),
      ],
    );
  }
}
