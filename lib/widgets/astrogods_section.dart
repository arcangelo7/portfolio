import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
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

  Widget _buildStrikethroughText(String text, TextStyle? style, TextAlign textAlign) {
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
    final isMobile = MediaQuery.of(context).size.width < 768;
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
        child: Container(
          padding: EdgeInsets.all(isMobile ? 20 : 64),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
            // Titolo principale
            Semantics(
              header: true,
              child: _buildStrikethroughText(
                l10n.astroGodsTitle,
                Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
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
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: SelectableText(
                l10n.astroGodsIntroduction,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: PortfolioTheme.astroLightGray,
                  fontSize: isMobile ? 16 : 18,
                  height: 1.6,
                ),
                textAlign: TextAlign.justify,
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
    );
  }

  Widget _buildExplanationCards(
    BuildContext context,
    AppLocalizations l10n,
    bool isMobile,
  ) {
    final cards = [
      {
        'icon': Icons.psychology_alt,
        'title': l10n.astroGodsCard1Title,
        'description': l10n.astroGodsCard1Description,
        'color': PortfolioTheme.astroProblemRed, // Rosso per il problema
      },
      {
        'icon': Icons.scatter_plot,
        'title': l10n.astroGodsCard2Title,
        'description': l10n.astroGodsCard2Description,
        'color': PortfolioTheme.astroElementViolet, // Viola per gli elementi
      },
      {
        'icon': Icons.trending_up,
        'title': l10n.astroGodsCard3Title,
        'description': l10n.astroGodsCard3Description,
        'color':
            PortfolioTheme
                .astroComplexityOrange, // Arancione per la complessità
      },
      {
        'icon': Icons.temple_hindu,
        'title': l10n.astroGodsCard4Title,
        'description': l10n.astroGodsCard4Description,
        'color': PortfolioTheme.astroTraditionBlue, // Blu per la tradizione
      },
      {
        'icon': Icons.smart_toy,
        'title': l10n.astroGodsCard5Title,
        'description': l10n.astroGodsCard5Description,
        'color': PortfolioTheme.astroAiGreen, // Verde per l'AI
      },
      {
        'icon': Icons.lightbulb,
        'title': l10n.astroGodsCard6Title,
        'description': l10n.astroGodsCard6Description,
        'color': PortfolioTheme.astroGold, // Oro per l'obiettivo
      },
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children:
          cards.map((card) {
            final cardColor = card['color'] as Color;

            return Container(
              width: isMobile ? double.infinity : 400,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cardColor.withValues(alpha: 0.15),
                    cardColor.withValues(alpha: 0.05),
                    Colors.white.withValues(alpha: 0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: cardColor.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: cardColor.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cardColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          card['icon'] as IconData,
                          color: cardColor,
                          size: isMobile ? 24 : 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SelectableText(
                          card['title'] as String,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: cardColor,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 16 : 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    card['description'] as String,
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
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _launchUrl('https://astrogods.it/'),
        icon: const Icon(Icons.language),
        label: Text(l10n.astroGodsVisitWebsite),
        style: ElevatedButton.styleFrom(
          backgroundColor: PortfolioTheme.astroGold,
          foregroundColor: PortfolioTheme.astroMysticBlue,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 24,
            vertical: isMobile ? 12 : 16,
          ),
          elevation: 8,
          shadowColor: PortfolioTheme.astroGold.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
