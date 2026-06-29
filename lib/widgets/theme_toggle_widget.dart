// SPDX-FileCopyrightText: 2025 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../main.dart';
import 'lazy_image.dart';

class ThemeToggleWidget extends StatelessWidget {
  final bool isDarkMode;
  final double size;

  const ThemeToggleWidget({
    super.key,
    required this.isDarkMode,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final label =
        isDarkMode
            ? (AppLocalizations.of(context)?.lightModeIconAlt ??
                'Switch to light mode')
            : (AppLocalizations.of(context)?.darkModeIconAlt ??
                'Switch to dark mode');

    return Semantics(
      image: true,
      label: label,
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: PortfolioTheme.iceWhite,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.88, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    child: child,
                  ),
                );
              },
              child: Transform.scale(
                key: ValueKey(isDarkMode),
                scale: 1.4,
                child:
                    isDarkMode
                        ? LazyImage(
                          assetPath: 'assets/images/light_mode.png',
                          width: size,
                          height: size,
                          fit: BoxFit.cover,
                          critical: true,
                          semanticLabel:
                              AppLocalizations.of(context)?.lightModeIconAlt,
                        )
                        : Transform.translate(
                          offset: Offset(size * 0.12, size * 0.05),
                          child: LazyImage(
                            assetPath: 'assets/images/dark_mode_button.png',
                            width: size,
                            height: size,
                            fit: BoxFit.cover,
                            critical: true,
                            semanticLabel:
                                AppLocalizations.of(context)?.darkModeIconAlt,
                          ),
                        ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
