// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/material.dart';

/// Spacing steps. Every gap, padding and margin in the app comes from here.
abstract final class Space {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double section = 64;
  static const double sectionWide = 96;
}

/// Corner radii. The ladder is what makes prominence readable: metadata pills
/// sit tighter than cards, cards tighter than panels.
abstract final class Radii {
  static const BorderRadius pill = BorderRadius.all(Radius.circular(4));
  static const BorderRadius card = BorderRadius.all(Radius.circular(10));
  static const BorderRadius panel = BorderRadius.all(Radius.circular(16));
  static const BorderRadius bubble = BorderRadius.all(Radius.circular(24));
}

abstract final class Motion {
  static const Duration quick = Duration(milliseconds: 200);
  static const Duration standard = Duration(milliseconds: 320);
  static const Duration reveal = Duration(milliseconds: 420);
  static const Duration theme = Duration(milliseconds: 800);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve settle = Curves.easeInOut;
}

/// Width caps. Without these the prose runs the full width of the viewport.
abstract final class Layout {
  /// Running prose, kept near 70 characters at [TextTheme.bodyLarge].
  static const double prose = 660;

  /// Cards, grids and anything that tolerates more width than prose.
  static const double content = 980;
}
