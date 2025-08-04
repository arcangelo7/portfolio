import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';

class EducationSection extends StatelessWidget {
  const EducationSection({super.key});

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
          Text(
            l10n.education,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              fontSize: isMobile ? 28 : null,
            ),
          ),
          const SizedBox(height: 32),
          Column(
            children: [
              _buildEducationItem(
                context,
                l10n.phdCulturalHeritageTitle,
                l10n.universityBologna,
                l10n.phdCulturalHeritagePeriod,
                l10n.phdCulturalHeritageDescription,
                true,
                isMobile,
              ),
              const SizedBox(height: 24),
              _buildEducationItem(
                context,
                l10n.phdEngineeringTitle,
                l10n.kuLeuven,
                l10n.phdEngineeringPeriod,
                l10n.phdEngineeringDescription,
                true,
                isMobile,
              ),
              const SizedBox(height: 24),
              _buildEducationItem(
                context,
                l10n.unaEuropaPhdTitle,
                l10n.unaEuropa,
                l10n.unaEuropaPhdPeriod,
                l10n.unaEuropaPhdDescription,
                true,
                isMobile,
              ),
              const SizedBox(height: 24),
              _buildEducationItem(
                context,
                l10n.mastersDegreeTitle,
                l10n.universityBologna,
                l10n.mastersPeriod,
                l10n.mastersDescription,
                false,
                isMobile,
              ),
              const SizedBox(height: 24),
              _buildEducationItem(
                context,
                l10n.bachelorsDegreeTitle,
                l10n.universityBologna,
                l10n.bachelorsPeriod,
                l10n.bachelorsDescription,
                false,
                isMobile,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEducationItem(
    BuildContext context,
    String degree,
    String institution,
    String period,
    String description,
    bool isOngoing,
    bool isMobile,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(
          color: isOngoing
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          width: isOngoing ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isOngoing
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary)
                .withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
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
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      degree,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isOngoing
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                        fontSize: isMobile ? 16 : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      institution,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                        fontSize: isMobile ? 14 : null,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (isOngoing
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.tertiary)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (isOngoing
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.tertiary)
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  period,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isOngoing
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 11 : null,
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
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.5,
              fontSize: isMobile ? 13 : null,
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