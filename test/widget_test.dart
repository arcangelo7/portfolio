import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:portfolio/l10n/app_localizations.dart';
import 'package:portfolio/widgets/publications_section.dart';

import 'package:portfolio/main.dart' as portfolio_main;

Widget createTestApp({
  Locale locale = const Locale('en'),
  bool isDarkMode = true,
}) {
  return MaterialApp(
    locale: locale,
    theme: portfolio_main.PortfolioTheme.lightTheme,
    darkTheme: portfolio_main.PortfolioTheme.darkTheme,
    themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en'), Locale('it'), Locale('es')],
    home: portfolio_main.LandingPage(
      onLanguageChanged: (locale) {},
      currentLocale: locale,
      onThemeToggle: () {},
      isDarkMode: isDarkMode,
    ),
  );
}

void main() {
  testWidgets('Main function initializes app correctly', (WidgetTester tester) async {
    portfolio_main.main();
    await tester.pumpAndSettle();
    
    expect(find.byType(portfolio_main.PortfolioApp), findsOneWidget);
  });
  
  testWidgets('Portfolio app loads correctly in English', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Arcangelo Massari'), findsAtLeastNWidgets(1));
    expect(find.textContaining('PhD Candidate'), findsOneWidget);
    expect(find.text('About Me'), findsOneWidget);
    expect(find.text('Skills'), findsOneWidget);
    expect(find.text('Get In Touch'), findsOneWidget);
  });

  testWidgets('Portfolio app loads correctly in Italian', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(locale: const Locale('it')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Arcangelo Massari'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Dottorando PhD'), findsOneWidget);
    expect(find.text('Chi Sono'), findsOneWidget);
    expect(find.text('Competenze'), findsOneWidget);
    expect(find.text('Contattami'), findsOneWidget);
  });

  testWidgets('Portfolio app loads correctly in Spanish', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(locale: const Locale('es')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Arcangelo Massari'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Candidato a PhD'), findsOneWidget);
    expect(find.text('Sobre Mí'), findsOneWidget);
    expect(find.text('Habilidades'), findsOneWidget);
    expect(find.text('Ponte en Contacto'), findsOneWidget);
  });

  testWidgets('Spanish localization appTitle works correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const portfolio_main.PortfolioApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    final localizations = AppLocalizations.of(tester.element(find.byType(portfolio_main.LandingPage)))!;
    expect(localizations.appTitle, equals('Portfolio de Arcangelo Massari'));
  });

  testWidgets('Hero section contains required elements', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(find.text('View My Work'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Floating action buttons are present', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsNWidgets(2));
    expect(find.byIcon(Icons.language), findsOneWidget);
    expect(find.byIcon(Icons.light_mode), findsOneWidget);
  });

  testWidgets('Skills section displays skill chips', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Flutter'), findsOneWidget);
    expect(find.text('Dart'), findsOneWidget);
    expect(find.text('JavaScript'), findsOneWidget);
    expect(find.text('Python'), findsOneWidget);
    expect(find.text('UI/UX Design'), findsOneWidget);
    expect(find.byType(Chip), findsNWidgets(5));
  });

  testWidgets('Contact section has social icons', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.email), findsOneWidget);
    expect(find.byIcon(Icons.web), findsOneWidget);
    expect(find.byIcon(Icons.code), findsOneWidget);
    expect(find.text('© 2025 Arcangelo Massari. All rights reserved.'), findsOneWidget);
  });

  testWidgets('Language selector works via floating button', (WidgetTester tester) async {
    await tester.pumpWidget(const portfolio_main.PortfolioApp());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.language), findsOneWidget);
    
    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();
    
    expect(find.text('Select Language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Italiano'), findsOneWidget);
    expect(find.text('Español'), findsOneWidget);
  });

  testWidgets('Theme toggle floating button changes icon', (WidgetTester tester) async {
    await tester.pumpWidget(const portfolio_main.PortfolioApp());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.light_mode), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode), findsNothing);

    await tester.tap(find.byIcon(Icons.light_mode));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    expect(find.byIcon(Icons.light_mode), findsNothing);
  });

  testWidgets('App works in light mode with floating controls', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(isDarkMode: false));
    await tester.pumpAndSettle();

    expect(find.textContaining('Arcangelo Massari'), findsAtLeastNWidgets(1));
    expect(find.textContaining('PhD Candidate'), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNWidgets(2));
    
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, equals(ThemeMode.light));
  });

  testWidgets('Floating theme toggle functionality works', (WidgetTester tester) async {
    await tester.pumpWidget(const portfolio_main.PortfolioApp());
    await tester.pumpAndSettle();

    var materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, equals(ThemeMode.dark));
    expect(find.byIcon(Icons.light_mode), findsOneWidget);

    await tester.tap(find.byIcon(Icons.light_mode));
    await tester.pumpAndSettle();

    materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, equals(ThemeMode.light));
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);

    await tester.tap(find.byIcon(Icons.dark_mode));
    await tester.pumpAndSettle();

    materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, equals(ThemeMode.dark));
    expect(find.byIcon(Icons.light_mode), findsOneWidget);
  });

  testWidgets('Language selection works from floating button', (WidgetTester tester) async {
    await tester.pumpWidget(const portfolio_main.PortfolioApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();

    expect(find.text('Select Language'), findsOneWidget);
    
    await tester.tap(find.text('Italiano'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Dottorando PhD'), findsOneWidget);
    expect(find.text('Chi Sono'), findsOneWidget);
  });

  testWidgets('English language selection works correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const portfolio_main.PortfolioApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.textContaining('PhD Candidate'), findsOneWidget);
    expect(find.text('About Me'), findsOneWidget);
  });

  testWidgets('Floating controls remain visible during scroll', (WidgetTester tester) async {
    await tester.pumpWidget(const portfolio_main.PortfolioApp());
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsNWidgets(2));
    
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsNWidgets(2));
    expect(find.byIcon(Icons.light_mode), findsOneWidget);
    expect(find.byIcon(Icons.language), findsOneWidget);
  });

  testWidgets('Contact section buttons can be tapped', (WidgetTester tester) async {
    await tester.pumpWidget(const portfolio_main.PortfolioApp());
    await tester.pumpAndSettle();

    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -1000));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.email), warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.web), warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.code), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.email), findsOneWidget);
    expect(find.byIcon(Icons.web), findsOneWidget);
    expect(find.byIcon(Icons.code), findsOneWidget);
  });

  testWidgets('View My Work button can be tapped', (WidgetTester tester) async {
    await tester.pumpWidget(const portfolio_main.PortfolioApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('View My Work'));
    await tester.pumpAndSettle();

    expect(find.text('View My Work'), findsOneWidget);
  });

  test('AppLocalizations handles unsupported locale error', () async {
    final delegate = AppLocalizations.delegate;
    
    expect(
      () async => await delegate.load(const Locale('unsupported')),
      throwsA(isA<FlutterError>()),
    );
  });

  testWidgets('Publications section is present', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.byType(PublicationsSection), findsOneWidget);
    expect(find.text('Publications'), findsOneWidget);
  });

  testWidgets('Publications section shows in Italian', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(locale: const Locale('it')));
    await tester.pumpAndSettle();

    expect(find.text('Pubblicazioni'), findsOneWidget);
  });

  testWidgets('Publications section loads content', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle(); // Wait for async operations to complete

    // Should show either loading indicator or publications content
    expect(
      find.byType(CircularProgressIndicator).evaluate().isNotEmpty ||
      find.textContaining('OpenCitations').evaluate().isNotEmpty,
      true,
    );
  });
}
