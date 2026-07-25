// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/responsive.dart';

/// The sun by day and the moon by night, crossing the page as you read.
///
/// Its position is reading progress: it rises out of the hero, culminates
/// mid-page and sets on the contact section. That is the one thing the design
/// spends boldness on, so it stays small, dim and behind the content.
class CelestialMarker extends StatelessWidget {
  final ValueListenable<double> progress;
  final bool isDarkMode;

  const CelestialMarker({
    super.key,
    required this.progress,
    required this.isDarkMode,
  });

  /// The hero already shows the sun full size, so the marker only appears once
  /// that composition has scrolled away.
  static const double _fadeInEnd = 0.14;
  static const double _peakOpacity = 0.5;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final markerSize = isMobile ? 40.0 : 56.0;
    final lift = isMobile ? 0.42 : 0.58;

    final marker = ExcludeSemantics(
      child: Image.asset(
        isDarkMode
            ? 'assets/images/dark_mode.png'
            : 'assets/images/light_mode.png',
        width: markerSize,
        height: markerSize,
        fit: BoxFit.contain,
      ),
    );

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final startX = -markerSize * 0.5;
          final endX = constraints.maxWidth - markerSize * 0.5;
          final baseY = constraints.maxHeight * 0.82;

          return ValueListenableBuilder<double>(
            valueListenable: progress,
            child: marker,
            builder: (context, t, child) {
              final opacity = (t / _fadeInEnd).clamp(0.0, 1.0) * _peakOpacity;
              if (opacity == 0) {
                return const SizedBox.expand();
              }
              return Stack(
                children: [
                  Positioned(
                    left: startX + (endX - startX) * t,
                    top:
                        baseY -
                        constraints.maxHeight * lift * math.sin(t * math.pi),
                    width: markerSize,
                    height: markerSize,
                    child: Opacity(opacity: opacity, child: child),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
