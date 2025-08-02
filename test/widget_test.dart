import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:portfolio/l10n/app_localizations.dart';

import 'package:portfolio/main.dart';

Widget createTestApp({
  Locale locale = const Locale('en'),
  bool isDarkMode = true,
}) {
  return MaterialApp(
    locale: locale,
    theme: PortfolioTheme.lightTheme,
    darkTheme: PortfolioTheme.darkTheme,
    themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en'), Locale('it'), Locale('es')],
    home: LandingPage(
      onLanguageChanged: (locale) {},
      currentLocale: locale,
      onThemeToggle: () {},
      isDarkMode: isDarkMode,
    ),
  );
}

void main() {
  testWidgets('Portfolio app loads correctly in English', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Arcangelo'), findsOneWidget);
    expect(find.text('Developer & Designer'), findsOneWidget);
    expect(find.text('About Me'), findsOneWidget);
    expect(find.text('Skills'), findsOneWidget);
    expect(find.text('Get In Touch'), findsOneWidget);
  });

  testWidgets('Portfolio app loads correctly in Italian', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(locale: const Locale('it')));
    await tester.pumpAndSettle();

    expect(find.text('Arcangelo'), findsOneWidget);
    expect(find.text('Sviluppatore & Designer'), findsOneWidget);
    expect(find.text('Chi Sono'), findsOneWidget);
    expect(find.text('Competenze'), findsOneWidget);
    expect(find.text('Contattami'), findsOneWidget);
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
    expect(find.text('© 2025 Arcangelo. All rights reserved.'), findsOneWidget);
  });

  testWidgets('Language selector works via floating button', (WidgetTester tester) async {
    await tester.pumpWidget(const PortfolioApp());
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
    await tester.pumpWidget(const PortfolioApp());
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

    expect(find.text('Arcangelo'), findsOneWidget);
    expect(find.text('Developer & Designer'), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNWidgets(2));
    
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, equals(ThemeMode.light));
  });

  testWidgets('Floating theme toggle functionality works', (WidgetTester tester) async {
    await tester.pumpWidget(const PortfolioApp());
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
    await tester.pumpWidget(const PortfolioApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();

    expect(find.text('Select Language'), findsOneWidget);
    
    await tester.tap(find.text('Italiano'));
    await tester.pumpAndSettle();

    expect(find.text('Sviluppatore & Designer'), findsOneWidget);
    expect(find.text('Chi Sono'), findsOneWidget);
  });

  testWidgets('Floating controls remain visible during scroll', (WidgetTester tester) async {
    await tester.pumpWidget(const PortfolioApp());
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsNWidgets(2));
    
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsNWidgets(2));
    expect(find.byIcon(Icons.light_mode), findsOneWidget);
    expect(find.byIcon(Icons.language), findsOneWidget);
  });
}
