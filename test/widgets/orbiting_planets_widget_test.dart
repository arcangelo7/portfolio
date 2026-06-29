// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/l10n/app_localizations.dart';
import 'package:portfolio/widgets/orbiting_planets_widget.dart';

void main() {
  testWidgets('theme elements render outgoing and incoming planets', (
    WidgetTester tester,
  ) async {
    final hostKey = GlobalKey<_ThemeElementHostState>();

    await tester.pumpWidget(_ThemeElementHost(key: hostKey));

    expect(find.byKey(const ValueKey('theme-element-sun')), findsOneWidget);
    expect(find.byKey(const ValueKey('theme-element-moon')), findsNothing);

    hostKey.currentState!.setDarkMode(true);
    await tester.pump();

    expect(find.byKey(const ValueKey('theme-element-sun')), findsOneWidget);
    expect(find.byKey(const ValueKey('theme-element-moon')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 325));

    expect(find.byKey(const ValueKey('theme-element-sun')), findsOneWidget);
    expect(find.byKey(const ValueKey('theme-element-moon')), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('theme-element-sun')), findsNothing);
    expect(find.byKey(const ValueKey('theme-element-moon')), findsOneWidget);
  });

  testWidgets('theme elements skip transition when animations are disabled', (
    WidgetTester tester,
  ) async {
    final hostKey = GlobalKey<_ThemeElementHostState>();

    await tester.pumpWidget(
      _ThemeElementHost(key: hostKey, disableAnimations: true),
    );

    expect(find.byKey(const ValueKey('theme-element-sun')), findsOneWidget);
    expect(find.byKey(const ValueKey('theme-element-moon')), findsNothing);

    hostKey.currentState!.setDarkMode(true);
    await tester.pump();

    expect(find.byKey(const ValueKey('theme-element-sun')), findsNothing);
    expect(find.byKey(const ValueKey('theme-element-moon')), findsOneWidget);
  });
}

class _ThemeElementHost extends StatefulWidget {
  final bool disableAnimations;

  const _ThemeElementHost({super.key, this.disableAnimations = false});

  @override
  State<_ThemeElementHost> createState() => _ThemeElementHostState();
}

class _ThemeElementHostState extends State<_ThemeElementHost> {
  bool _isDarkMode = false;

  void setDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('it'), Locale('es')],
      home: MediaQuery(
        data: const MediaQueryData(
          size: Size(800, 600),
        ).copyWith(disableAnimations: widget.disableAnimations),
        child: Scaffold(
          body: SizedBox(
            width: 800,
            height: 600,
            child: Stack(
              children: [
                StaticThemeElementsWidget(
                  isDarkMode: _isDarkMode,
                  elementSize: 80,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
