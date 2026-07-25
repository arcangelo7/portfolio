// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// One continuous sky behind the whole page. Scrolling advances the time of
/// day, but only within the current register: day never becomes night by
/// scrolling, which would leave dark sections stranded in the light theme.
class SkyBackdrop extends StatelessWidget {
  final ValueListenable<double> progress;
  final Widget child;

  const SkyBackdrop({super.key, required this.progress, required this.child});

  static const List<Color> _dayEarly = [Color(0xFFF7FBFF), Color(0xFFE8F1FB)];
  static const List<Color> _dayLate = [Color(0xFFF2F7FE), Color(0xFFDDE9F7)];
  static const List<Color> _nightEarly = [Color(0xFF1B1F2E), Color(0xFF12141A)];
  static const List<Color> _nightLate = [Color(0xFF0E1016), Color(0xFF0A0C11)];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final early = isDark ? _nightEarly : _dayEarly;
    final later = isDark ? _nightLate : _dayLate;

    return ValueListenableBuilder<double>(
      valueListenable: progress,
      child: child,
      builder: (context, t, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(early[0], later[0], t)!,
                Color.lerp(early[1], later[1], t)!,
              ],
            ),
          ),
          child: child,
        );
      },
    );
  }
}
