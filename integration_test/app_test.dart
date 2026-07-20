// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:portfolio/controllers/publications_controller.dart';
import 'package:portfolio/l10n/app_localizations.dart';
import 'package:portfolio/main.dart';
import 'package:portfolio/models/publication.dart';
import 'package:portfolio/services/zotero_service.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'theme transitions, fling and indexed navigation stay responsive',
    (WidgetTester tester) async {
      if (kIsWeb) {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(1200, 800);
        addTearDown(tester.view.reset);
      }

      await tester.pumpWidget(const _IntegrationHost());
      await _pumpFrames(tester, 60);

      expect(find.byKey(const ValueKey('section-hero')), findsOneWidget);
      await _runThemeCycle(tester);

      await _recordFrameTimings(
        binding,
        'hero_theme_transitions',
        () => _runThemeCycles(tester),
      );

      await tester.tap(find.text('Check out my projects'));
      await _pumpFrames(tester, 120);
      expect(
        find.byKey(const ValueKey('section-publications')),
        findsOneWidget,
      );

      await _runThemeCycle(tester);
      await _recordFrameTimings(
        binding,
        'publications_theme_transitions',
        () => _runThemeCycles(tester),
      );

      final scrollable = find.byType(Scrollable).first;
      var flingOffsets = <double>[];
      await _recordFrameTimings(binding, 'rapid_scroll', () async {
        await tester.fling(scrollable, const Offset(0, -6000), 10000);
        flingOffsets = await _recordScrollOffsets(tester);
      });
      expect(flingOffsets, List<double>.from(flingOffsets)..sort());

      await _recordFrameTimings(binding, 'toc_navigation', () async {
        if (kIsWeb) {
          await tester.tap(find.byKey(const ValueKey('toc-toggle')));
        } else {
          await tester.tap(find.byIcon(Icons.settings));
          await _pumpFrames(tester, 20);
          await tester.tap(find.byKey(const ValueKey('toc-toggle-mobile')));
        }
        await tester.pump();
        await tester.tap(find.byIcon(Icons.travel_explore));
        await _pumpFrames(tester, 120);
      });
      expect(find.byKey(const ValueKey('section-astrogods')), findsOneWidget);

      await _runThemeCycle(tester);
      await _recordFrameTimings(
        binding,
        'astrogods_theme_transitions',
        () => _runThemeCycles(tester),
      );
    },
  );
}

Future<void> _runThemeCycles(WidgetTester tester) async {
  for (var cycle = 0; cycle < 3; cycle++) {
    await _runThemeCycle(tester);
  }
}

Future<void> _runThemeCycle(WidgetTester tester) async {
  await _tapThemeToggle(tester);
  await _pumpFrames(tester, 51);
  await _tapThemeToggle(tester);
  await _pumpFrames(tester, 51);
}

Future<void> _tapThemeToggle(WidgetTester tester) async {
  if (kIsWeb) {
    await tester.tap(find.byKey(const ValueKey('theme-toggle')));
    return;
  }
  await tester.tap(find.byIcon(Icons.settings));
  await _pumpFrames(tester, 20);
  await tester.tap(find.byKey(const ValueKey('theme-toggle-mobile')));
}

Future<void> _pumpFrames(WidgetTester tester, int count) async {
  for (var frame = 0; frame < count; frame++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

Future<List<double>> _recordScrollOffsets(WidgetTester tester) async {
  final offsets = <double>[];
  for (var frame = 0; frame < 120; frame++) {
    await tester.pump(const Duration(milliseconds: 16));
    offsets.add(
      tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .pixels,
    );
  }
  return offsets;
}

Future<void> _recordFrameTimings(
  IntegrationTestWidgetsFlutterBinding binding,
  String reportKey,
  Future<void> Function() action,
) async {
  await Future<void>.delayed(const Duration(seconds: 2));
  final timings = <FrameTiming>[];
  final callback = timings.addAll;
  SchedulerBinding.instance.addTimingsCallback(callback);
  await action();
  await Future<void>.delayed(const Duration(seconds: 2));
  SchedulerBinding.instance.removeTimingsCallback(callback);

  final buildTimes =
      timings.map((timing) => timing.buildDuration.inMicroseconds).toList()
        ..sort();
  final rasterTimes =
      timings.map((timing) => timing.rasterDuration.inMicroseconds).toList()
        ..sort();
  final frameTimes =
      timings
          .map(
            (timing) => math.max(
              timing.buildDuration.inMicroseconds,
              timing.rasterDuration.inMicroseconds,
            ),
          )
          .toList()
        ..sort();
  final percentileIndex = (frameTimes.length * 0.95).ceil() - 1;

  binding.reportData ??= <String, dynamic>{};
  binding.reportData![reportKey] = <String, dynamic>{
    'frame_count': frameTimes.length,
    'p95_frame_time_ms': frameTimes[percentileIndex] / 1000,
    'p95_build_time_ms': buildTimes[percentileIndex] / 1000,
    'p95_raster_time_ms': rasterTimes[percentileIndex] / 1000,
    'max_frame_time_ms': frameTimes.last / 1000,
    'frames_over_16_7_ms': frameTimes
        .where((duration) => duration > 16700)
        .length,
    'frames_over_33_3_ms': frameTimes
        .where((duration) => duration > 33300)
        .length,
  };
}

class _IntegrationHost extends StatefulWidget {
  const _IntegrationHost();

  @override
  State<_IntegrationHost> createState() => _IntegrationHostState();
}

class _IntegrationHostState extends State<_IntegrationHost> {
  late final PublicationsController _publicationsController;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _publicationsController = PublicationsController(
      zoteroService: _EmptyZoteroService(),
    );
  }

  @override
  void dispose() {
    _publicationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: PortfolioTheme.lightTheme,
      darkTheme: PortfolioTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('it'), Locale('es')],
      home: LandingPage(
        onLanguageChanged: (_) {},
        currentLocale: const Locale('en'),
        onThemeToggle: () {
          setState(() {
            _isDarkMode = !_isDarkMode;
          });
        },
        isDarkMode: _isDarkMode,
        onSectionChanged: (_) {},
        publicationsController: _publicationsController,
      ),
    );
  }
}

class _EmptyZoteroService extends ZoteroService {
  @override
  Future<List<Publication>> getPublications() async {
    return List.generate(
      10,
      (index) => Publication(
        key: 'integration-$index',
        title: 'Integration publication $index',
        authors: const ['Arcangelo Massari'],
        journal: 'Integration Journal',
        year: '2026',
        itemType: 'journalArticle',
      ),
    );
  }
}
