import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';

// Importazioni condizionali per Flutter web
import 'dart:ui_web' as ui;
import 'dart:html' as html;

/// Sezione dedicata ad AstroGods - la sezione "Contro la Scienza"
/// Un app che utilizza l'astrologia egizia combinata con l'intelligenza artificiale
class AstroGodsSection extends StatelessWidget {
  final bool isLanguageModalOpen;

  const AstroGodsSection({super.key, this.isLanguageModalOpen = false});

  static bool _iframeRegistered = false;

  static void _registerIframe() {
    if (!_iframeRegistered) {
      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory('iframe-astrogods', (
        int viewId,
      ) {
        // ignore: undefined_prefixed_name
        final iframe =
            html.IFrameElement()
              ..src = 'https://astrogods.it/'
              ..style.border = 'none'
              ..style.height = '100%'
              ..style.width = '100%';
        return iframe;
      });
      _iframeRegistered = true;
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
    _registerIframe();

    final l10n = AppLocalizations.of(context)!;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A2E), // Blu scuro mistico
            const Color(0xFF16213E), // Viola scuro
            const Color(0xFF0F3460), // Blu profondo
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 20 : 64),
        child: Column(
          children: [
            // Icona e titolo principale
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome_mosaic,
                  size: isMobile ? 32 : 48,
                  color: const Color(0xFFFFD700), // Oro per i simboli esoterici
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    l10n.astroGodsTitle,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFD700),
                      fontSize: isMobile ? 28 : null,
                      shadows: [
                        Shadow(
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.psychology_alt,
                  size: isMobile ? 32 : 48,
                  color: const Color(0xFFFFD700),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Sottotitolo ironico
            Text(
              l10n.astroGodsSubtitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFFE0E0E0),
                fontStyle: FontStyle.italic,
                fontSize: isMobile ? 18 : null,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Carte di spiegazione
            _buildExplanationCards(context, l10n, isMobile),

            const SizedBox(height: 32),

            // Preview del sito web
            _buildWebsitePreview(context, l10n, isMobile),

            const SizedBox(height: 32),

            // Pulsanti di azione
            _buildActionButtons(context, l10n, isMobile),
          ],
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
        'color': const Color(0xFFE74C3C), // Rosso per il problema
      },
      {
        'icon': Icons.scatter_plot,
        'title': l10n.astroGodsCard2Title,
        'description': l10n.astroGodsCard2Description,
        'color': const Color(0xFF9B59B6), // Viola per gli elementi
      },
      {
        'icon': Icons.trending_up,
        'title': l10n.astroGodsCard3Title,
        'description': l10n.astroGodsCard3Description,
        'color': const Color(0xFFE67E22), // Arancione per la complessità
      },
      {
        'icon': Icons.temple_hindu,
        'title': l10n.astroGodsCard4Title,
        'description': l10n.astroGodsCard4Description,
        'color': const Color(0xFF3498DB), // Blu per la tradizione
      },
      {
        'icon': Icons.smart_toy,
        'title': l10n.astroGodsCard5Title,
        'description': l10n.astroGodsCard5Description,
        'color': const Color(0xFF2ECC71), // Verde per l'AI
      },
      {
        'icon': Icons.lightbulb,
        'title': l10n.astroGodsCard6Title,
        'description': l10n.astroGodsCard6Description,
        'color': const Color(0xFFFFD700), // Oro per l'obiettivo
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
                        child: Text(
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
                  Text(
                    card['description'] as String,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFE0E0E0),
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

  Widget _buildWebsitePreview(
    BuildContext context,
    AppLocalizations l10n,
    bool isMobile,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Preview AstroGods',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: isMobile ? 300 : 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  isMobile || isLanguageModalOpen
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.language,
                              color: const Color(0xFFFFD700),
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isLanguageModalOpen
                                  ? l10n.astroGodsIframeHidden
                                  : l10n.astroGodsVisitForFullExperience,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: const Color(0xFFE0E0E0)),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                      : const HtmlElementView(viewType: 'iframe-astrogods'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AppLocalizations l10n,
    bool isMobile,
  ) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        ElevatedButton.icon(
          onPressed: () => _launchUrl('https://astrogods.it/'),
          icon: const Icon(Icons.language),
          label: Text(l10n.astroGodsVisitWebsite),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: const Color(0xFF1A1A2E),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 24,
              vertical: isMobile ? 12 : 16,
            ),
            elevation: 8,
            shadowColor: const Color(0xFFFFD700).withValues(alpha: 0.5),
          ),
        ),
        OutlinedButton.icon(
          onPressed:
              () => _launchUrl(
                'mailto:arcangelo.massari@studio.unibo.it?subject=AstroGods%20Collaboration',
              ),
          icon: const Icon(Icons.contact_mail),
          label: Text(l10n.astroGodsCollaborate),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFFFD700),
            side: const BorderSide(color: Color(0xFFFFD700), width: 2),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 24,
              vertical: isMobile ? 12 : 16,
            ),
          ),
        ),
      ],
    );
  }
}
