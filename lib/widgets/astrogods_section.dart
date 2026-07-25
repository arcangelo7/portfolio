// SPDX-FileCopyrightText: 2025-2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../theme/design_tokens.dart';
import '../theme/portfolio_theme.dart';
import '../utils/responsive.dart';
import 'section_shell.dart';
import 'starry_background.dart';

class AstroGodsSection extends StatefulWidget {
  const AstroGodsSection({super.key});

  @override
  State<AstroGodsSection> createState() => _AstroGodsSectionState();
}

class _AstroGodsSectionState extends State<AstroGodsSection> {
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildStrikethroughText(
    String text,
    TextStyle? style,
    TextAlign textAlign,
  ) {
    final strikethroughRegex = RegExp(r'~~([^~]+)~~');
    final match = strikethroughRegex.firstMatch(text);

    if (match == null) {
      return SelectableText(text, style: style, textAlign: textAlign);
    }

    final beforeText = text.substring(0, match.start);
    final strikethroughText = match.group(1)!;
    final afterText = text.substring(match.end);

    return SelectableText.rich(
      TextSpan(
        style: style,
        children: [
          if (beforeText.isNotEmpty) TextSpan(text: beforeText),
          TextSpan(
            text: strikethroughText,
            style: style?.copyWith(
              decoration: TextDecoration.lineThrough,
              decorationColor: PortfolioTheme.astroGold,
              decorationThickness: 3.0,
              color: PortfolioTheme.astroGold.withValues(alpha: 0.6),
            ),
          ),
          if (afterText.isNotEmpty) TextSpan(text: afterText),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isMobile = Responsive.isMobile(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: StarryBackground(
        showHorizon: true,
        forceNightBackground: true, // Sempre sfondo notturno per AstroGods
        // Configurazione personalizzata per AstroGods
        starCount1: isDark ? 500 : 400,
        starCount2: isDark ? 150 : 120,
        starCount3: isDark ? 80 : 60,
        starSize1: isDark ? 1.2 : 1.0,
        starSize2: isDark ? 2.5 : 2.0,
        starSize3: isDark ? 4.0 : 3.0,
        starColor: isDark ? PortfolioTheme.astroGold : Colors.white,
        animationSpeed1: isDark ? 60 : 45,
        animationSpeed2: isDark ? 120 : 90,
        animationSpeed3: isDark ? 180 : 135,
        // The star field stays full bleed because it is the atmosphere, but the
        // content sits in the same column as every other section.
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.pageInset(context),
            vertical: Responsive.sectionInset(context),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: Layout.content),
              child: Column(
                children: [
                  SvgPicture.asset(
                    'assets/images/astrogods_logo.svg',
                    height: isMobile ? 100 : 150,
                  ),
                  const SizedBox(height: 24),
                  // Titolo principale
                  Semantics(
                    header: true,
                    child: _buildStrikethroughText(
                      l10n.astroGodsTitle,
                      Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: PortfolioTheme.astroGold,
                        fontSize: isMobile ? 28 : null,
                        shadows: [
                          Shadow(
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                            color: Colors.black.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                      TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sottotitolo ironico
                  SelectableText(
                    l10n.astroGodsSubtitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: PortfolioTheme.astroLightGray,
                      fontStyle: FontStyle.italic,
                      fontSize: isMobile ? 18 : null,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Introduzione
                  ProseBlock(
                    centered: true,
                    child: SelectableText(
                      l10n.astroGodsIntroduction,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: PortfolioTheme.astroLightGray,
                        fontSize: isMobile ? 16 : 18,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Carte di spiegazione
                  _buildExplanationCards(context, l10n, isMobile),

                  const SizedBox(height: 32),

                  // Pulsante di azione
                  _buildActionButtons(context, l10n, isMobile),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExplanationCards(
    BuildContext context,
    AppLocalizations l10n,
    bool isMobile,
  ) {
    final cards = [
      (
        icon: Icons.psychology_alt,
        title: l10n.astroGodsCard1Title,
        description: l10n.astroGodsCard1Description,
        color: PortfolioTheme.emberNight,
      ),
      (
        icon: Icons.scatter_plot,
        title: l10n.astroGodsCard2Title,
        description: l10n.astroGodsCard2Description,
        color: PortfolioTheme.violetNight,
      ),
      (
        icon: Icons.trending_up,
        title: l10n.astroGodsCard3Title,
        description: l10n.astroGodsCard3Description,
        color: PortfolioTheme.amberNight,
      ),
      (
        icon: Icons.temple_hindu,
        title: l10n.astroGodsCard4Title,
        description: l10n.astroGodsCard4Description,
        color: PortfolioTheme.lightCobaltBlue,
      ),
      (
        icon: Icons.smart_toy,
        title: l10n.astroGodsCard5Title,
        description: l10n.astroGodsCard5Description,
        color: PortfolioTheme.emeraldNight,
      ),
      (
        icon: Icons.lightbulb,
        title: l10n.astroGodsCard6Title,
        description: l10n.astroGodsCard6Description,
        color: PortfolioTheme.astroGold,
      ),
    ];

    return SectionGrid(
      desktopColumns: 3,
      children: cards.map((card) {
        return Container(
          padding: const EdgeInsets.all(Space.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                card.color.withValues(alpha: 0.15),
                card.color.withValues(alpha: 0.05),
                Colors.white.withValues(alpha: 0.02),
              ],
            ),
            borderRadius: Radii.card,
            border: Border.all(color: card.color.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(Space.sm),
                    decoration: BoxDecoration(
                      color: card.color.withValues(alpha: 0.2),
                      borderRadius: Radii.card,
                    ),
                    child: Icon(
                      card.icon,
                      color: card.color,
                      size: isMobile ? 24 : 28,
                    ),
                  ),
                  const SizedBox(width: Space.md),
                  Expanded(
                    child: SelectableText(
                      card.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: card.color,
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 16 : 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.md),
              SelectableText(
                card.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: PortfolioTheme.astroLightGray,
                  fontSize: isMobile ? 14 : 15,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AppLocalizations l10n,
    bool isMobile,
  ) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: PortfolioTheme.astroGold,
      foregroundColor: PortfolioTheme.astroMysticBlue,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 20,
        vertical: isMobile ? 12 : 16,
      ),
      elevation: 8,
      shadowColor: PortfolioTheme.astroGold.withValues(alpha: 0.5),
    );

    const iconSize = 20.0;
    final iconColor = ColorFilter.mode(
      PortfolioTheme.astroMysticBlue,
      BlendMode.srcIn,
    );

    return Center(
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () => _launchUrl('https://astrogods.it/'),
            icon: const Icon(Icons.language),
            label: Text(l10n.astroGodsVisitWebsite),
            style: buttonStyle,
          ),
          ElevatedButton.icon(
            onPressed: () =>
                _launchUrl('https://flathub.org/apps/it.astrogods.AstroGods'),
            icon: SvgPicture.asset(
              'assets/icons/flathub.svg',
              width: iconSize,
              height: iconSize,
              colorFilter: iconColor,
            ),
            label: Text(l10n.astroGodsGetOnFlathub),
            style: buttonStyle,
          ),
          ElevatedButton.icon(
            onPressed: () => _launchUrl('https://snapcraft.io/astrogods'),
            icon: SvgPicture.asset(
              'assets/icons/snapcraft.svg',
              width: iconSize,
              height: iconSize,
              colorFilter: iconColor,
            ),
            label: Text(l10n.astroGodsGetOnSnap),
            style: buttonStyle,
          ),
          ElevatedButton.icon(
            onPressed: () =>
                _launchUrl('https://apps.microsoft.com/detail/9mttm2qdm94v'),
            icon: SvgPicture.asset(
              'assets/icons/microsoft_store.svg',
              width: iconSize,
              height: iconSize,
              colorFilter: iconColor,
            ),
            label: Text(l10n.astroGodsGetOnMicrosoftStore),
            style: buttonStyle,
          ),
          ElevatedButton.icon(
            onPressed: () => _launchUrl(
              'https://play.google.com/store/apps/details?id=com.astrogods.app',
            ),
            icon: SvgPicture.asset(
              'assets/icons/google_play.svg',
              width: iconSize,
              height: iconSize,
              colorFilter: iconColor,
            ),
            label: Text(l10n.astroGodsGetOnGooglePlay),
            style: buttonStyle,
          ),
        ],
      ),
    );
  }
}
