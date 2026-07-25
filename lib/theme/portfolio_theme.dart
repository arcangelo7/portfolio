// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/material.dart';

import 'design_tokens.dart';

/// Day and night are two deliberate atmospheres, not one design inverted.
///
/// Day is cool and dry: cobalt ink on ice. The only warmth is the sun itself,
/// as an object: gold reads 1.31:1 on ice white and can never be a day accent.
/// Night is deep and blue-black, with gold as the single warm thing, which is
/// what lets the AstroGods section belong to the system instead of escaping it.
class PortfolioTheme {
  static const Color iceWhite = Color(0xFFF0F8FF);
  static const Color emeraldGreen = Color(0xFF226C3B);
  static const Color violet = Color(0xFF420075);
  static const Color wine = Color(0xFF800020);
  static const Color cobaltBlue = Color(0xFF000075);
  static const Color lightCobaltBlue = Color(0xFF8E8EF0);
  static const Color black = Color(0xFF1A1A1A);

  /// Night ground. Deeper and bluer than [black] so it meets the star field
  /// and the AstroGods sky (0xFF0C1116) instead of sitting apart from them.
  static const Color nightGround = Color(0xFF12141A);

  /// Night-legible cuts of the brand hues. The originals fail badly on the
  /// night ground: emerald reads 2.72:1 and violet 1.23:1.
  static const Color emeraldNight = Color(0xFF5FB57C);
  static const Color violetNight = Color(0xFFB98CE8);
  static const Color wineNight = Color(0xFFE9738C);

  static const Color astroGold = Color(0xFFFFD700);
  static const Color astroMysticBlue = Color(0xFF1A1A2E);
  static const Color astroLightGray = Color(0xFFE0E0E0);

  /// The hero sky, deepest in the corner opposite the sun or moon. The two
  /// ramps carry the same number of stops so the theme transition lerps them
  /// one to one.
  static const List<Color> heroDaySky = [
    Color(0xFF0E2A63),
    Color(0xFF3F5596),
    Color(0xFF7E8DC4),
  ];
  static const List<Color> heroNightSky = [
    Color(0xFF0A0C11),
    Color(0xFF141B33),
    Color(0xFF1E2A55),
  ];

  /// The light the mascot casts on the sky around it: brightest at the mascot,
  /// gone before the text column. Day reaches the blue through rose, the way a
  /// dawn does. A two stop lerp from blue to gold would instead pass through
  /// the desaturated middle and turn the frame olive, which is why the warm
  /// end lives here as a local glow and never as a stop of the sky itself.
  static const List<Color> heroDayGlow = [
    Color(0xEBFFDCA8),
    Color(0x4DEE9AA8),
    Color(0x00EE9AA8),
  ];
  static const List<Color> heroNightGlow = [
    Color(0x66B9C6F0),
    Color(0x1F6E7CB8),
    Color(0x006E7CB8),
  ];

  /// Warm cuts that complete the night accent set. Together with [astroGold],
  /// [violetNight], [lightCobaltBlue] and [emeraldNight] these are the six
  /// hues the AstroGods cards draw from, so that section stops running on a
  /// palette of its own.
  static const Color amberNight = Color(0xFFF2A65A);
  static const Color emberNight = Color(0xFFE8788C);

  static const String fontDisplay = 'Felipa';
  static const String fontBody = 'IBMPlexSans';
  static const String fontMono = 'IBMPlexMono';

