// SPDX-FileCopyrightText: 2025 Arcangelo Massari <info@arcangelomassari.com>
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

class WorkExperienceSection extends StatefulWidget {
  final List<WorkExperienceEntry>? entries;

  const WorkExperienceSection({super.key, this.entries});

  @override
  State<WorkExperienceSection> createState() => _WorkExperienceSectionState();
}

class _WorkExperienceSectionState extends State<WorkExperienceSection> {
  List<WorkExperienceEntry>? _workEntries;
  late bool _isLoading;
  String? _error;

  @override
  void initState() {
    super.initState();
    _workEntries = widget.entries;
    _isLoading = widget.entries == null;
    if (_isLoading) {
      _loadWorkExperience();
    }
  }

  @override
  void didUpdateWidget(WorkExperienceSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entries != null && oldWidget.entries != widget.entries) {
      _workEntries = widget.entries;
      _isLoading = false;
      _error = null;
    }
  }

  Future<void> _loadWorkExperience() async {
    try {
      final workEntries = await CVDataService.getWorkExperience();
      if (mounted) {
        setState(() {
          _workEntries = workEntries;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _workEntries = null;
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SectionShell(title: l10n.workExperience, child: _buildContent(l10n));
  }

  Widget _buildContent(AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return SelectableText(l10n.sectionLoadError(_error!));
    }

    final entries = _workEntries!;
    final isMobile = Responsive.isMobile(context);

    return Column(
      children: [
        for (var i = 0; i < entries.length; i++)
          TimelineItem(
            isFirst: i == 0,
            isLast: i == entries.length - 1,
            isCurrent: entries[i].current,
            isMobile: isMobile,
            spacing: Space.xl,
            nodeCenter: EntryCard.nodeCenter(context, isMobile),
            child: EntryCard(
              title: LocalizationHelper.getLocalizedText(
                l10n,
                entries[i].titleKey,
              ),
              subtitle: LocalizationHelper.getLocalizedText(
                l10n,
                entries[i].companyKey,
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
