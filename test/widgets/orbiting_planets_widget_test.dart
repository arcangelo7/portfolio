// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/l10n/app_localizations.dart';
import 'package:portfolio/theme/portfolio_theme.dart';
import 'package:portfolio/widgets/hero_section.dart';
import 'package:portfolio/widgets/starry_background.dart';

void main() {
  testWidgets('sun and moon follow the 650 ms trajectory in both directions', (
    WidgetTester tester,
  ) async {
    final hostKey = GlobalKey<_HeroHostState>();
    await tester.pumpWidget(_HeroHost(key: hostKey));

    expect(find.byKey(const ValueKey('theme-element-sun')), findsOneWidget);
    expect(find.byKey(const ValueKey('theme-element-moon')), findsNothing);
    _expectTranslation(tester, 'theme-element-sun-transform', Offset.zero);

    hostKey.currentState!.setDarkMode(true);
    await tester.pump();

    expect(find.byKey(const ValueKey('theme-element-sun')), findsOneWidget);
    expect(find.byKey(const ValueKey('theme-element-moon')), findsOneWidget);
    _expectTranslation(tester, 'theme-element-sun-transform', Offset.zero);
    _expectTranslation(
      tester,
      'theme-element-moon-transform',
      const Offset(-220, 104),
    );

    await tester.pump(const Duration(milliseconds: 325));

    final midpoint = Curves.easeInOutCubic.transform(0.5);
    _expectTranslation(
      tester,
      'theme-element-sun-transform',
      Offset(
        940 * midpoint,
        380 * midpoint - 72 * math.sin(midpoint * math.pi),
      ),
    );
    _expectTranslation(
      tester,
      'theme-element-moon-transform',
      Offset(
        -220 * (1 - midpoint),
        104 * (1 - midpoint) - 36 * math.sin(midpoint * math.pi),
      ),
    );

    await tester.pump(const Duration(milliseconds: 475));
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();

    expect(find.byKey(const ValueKey('theme-element-sun')), findsNothing);
    expect(find.byKey(const ValueKey('theme-element-moon')), findsOneWidget);
    _expectTranslation(tester, 'theme-element-moon-transform', Offset.zero);

    hostKey.currentState!.setDarkMode(false);
    await tester.pump();

    _expectTranslation(tester, 'theme-element-moon-transform', Offset.zero);
    _expectTranslation(
      tester,
      'theme-element-sun-transform',
      const Offset(-220, 104),
    );

    await tester.pump(const Duration(milliseconds: 325));

    _expectTranslation(
      tester,
      'theme-element-moon-transform',
      Offset(
        940 * midpoint,
        380 * midpoint - 72 * math.sin(midpoint * math.pi),
      ),
    );
    _expectTranslation(
      tester,
      'theme-element-sun-transform',
      Offset(
        -220 * (1 - midpoint),
        104 * (1 - midpoint) - 36 * math.sin(midpoint * math.pi),
      ),
    );

    await tester.pump(const Duration(milliseconds: 475));
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();

    expect(find.byKey(const ValueKey('theme-element-moon')), findsNothing);
    expect(find.byKey(const ValueKey('theme-element-sun')), findsOneWidget);
    _expectTranslation(tester, 'theme-element-sun-transform', Offset.zero);
  });

  testWidgets('gradient and moving stars span 800 ms in both directions', (
    WidgetTester tester,
  ) async {
    final hostKey = GlobalKey<_HeroHostState>();
    await tester.pumpWidget(_HeroHost(key: hostKey));
    final profileState = tester.state(
      find.byKey(const ValueKey('hero-profile')),
    );

    hostKey.currentState!.setDarkMode(true);
    await tester.pump();

    _expectThemeProgress(tester, progress: 0, starOpacity: 0);
    _expectStarsEnabled(tester, true);
    expect(
      tester.state(find.byKey(const ValueKey('hero-profile'))),
      same(profileState),
    );

    await tester.pump(const Duration(milliseconds: 325));
    final progressAt325 = Curves.easeInOut.transform(325 / 800);
    _expectThemeProgress(
      tester,
      progress: progressAt325,
      starOpacity: progressAt325,
    );
    _expectStarsEnabled(tester, true);

    await tester.pump(const Duration(milliseconds: 75));
    _expectThemeProgress(tester, progress: 0.5, starOpacity: 0.5);

    await tester.pump(const Duration(milliseconds: 250));
    final progressAt650 = Curves.easeInOut.transform(650 / 800);
    _expectThemeProgress(
      tester,
      progress: progressAt650,
      starOpacity: progressAt650,
    );
    _expectTranslation(
      tester,
      'theme-element-moon-transform',
      Offset(0, -36 * math.sin(math.pi)),
    );

    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();

    _expectThemeProgress(tester, progress: 1, starOpacity: 1);
    _expectStarsEnabled(tester, true);
    expect(
      tester.state(find.byKey(const ValueKey('hero-profile'))),
      same(profileState),
    );

    hostKey.currentState!.setDarkMode(false);
    await tester.pump();

    _expectThemeProgress(
      tester,
      progress: 0,
      starOpacity: 1,
      previousDarkMode: true,
    );
    _expectStarsEnabled(tester, true);

    await tester.pump(const Duration(milliseconds: 325));
    _expectThemeProgress(
      tester,
      progress: progressAt325,
      starOpacity: 1 - progressAt325,
      previousDarkMode: true,
    );

    await tester.pump(const Duration(milliseconds: 75));
    _expectThemeProgress(
      tester,
      progress: 0.5,
      starOpacity: 0.5,
      previousDarkMode: true,
    );

    await tester.pump(const Duration(milliseconds: 250));
    _expectThemeProgress(
      tester,
      progress: progressAt650,
      starOpacity: 1 - progressAt650,
      previousDarkMode: true,
    );
    _expectTranslation(
      tester,
      'theme-element-sun-transform',
      Offset(0, -36 * math.sin(math.pi)),
    );

    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();

    expect(_gradientColors(tester), PortfolioTheme.heroDaySky);
    expect(_starOpacity(tester), 0);
    _expectStarsEnabled(tester, false);
    expect(
      tester.state(find.byKey(const ValueKey('hero-profile'))),
      same(profileState),
    );
  });

  testWidgets('theme transition is immediate when animations are disabled', (
    WidgetTester tester,
  ) async {
    final hostKey = GlobalKey<_HeroHostState>();
    await tester.pumpWidget(_HeroHost(key: hostKey, disableAnimations: true));

    hostKey.currentState!.setDarkMode(true);
    await tester.pump();

    expect(find.byKey(const ValueKey('theme-element-sun')), findsNothing);
    expect(find.byKey(const ValueKey('theme-element-moon')), findsOneWidget);
    _expectTranslation(tester, 'theme-element-moon-transform', Offset.zero);
    expect(_gradientColors(tester), PortfolioTheme.heroNightSky);
    expect(_starOpacity(tester), 1);
    _expectStarsEnabled(tester, true);

    hostKey.currentState!.setDarkMode(false);
    await tester.pump();

    expect(_gradientColors(tester), PortfolioTheme.heroDaySky);
    expect(_starOpacity(tester), 0);
    _expectStarsEnabled(tester, false);
  });

  testWidgets('the glow stays behind the mascot at every viewport', (
    WidgetTester tester,
  ) async {
    addTearDown(tester.view.reset);

    for (final viewport in const [
      Size(1440, 900),
      Size(2560, 1440),
      Size(390, 844),
    ]) {
      tester.view
        ..physicalSize = viewport
        ..devicePixelRatio = 1;
      await tester.pumpWidget(_HeroHost(viewport: viewport));

      final glow = tester.getRect(find.byKey(const ValueKey('hero-glow')));
      final sun = tester.getRect(
        find.byKey(const ValueKey('theme-element-sun')),
      );

      expect(
        glow.center,
        sun.center,
        reason: 'the light must come from behind the mascot at $viewport',
      );
      expect(
        glow.width,
        sun.width * 7,
        reason: 'the halo scales with the mascot, not with the viewport',
      );
    }
  });
}

