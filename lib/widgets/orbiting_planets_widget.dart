// SPDX-FileCopyrightText: 2025 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../utils/responsive.dart';
import 'lazy_image.dart';

class ThemeElementsTransition extends StatelessWidget {
  final bool previousDarkMode;
  final bool finalDarkMode;
  final Animation<double> animation;
  final double elementSize;

  const ThemeElementsTransition({
    super.key,
    required this.previousDarkMode,
    required this.finalDarkMode,
    required this.animation,
    this.elementSize = 60.0,
  });

  Widget _buildPlanetElement(BuildContext context, bool isDarkMode) {
    return Container(
      key: ValueKey(isDarkMode ? 'theme-element-moon' : 'theme-element-sun'),
      width: elementSize,
      height: elementSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Semantics(
          image: true,
          label: AppLocalizations.of(context)?.orbitingPlanetAlt,
          child: ExcludeSemantics(
            excluding: true,
            child: LazyImage(
              assetPath: isDarkMode
                  ? 'assets/images/dark_mode.png'
                  : 'assets/images/light_mode.png',
              fit: BoxFit.cover,
              width: elementSize,
              height: elementSize,
              critical: true,
              semanticLabel: AppLocalizations.of(context)?.orbitingPlanetAlt,
            ),
          ),
        ),
      ),
    );
  }

  Widget _translatedPlanet({
    required bool isDarkMode,
    required Offset offset,
    required Widget child,
  }) {
    return Transform.translate(
      key: ValueKey(
        isDarkMode
            ? 'theme-element-moon-transform'
            : 'theme-element-sun-transform',
      ),
      offset: offset,
      child: child,
    );
  }

  double _lerp(double start, double end, double progress) {
    return start + (end - start) * progress;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = Responsive.sizeOf(context);
    final isMobile = Responsive.isMobile(context);

    final leftPosition = isMobile ? 20.0 : 40.0;
    final topPosition = isMobile ? 20.0 : 40.0;
    final outgoingPlanet = _buildPlanetElement(context, previousDarkMode);
    if (previousDarkMode == finalDarkMode) {
      return Stack(
        children: [
          Positioned(
            left: leftPosition,
            top: topPosition,
            child: _translatedPlanet(
              isDarkMode: finalDarkMode,
              offset: Offset.zero,
              child: outgoingPlanet,
            ),
          ),
        ],
      );
    }

    final incomingPlanet = _buildPlanetElement(context, finalDarkMode);
    final planetAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0, 650 / 800, curve: Curves.easeInOutCubic),
    );

    return ClipRect(
      child: Stack(
        children: [
          Positioned(
            left: leftPosition,
            top: topPosition,
            child: AnimatedBuilder(
              animation: planetAnimation,
              child: outgoingPlanet,
              builder: (context, child) {
                final progress = planetAnimation.value;
                final offset = Offset(
                  _lerp(
                    0,
                    screenSize.width + elementSize - leftPosition,
                    progress,
                  ),
                  _lerp(0, screenSize.height * 0.7 - topPosition, progress) -
                      screenSize.height * 0.12 * math.sin(progress * math.pi),
                );
                return _translatedPlanet(
                  isDarkMode: previousDarkMode,
                  offset: offset,
                  child: child!,
                );
              },
            ),
          ),
          Positioned(
            left: leftPosition,
            top: topPosition,
            child: AnimatedBuilder(
              animation: planetAnimation,
              child: incomingPlanet,
              builder: (context, child) {
                final progress = planetAnimation.value;
                final offset = Offset(
                  _lerp(-elementSize - leftPosition, 0, progress),
                  _lerp(screenSize.height * 0.24 - topPosition, 0, progress) -
                      screenSize.height * 0.06 * math.sin(progress * math.pi),
                );
                return _translatedPlanet(
                  isDarkMode: finalDarkMode,
                  offset: offset,
                  child: child!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