  static const ColorScheme dayColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: cobaltBlue,
    onPrimary: iceWhite,
    primaryContainer: Color(0xFFD5DCF5),
    onPrimaryContainer: Color(0xFF00003D),
    secondary: emeraldGreen,
    onSecondary: iceWhite,
    secondaryContainer: Color(0xFFD3E7DA),
    onSecondaryContainer: Color(0xFF0C2E19),
    tertiary: violet,
    onTertiary: iceWhite,
    tertiaryContainer: Color(0xFFE4D4F2),
    onTertiaryContainer: Color(0xFF1E0035),
    error: wine,
    onError: iceWhite,
    errorContainer: Color(0xFFF6D6DD),
    onErrorContainer: Color(0xFF3A000E),
    surface: iceWhite,
    onSurface: black,
    onSurfaceVariant: Color(0xFF4A5568),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFE9F1FB),
    surfaceContainer: Color(0xFFE3EDF9),
    surfaceContainerHigh: Color(0xFFDAE7F6),
    surfaceContainerHighest: Color(0xFFD1E0F2),
    outline: Color(0xFFA9C0DA),
    outlineVariant: Color(0xFFCBDCEE),
    shadow: Color(0xFF0B1B2E),
    scrim: Color(0xFF0B1B2E),
    inverseSurface: nightGround,
    onInverseSurface: iceWhite,
    inversePrimary: lightCobaltBlue,
  );

  static const ColorScheme nightColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: lightCobaltBlue,
    onPrimary: Color(0xFF0B0B2E),
    primaryContainer: Color(0xFF262C5F),
    onPrimaryContainer: Color(0xFFD5DCF5),
    secondary: emeraldNight,
    onSecondary: Color(0xFF06210F),
    secondaryContainer: Color(0xFF1B3D28),
    onSecondaryContainer: Color(0xFFD3E7DA),
    tertiary: violetNight,
    onTertiary: Color(0xFF1E0035),
    tertiaryContainer: Color(0xFF35205A),
    onTertiaryContainer: Color(0xFFE4D4F2),
    error: wineNight,
    onError: Color(0xFF3A000E),
    errorContainer: Color(0xFF5C1424),
    onErrorContainer: Color(0xFFF6D6DD),
    surface: nightGround,
    onSurface: iceWhite,
    onSurfaceVariant: Color(0xFFA8B2C4),
    surfaceContainerLowest: Color(0xFF0D0F14),
    surfaceContainerLow: Color(0xFF16191F),
    surfaceContainer: Color(0xFF1B1F26),
    surfaceContainerHigh: Color(0xFF22262F),
    surfaceContainerHighest: Color(0xFF2A2F39),
    outline: Color(0xFF515C6B),
    outlineVariant: Color(0xFF333B47),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: iceWhite,
    onInverseSurface: black,
    inversePrimary: cobaltBlue,
  );

  /// Felipa is a single-weight calligraphic face, so display roles never carry
  /// a weight other than 400 and never inherit the negative tracking Material
  /// ships for Roboto, which on a script collides the swashes.
  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: fontDisplay,
      fontSize: 64,
      fontWeight: FontWeight.w400,
      letterSpacing: 1,
      height: 1.08,
    ),
    displayMedium: TextStyle(
      fontFamily: fontDisplay,
      fontSize: 48,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.8,
      height: 1.12,
    ),
    displaySmall: TextStyle(
      fontFamily: fontDisplay,
      fontSize: 38,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.6,
      height: 1.15,
    ),
    headlineLarge: TextStyle(
      fontFamily: fontBody,
      fontSize: 30,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.2,
      height: 1.25,
    ),
    headlineMedium: TextStyle(
      fontFamily: fontBody,
      fontSize: 26,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.15,
      height: 1.28,
    ),
    headlineSmall: TextStyle(
      fontFamily: fontBody,
      fontSize: 22,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.1,
      height: 1.32,
    ),
    titleLarge: TextStyle(
      fontFamily: fontBody,
      fontSize: 20,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.1,
      height: 1.35,
    ),
    titleMedium: TextStyle(
      fontFamily: fontBody,
      fontSize: 17,
      fontWeight: FontWeight.w500,
      height: 1.45,
    ),
    titleSmall: TextStyle(
      fontFamily: fontBody,
      fontSize: 15,
      fontWeight: FontWeight.w500,
      height: 1.45,
    ),
    bodyLarge: TextStyle(
      fontFamily: fontBody,
      fontSize: 17,
      fontWeight: FontWeight.w400,
      height: 1.65,
    ),
    bodyMedium: TextStyle(
      fontFamily: fontBody,
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.6,
    ),
    bodySmall: TextStyle(
      fontFamily: fontBody,
      fontSize: 13,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.1,
      height: 1.5,
    ),
    labelLarge: TextStyle(
      fontFamily: fontMono,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
      height: 1.4,
    ),
    labelMedium: TextStyle(
      fontFamily: fontMono,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
      height: 1.35,
    ),
    labelSmall: TextStyle(
      fontFamily: fontMono,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.3,
      height: 1.35,
    ),
  );

  static ThemeData _build(ColorScheme scheme) {
    final textTheme = _textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      brightness: scheme.brightness,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: fontBody,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: scheme.surfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: Radii.card),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainer,
        selectedColor: scheme.primaryContainer,
        side: BorderSide(color: scheme.outlineVariant),
        labelStyle: textTheme.labelLarge,
        shape: const RoundedRectangleBorder(borderRadius: Radii.pill),
        padding: const EdgeInsets.symmetric(
          horizontal: Space.sm,
          vertical: Space.xs,
        ),
        showCheckmark: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: Space.lg,
            vertical: Space.md,
          ),
          shape: const RoundedRectangleBorder(borderRadius: Radii.card),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: textTheme.labelLarge,
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline),
          padding: const EdgeInsets.symmetric(
            horizontal: Space.lg,
            vertical: Space.md,
          ),
          shape: const RoundedRectangleBorder(borderRadius: Radii.card),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: textTheme.labelLarge,
          foregroundColor: scheme.primary,
          shape: const RoundedRectangleBorder(borderRadius: Radii.pill),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: scheme.onSurface),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: Radii.card),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: scheme.surfaceContainer,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Space.md,
          vertical: Space.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: Radii.card,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: Radii.card,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: Radii.card,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: Radii.panel),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: Space.xl,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: const WidgetStatePropertyAll(8),
        radius: const Radius.circular(4),
        thumbColor: WidgetStatePropertyAll(
          scheme.onSurface.withValues(alpha: 0.28),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: const RoundedRectangleBorder(borderRadius: Radii.card),
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodySmall,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: Radii.pill,
        ),
        textStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
      ),
    );
  }

  static final ThemeData lightTheme = _build(dayColorScheme);
  static final ThemeData darkTheme = _build(nightColorScheme);
}
