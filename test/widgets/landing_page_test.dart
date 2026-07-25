// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portfolio/controllers/publications_controller.dart';
import 'package:portfolio/l10n/app_localizations.dart';
import 'package:portfolio/main.dart';
import 'package:portfolio/theme/portfolio_theme.dart';
import 'package:portfolio/models/publication.dart';
import 'package:portfolio/services/opencitations_index_service.dart';
import 'package:portfolio/services/zotero_service.dart';

class _MockZoteroService extends Mock implements ZoteroService {}

class _MockOpenCitationsIndexService extends Mock
    implements OpenCitationsIndexService {}

void main() {
  late _MockZoteroService zoteroService;
  late PublicationsController publicationsController;

  setUp(() async {
    zoteroService = _MockZoteroService();
    when(
      () => zoteroService.getPublications(),
    ).thenAnswer((_) async => <Publication>[]);
    publicationsController = PublicationsController(
      zoteroService: zoteroService,
    );
    await publicationsController.loadPublications();
  });

  tearDown(() {
    publicationsController.dispose();
  });

  testWidgets('hero navigates to an unbuilt publications section', (
    WidgetTester tester,
  ) async {
    final changedSections = <String>[];
    await _setDesktopViewport(tester);
    await tester.pumpWidget(
      _buildLandingPage(
        publicationsController: publicationsController,
        changedSections: changedSections,
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('section-publications')), findsNothing);

    await tester.tap(find.text('Check out my projects'));
    await tester.pumpAndSettle();

    expect(changedSections, ['publications']);
    expect(find.byKey(const ValueKey('section-publications')), findsOneWidget);
  });

  testWidgets('table of contents navigates to an unbuilt section', (
    WidgetTester tester,
  ) async {
    final changedSections = <String>[];
    await _setDesktopViewport(tester);
    await tester.pumpWidget(
      _buildLandingPage(
        publicationsController: publicationsController,
        changedSections: changedSections,
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('section-astrogods')), findsNothing);

    await tester.tap(find.byIcon(Icons.list_rounded));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.travel_explore));
    final offsets = await _pumpNavigation(tester);

    expect(changedSections, ['astrogods']);
    expect(find.byKey(const ValueKey('section-astrogods')), findsOneWidget);
    expect(offsets, List<double>.from(offsets)..sort());
  });

  testWidgets('initial fragment positions an initially unbuilt section', (
    WidgetTester tester,
  ) async {
    final changedSections = <String>[];
    await _setDesktopViewport(tester);
    await tester.pumpWidget(
      _buildLandingPage(
        publicationsController: publicationsController,
        changedSections: changedSections,
        initialSectionId: 'astrogods',
      ),
    );
    await _pumpNavigation(tester);

    expect(find.byKey(const ValueKey('section-astrogods')), findsOneWidget);
    expect(find.byKey(const ValueKey('section-about')), findsNothing);
    expect(changedSections, isEmpty);
  });

  testWidgets(
    'initial fragment waits for publication layout before positioning',
    (WidgetTester tester) async {
      final publicationsCompleter = Completer<List<Publication>>();
      final citationCountCompleter = Completer<int>();
      final totalCitationCountCompleter = Completer<int>();
      final descriptionCompleter = Completer<String?>();
      final delayedZoteroService = _MockZoteroService();
      final openCitationsService = _MockOpenCitationsIndexService();
      when(
        delayedZoteroService.getPublications,
      ).thenAnswer((_) => publicationsCompleter.future);
      when(
        () => openCitationsService.getCitationCount('10.1000/delayed'),
      ).thenAnswer((_) => citationCountCompleter.future);
      when(
        () => openCitationsService.getTotalCitationCount(['10.1000/delayed']),
      ).thenAnswer((_) => totalCitationCountCompleter.future);
      final delayedController = PublicationsController(
        zoteroService: delayedZoteroService,
        openCitationsService: openCitationsService,
        gitHubDescriptionLoader: (url) {
          expect(url, 'https://github.com/example/delayed');
          return descriptionCompleter.future;
        },
      );
      addTearDown(delayedController.dispose);

      await _setDesktopViewport(tester);
      await tester.pumpWidget(
        _buildLandingPage(
          publicationsController: delayedController,
          changedSections: <String>[],
          initialSectionId: 'astrogods',
        ),
      );
      await tester.pump();

      expect(find.byKey(const ValueKey('section-astrogods')), findsNothing);

      publicationsCompleter.complete([
        const Publication(
          key: 'delayed-article',
          title: 'Delayed article',
          authors: ['Arcangelo Massari'],
          year: '2026',
          itemType: 'journalArticle',
          doi: '10.1000/delayed',
        ),
        const Publication(
          key: 'delayed-software',
          title: 'Delayed software',
          authors: ['Arcangelo Massari'],
          year: '2026',
          itemType: 'computerProgram',
          url: 'https://github.com/example/delayed',
        ),
      ]);
      await tester.pump();
      await tester.pump();

      citationCountCompleter.complete(4);
      totalCitationCountCompleter.complete(4);
      await tester.pump();
      await tester.pump();

      expect(find.byKey(const ValueKey('section-astrogods')), findsNothing);

      descriptionCompleter.complete('Delayed description');
      await _pumpNavigation(tester);

      expect(find.byKey(const ValueKey('section-astrogods')), findsOneWidget);
      final scrollable = tester.state<ScrollableState>(
        find.byType(Scrollable).first,
      );
      final positionedOffset = scrollable.position.pixels;

      await tester.pump(const Duration(seconds: 1));

      expect(scrollable.position.pixels, positionedOffset);
      verify(delayedZoteroService.getPublications).called(1);
      verify(
        () => openCitationsService.getCitationCount('10.1000/delayed'),
      ).called(1);
      verify(
        () => openCitationsService.getTotalCitationCount(['10.1000/delayed']),
      ).called(1);
    },
  );
}

Future<void> _setDesktopViewport(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1200, 800);
  addTearDown(tester.view.reset);
}

Future<List<double>> _pumpNavigation(WidgetTester tester) async {
  final offsets = <double>[];
  for (var frame = 0; frame < 40; frame++) {
    await tester.pump(const Duration(milliseconds: 50));
    offsets.add(
      tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .pixels,
    );
  }
  return offsets;
}

Widget _buildLandingPage({
  required PublicationsController publicationsController,
  required List<String> changedSections,
  String? initialSectionId,
}) {
  return MaterialApp(
    theme: PortfolioTheme.lightTheme,
    darkTheme: PortfolioTheme.darkTheme,
    themeAnimationStyle: AnimationStyle.noAnimation,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en'), Locale('it'), Locale('es')],
    home: MediaQuery(
      data: const MediaQueryData(
        size: Size(1200, 800),
        disableAnimations: true,
      ),
      child: LandingPage(
        onLanguageChanged: (_) {},
        currentLocale: const Locale('en'),
        onThemeToggle: () {},
        isDarkMode: false,
        onSectionChanged: changedSections.add,
        initialSectionId: initialSectionId,
        publicationsController: publicationsController,
      ),
    ),
  );
}
