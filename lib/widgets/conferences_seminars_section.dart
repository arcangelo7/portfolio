import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../services/cv_data_service.dart';
import '../models/cv_data.dart';

class ConferencesSeminarsSection extends StatelessWidget {
  const ConferencesSeminarsSection({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _getLocalizedText(AppLocalizations l10n, String key) {
    switch (key) {
      case 'unaEuropaWorkshop2025Title':
        return l10n.unaEuropaWorkshop2025Title;
      case 'unaEuropaWorkshop2025Period':
        return l10n.unaEuropaWorkshop2025Period;
      case 'unaEuropaWorkshop2025Location':
        return l10n.unaEuropaWorkshop2025Location;
      case 'unaEuropaWorkshop2025Description':
        return l10n.unaEuropaWorkshop2025Description;
      case 'aiucdConference2024Title':
        return l10n.aiucdConference2024Title;
      case 'aiucdConference2024Period':
        return l10n.aiucdConference2024Period;
      case 'aiucdConference2024Location':
        return l10n.aiucdConference2024Location;
      case 'aiucdConference2024Description':
        return l10n.aiucdConference2024Description;
      case 'cziHackathon2023Title':
        return l10n.cziHackathon2023Title;
      case 'cziHackathon2023Period':
        return l10n.cziHackathon2023Period;
      case 'cziHackathon2023Location':
        return l10n.cziHackathon2023Location;
      case 'cziHackathon2023Description':
        return l10n.cziHackathon2023Description;
      case 'adhoDhConf2023Title':
        return l10n.adhoDhConf2023Title;
      case 'adhoDhConf2023Period':
        return l10n.adhoDhConf2023Period;
      case 'adhoDhConf2023Location':
        return l10n.adhoDhConf2023Location;
      case 'adhoDhConf2023Description':
        return l10n.adhoDhConf2023Description;
      case 'rdaPlenary2023Title':
        return l10n.rdaPlenary2023Title;
      case 'rdaPlenary2023Period':
        return l10n.rdaPlenary2023Period;
      case 'rdaPlenary2023Location':
        return l10n.rdaPlenary2023Location;
      case 'rdaPlenary2023Description':
        return l10n.rdaPlenary2023Description;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 64),
      child: Column(
        children: [
          Text(
            l10n.conferencesAndSeminars,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              fontSize: isMobile ? 28 : null,
            ),
          ),
          const SizedBox(height: 32),
          FutureBuilder<List<ConferenceEntry>>(
            future: CVDataService.getConferences(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              final conferenceEntries = snapshot.data ?? [];

              return Column(
                children: conferenceEntries.map((entry) {
                  return Column(
                    children: [
                      _buildConferenceItem(
                        context,
                        l10n,
                        entry,
                        isMobile,
                      ),
                      if (entry != conferenceEntries.last) const SizedBox(height: 32),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConferenceItem(
    BuildContext context,
    AppLocalizations l10n,
    ConferenceEntry entry,
    bool isMobile,
  ) {
    final title = _getLocalizedText(l10n, entry.titleKey);
    final location = _getLocalizedText(l10n, entry.locationKey);
    final period = _getLocalizedText(l10n, entry.periodKey);
    final description = _getLocalizedText(l10n, entry.descriptionKey);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: isMobile ? 18 : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                        fontSize: isMobile ? 16 : null,
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
                  color: Theme.of(
                    context,
                  ).colorScheme.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.tertiary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  period,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 12 : null,
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
              color: Theme.of(context).colorScheme.onSurface,
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
    final markdownRegex = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');
    final matches = markdownRegex.allMatches(text);

    if (matches.isEmpty) {
      return Text(text, style: style);
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

      final linkText = match.group(1)!;
      final linkUrl = match.group(2)!;
      spans.add(
        TextSpan(
          text: linkText,
          style: style?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()..onTap = () => _launchUrl(linkUrl),
        ),
      );

      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex), style: style));
    }

    return RichText(text: TextSpan(children: spans));
  }
}
