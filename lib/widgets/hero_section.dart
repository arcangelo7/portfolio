// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../main.dart';
import '../utils/responsive.dart';
import 'lazy_image.dart';
import 'orbiting_planets_widget.dart';
import 'starry_background.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onViewWork;
  final bool enableThemeAnimation;

  const HeroSection({
    super.key,
    required this.onViewWork,
    required this.enableThemeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = Responsive.sizeOf(context);
    final screenWidth = screenSize.width;
    final isMobile = Responsive.isMobile(context);
    final l10n = AppLocalizations.of(context)!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      height: screenSize.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors:
              isDark
                  ? [PortfolioTheme.cobaltBlue, PortfolioTheme.astroMysticBlue]
                  : [PortfolioTheme.emeraldGreen, PortfolioTheme.astroGold],
        ),
      ),
      child: Stack(
        children: [
          if (isDark)
            const Positioned.fill(
              child: StarryBackground(
                showHorizon: false,
                child: SizedBox.expand(),
              ),
            ),
          StaticThemeElementsWidget(
            isDarkMode: isDark,
            elementSize: isMobile ? 120.0 : 180.0,
            enableAnimation: enableThemeAnimation,
          ),
          Positioned.fill(
            child: LazyImage(
              assetPath: 'assets/images/profile_cutout.webp',
              fit:
                  screenWidth / screenSize.height > 2.1
                      ? BoxFit.contain
                      : BoxFit.cover,
              alignment:
                  screenWidth / screenSize.height > 2.1
                      ? Alignment.bottomRight
                      : Alignment.center,
              semanticLabel: l10n.profileImageAlt,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.person,
                    size: 200,
                    color: PortfolioTheme.iceWhite,
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: isMobile ? 16 : 60,
            right: isMobile ? 16 : null,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: isMobile ? null : screenWidth * 0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment:
                    isMobile
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: SelectableText(
                      l10n.name,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: PortfolioTheme.iceWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 36 : 56,
                        shadows: [
                          Shadow(
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                            color: Colors.black.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                      textAlign: isMobile ? TextAlign.center : TextAlign.start,
                      semanticsLabel: 'Main heading: ${l10n.name}',
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: onViewWork,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PortfolioTheme.iceWhite,
                      foregroundColor: PortfolioTheme.cobaltBlue,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 30 : 40,
                        vertical: isMobile ? 16 : 20,
                      ),
                      elevation: 8,
                    ),
                    child: Text(
                      l10n.viewMyWork,
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