void _expectThemeProgress(
  WidgetTester tester, {
  required double progress,
  required double starOpacity,
  bool previousDarkMode = false,
}) {
  final previousColors = previousDarkMode
      ? PortfolioTheme.heroNightSky
      : PortfolioTheme.heroDaySky;
  final finalColors = previousDarkMode
      ? PortfolioTheme.heroDaySky
      : PortfolioTheme.heroNightSky;
  expect(_gradientColors(tester), [
    for (var i = 0; i < finalColors.length; i++)
      Color.lerp(previousColors[i], finalColors[i], progress),
  ]);
  expect(_starOpacity(tester), starOpacity);
}

void _expectStarsEnabled(WidgetTester tester, bool expected) {
  expect(
    tester
        .widget<StarryBackground>(find.byKey(const ValueKey('hero-stars')))
        .enableAnimation,
    expected,
  );
}

double _starOpacity(WidgetTester tester) {
  return tester
      .widget<Opacity>(find.byKey(const ValueKey('hero-stars-opacity')))
      .opacity;
}

void _expectTranslation(WidgetTester tester, String key, Offset expected) {
  final transform = tester.widget<Transform>(find.byKey(ValueKey(key)));
  final translation = transform.transform.getTranslation();
  expect(Offset(translation.x, translation.y), expected);
}

List<Color?> _gradientColors(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find.byKey(const ValueKey('hero-gradient')),
  );
  final decoration = box.decoration as BoxDecoration;
  final gradient = decoration.gradient! as LinearGradient;
  return gradient.colors;
}

class _HeroHost extends StatefulWidget {
  final bool disableAnimations;
  final Size viewport;

  const _HeroHost({
    super.key,
    this.disableAnimations = false,
    this.viewport = const Size(800, 600),
  });

  @override
  State<_HeroHost> createState() => _HeroHostState();
}

class _HeroHostState extends State<_HeroHost> {
  bool _isDarkMode = false;

  void setDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: PortfolioTheme.lightTheme,
      darkTheme: PortfolioTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      themeAnimationStyle: AnimationStyle.noAnimation,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('it'), Locale('es')],
      home: MediaQuery(
        data: MediaQueryData(
          size: widget.viewport,
        ).copyWith(disableAnimations: widget.disableAnimations),
        child: Scaffold(
          body: HeroSection(isDarkMode: _isDarkMode, onViewWork: () {}),
        ),
      ),
    );
  }
}
