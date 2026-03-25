// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../models/cv_data.dart';

class AttachmentButton extends StatelessWidget {
  final EntryAttachment attachment;

  const AttachmentButton({super.key, required this.attachment});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final (IconData icon, String text) = switch (attachment.type) {
      'credential' => (Icons.verified_outlined, l10n.verifyCredential),
      'diplomaSupplement' => (Icons.description_outlined, l10n.diplomaSupplement),
      'completedExams' => (Icons.list_alt, l10n.completedExams),
      'announcement' => (Icons.campaign_outlined, l10n.announcement),
      _ => (Icons.link, attachment.type),
    };

    final label = attachment.label != null ? '$text ${attachment.label}' : text;
    final target = attachment.url ?? Uri.base.resolve(attachment.asset!).toString();

    return TextButton.icon(
      onPressed: () => _launchUrl(target),
      icon: Icon(
        icon,
        size: 18,
        color: Theme.of(context).colorScheme.primary,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
