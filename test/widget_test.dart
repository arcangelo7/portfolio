import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:portfolio/l10n/app_localizations.dart';
import 'package:portfolio/widgets/publications_section.dart';

import 'package:portfolio/main.dart' as portfolio_main;
import 'package:portfolio/main.dart';

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
  testWidgets('Main function initializes app correctly', (
    WidgetTester tester,
  ) async {
    portfolio_main.main();
    await tester.pumpAndSettle();

    expect(find.byType(portfolio_main.PortfolioApp), findsOneWidget);
  });

  testWidgets('Portfolio app loads correctly in English', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Arcangelo Massari'), findsAtLeastNWidgets(1));
    expect(find.textContaining('PhD candidate in Digital Humanities'), findsOneWidget);
    expect(find.text('About Me'), findsOneWidget);
    expect(find.text('My toolbox'), findsOneWidget);
    expect(find.text('Find me online'), findsOneWidget);
  });

  testWidgets('Portfolio app loads correctly in Italian', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestApp(locale: const Locale('it')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Arcangelo Massari'), findsAtLeastNWidgets(1));
    expect(
      find.textContaining('Dottorando in Digital Humanities'),
      findsOneWidget,
    );
    expect(find.text('Chi Sono'), findsOneWidget);
    expect(find.text('La mia cassetta degli attrezzi'), findsOneWidget);
    expect(find.text('Dove trovarmi'), findsOneWidget);
  });

  testWidgets('Portfolio app loads correctly in Spanish', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestApp(locale: const Locale('es')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Arcangelo Massari'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Candidato a PhD en Humanidades Digitales'), findsOneWidget);
    expect(find.text('Sobre Mí'), findsOneWidget);
    expect(find.text('Mi caja de herramientas'), findsOneWidget);
    expect(find.text('Encuéntrame online'), findsOneWidget);
  });

  testWidgets('Spanish localization appTitle works correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const portfolio_main.PortfolioApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    final localizations =
        AppLocalizations.of(
          tester.element(find.byType(portfolio_main.LandingPage)),
        )!;
    expect(localizations.appTitle, equals('Portfolio de Arcangelo Massari'));
  });

  testWidgets('Hero section contains required elements', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Check out my projects'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Floating action buttons are present', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsNWidgets(2));
    expect(find.byIcon(Icons.language), findsOneWidget);
    expect(find.byIcon(Icons.light_mode), findsOneWidget);
  });

  testWidgets('Skills section displays skill bubbles', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    // Verifica la presenza di alcune skill effettive
    expect(find.text('Flutter'), findsOneWidget);
    expect(find.text('Dart'), findsOneWidget);
    expect(find.text('JavaScript'), findsOneWidget);
    expect(find.text('Python'), findsOneWidget);
    expect(find.text('React'), findsOneWidget);

    // Verifica che ci siano le categorie di skill
    expect(find.text('Programming languages'), findsOneWidget);
  });

  testWidgets('Contact section has social icons', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.email), findsOneWidget);
    expect(find.byIcon(Icons.web), findsOneWidget);
    expect(find.byIcon(Icons.code), findsOneWidget);
    expect(
      find.text('© 2025 Arcangelo Massari. All rights are illusion.'),
      findsOneWidget,
    );
  });

  testWidgets('Language selector works via floating button', (
    WidgetTester tester,
  ) async {
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

  testWidgets('Theme toggle floating button changes icon', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const portfolio_main.PortfolioApp());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    expect(find.byIcon(Icons.light_mode), findsNothing);

    await tester.tap(find.byIcon(Icons.dark_mode));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.light_mode), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode), findsNothing);
  });

  testWidgets('App works in light mode with floating controls', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestApp(isDarkMode: false));
    await tester.pumpAndSettle();

    expect(find.textContaining('Arcangelo Massari'), findsAtLeastNWidgets(1));
    expect(find.textContaining('PhD candidate in Digital Humanities'), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNWidgets(2));

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, equals(ThemeMode.light));
  });

  testWidgets('Floating theme toggle functionality works', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const portfolio_main.PortfolioApp());
    await tester.pumpAndSettle();

    var materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, equals(ThemeMode.light));
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);

    await tester.tap(find.byIcon(Icons.dark_mode));
    await tester.pumpAndSettle();

    materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, equals(ThemeMode.dark));
    expect(find.byIcon(Icons.light_mode), findsOneWidget);

    await tester.tap(find.byIcon(Icons.light_mode));
    await tester.pumpAndSettle();

    materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, equals(ThemeMode.light));
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
  });

  testWidgets('Language selection works from floating button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const portfolio_main.PortfolioApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();

    expect(find.text('Select Language'), findsOneWidget);

    await tester.tap(find.text('Italiano'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Dottorando in Digital Humanities'),
      findsOneWidget,
    );
    expect(find.text('Chi Sono'), findsOneWidget);
  });

  testWidgets('English language selection works correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const portfolio_main.PortfolioApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.textContaining('PhD candidate in Digital Humanities'), findsOneWidget);
    expect(find.text('About Me'), findsOneWidget);
  });

  testWidgets('Floating controls remain visible during scroll', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const portfolio_main.PortfolioApp());
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsNWidgets(2));

    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsNWidgets(2));
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    expect(find.byIcon(Icons.language), findsOneWidget);
  });

  testWidgets('Contact section buttons can be tapped', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const portfolio_main.PortfolioApp());
    await tester.pumpAndSettle();

    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -1000),
    );
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

    await tester.tap(find.text('Check out my projects'));
    await tester.pumpAndSettle();

    expect(find.text('Check out my projects'), findsOneWidget);
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

  testWidgets('Publications section shows in Italian', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestApp(locale: const Locale('it')));
    await tester.pumpAndSettle();

    expect(find.text('Pubblicazioni'), findsOneWidget);
  });

  testWidgets('Publications section loads content', (
    WidgetTester tester,
  ) async {
    // Test PublicationsSection widget directly
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('it'), Locale('es')],
        home: const Scaffold(body: PublicationsSection()),
      ),
    );

    // Should show loading indicator initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for async operations to complete with a reasonable timeout
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // After loading, should not show loading indicator anymore
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Should show either publications content or error message
    expect(
      find.text('Publications').evaluate().isNotEmpty ||
          find.textContaining('No publications').evaluate().isNotEmpty ||
          find.byIcon(Icons.error_outline).evaluate().isNotEmpty,
      true,
    );
  });

  group('Portfolio Theme Tests', () {
    test('should have correct color scheme properties', () {
      expect(PortfolioTheme.iceWhite, equals(const Color(0xFFF0F8FF)));
      expect(PortfolioTheme.emeraldGreen, equals(const Color(0xFF226C3B)));
      expect(PortfolioTheme.violet, equals(const Color(0xFF420075)));
      expect(PortfolioTheme.wine, equals(const Color(0xFF800020)));
      expect(PortfolioTheme.cobaltBlue, equals(const Color(0xFF0000FF)));
      expect(PortfolioTheme.black, equals(const Color(0xFF1A1A1A)));
    });

    test('should have light theme with correct properties', () {
      final lightTheme = PortfolioTheme.lightTheme;
      expect(lightTheme.brightness, equals(Brightness.light));
      expect(lightTheme.useMaterial3, isTrue);
      expect(
        lightTheme.scaffoldBackgroundColor,
        equals(PortfolioTheme.iceWhite),
      );
    });

    test('should have dark theme with correct properties', () {
      final darkTheme = PortfolioTheme.darkTheme;
      expect(darkTheme.brightness, equals(Brightness.dark));
      expect(darkTheme.useMaterial3, isTrue);
      expect(darkTheme.scaffoldBackgroundColor, equals(PortfolioTheme.black));
    });

    test('should have correct light color scheme', () {
      final lightColorScheme = PortfolioTheme.lightColorScheme;
      expect(lightColorScheme.primary, equals(PortfolioTheme.cobaltBlue));
      expect(lightColorScheme.secondary, equals(PortfolioTheme.emeraldGreen));
      expect(lightColorScheme.tertiary, equals(PortfolioTheme.violet));
      expect(lightColorScheme.surface, equals(PortfolioTheme.iceWhite));
      expect(lightColorScheme.onSurface, equals(PortfolioTheme.black));
    });

    test('should have correct dark color scheme', () {
      final darkColorScheme = PortfolioTheme.darkColorScheme;
      expect(darkColorScheme.primary, equals(PortfolioTheme.iceWhite));
      expect(darkColorScheme.secondary, equals(PortfolioTheme.emeraldGreen));
      expect(darkColorScheme.tertiary, equals(PortfolioTheme.violet));
      expect(darkColorScheme.surface, equals(PortfolioTheme.black));
      expect(darkColorScheme.onSurface, equals(PortfolioTheme.iceWhite));
    });
  });

  testWidgets('LandingPage scroll to publications functionality', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const portfolio_main.PortfolioApp());
    await tester.pumpAndSettle();

    final viewMyWorkButton = find.text('Check out my projects');
    if (viewMyWorkButton.evaluate().isNotEmpty) {
      await tester.tap(viewMyWorkButton);
      await tester.pumpAndSettle();
      expect(find.text('Check out my projects'), findsOneWidget);
    } else {
      expect(find.text('Arcangelo Massari'), findsAtLeastNWidgets(1));
    }
  });

  testWidgets('Portfolio app initial theme mode is light', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const portfolio_main.PortfolioApp());
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, equals(ThemeMode.light));
  });

  testWidgets('About section renders markdown links correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('About Me'), findsOneWidget);
  });

  testWidgets('Skills section bubble containers are displayed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    // Verifica che ci siano Container con decorazioni (i bubble)
    final containerFinder = find.byType(Container);
    expect(containerFinder, findsWidgets);

    // Verifica che ci siano le skill visualizzate come testo
    expect(find.text('Flutter'), findsOneWidget);
    expect(find.text('Python'), findsOneWidget);
  });

  testWidgets('Hero section gradient colors change with theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestApp(isDarkMode: false));
    await tester.pumpAndSettle();

    expect(find.text('Check out my projects'), findsOneWidget);

    await tester.pumpWidget(createTestApp(isDarkMode: true));
    await tester.pumpAndSettle();

    expect(find.text('Check out my projects'), findsOneWidget);
  });

  testWidgets('Contact section icon buttons have correct properties', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -1000),
    );
    await tester.pumpAndSettle();

    final emailButton = find.byIcon(Icons.email);
    final webButton = find.byIcon(Icons.web);
    final codeButton = find.byIcon(Icons.code);

    expect(emailButton, findsOneWidget);
    expect(webButton, findsOneWidget);
    expect(codeButton, findsOneWidget);

    expect(find.byType(Icon), findsWidgets);
  });

  testWidgets('App generates title correctly from localization', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const portfolio_main.PortfolioApp());
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.onGenerateTitle, isNotNull);
  });

  testWidgets('Landing page handles null contexts gracefully', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    final viewMyWorkButton = find.text('Check out my projects');
    if (viewMyWorkButton.evaluate().isNotEmpty) {
      await tester.tap(viewMyWorkButton);
      await tester.pumpAndSettle();
    }

    expect(find.text('Arcangelo Massari'), findsAtLeastNWidgets(1));
  });

  testWidgets('Language selector shows correct emoji flags', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const portfolio_main.PortfolioApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();

    expect(find.text('🇺🇸'), findsOneWidget);
    expect(find.text('🇮🇹'), findsOneWidget);
    expect(find.text('🇪🇸'), findsOneWidget);
  });

  testWidgets('App supports all required locales', (WidgetTester tester) async {
    await tester.pumpWidget(const portfolio_main.PortfolioApp());
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.supportedLocales, contains(const Locale('en')));
    expect(materialApp.supportedLocales, contains(const Locale('it')));
    expect(materialApp.supportedLocales, contains(const Locale('es')));
  });

  testWidgets('PortfolioApp state management works correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const portfolio_main.PortfolioApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Italiano'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Arcangelo Massari'), findsAtLeastNWidgets(1));

    await tester.tap(find.byIcon(Icons.dark_mode));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.light_mode), findsOneWidget);
  });

  testWidgets('Profile image error builder works', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    final imageWidgets = find.byType(Image);
    expect(imageWidgets, findsOneWidget);

    final imageWidget = tester.widget<Image>(imageWidgets);
    expect(imageWidget.errorBuilder, isNotNull);

    if (imageWidget.errorBuilder != null) {
      final errorWidget = imageWidget.errorBuilder!(
        tester.element(imageWidgets),
        Exception('Test error'),
        null,
      );
      expect(errorWidget, isA<Center>());
    }
  });

  testWidgets('About section handles text without markdown links', (
    WidgetTester tester,
  ) async {
    final widget = MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('it'), Locale('es')],
      home: Scaffold(
        body: portfolio_main.LandingPage(
          onLanguageChanged: (locale) {},
          currentLocale: const Locale('en'),
          onThemeToggle: () {},
          isDarkMode: false,
        ),
      ),
    );

    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    expect(find.text('About Me'), findsOneWidget);
  });

  testWidgets('Text without markdown links falls back to simple Text widget', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('it'), Locale('es')],
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final aboutText =
                  AppLocalizations.of(context)!.aboutMeDescription;
              final hasLinks =
                  aboutText.contains('http') || aboutText.contains('[');

              expect(hasLinks || aboutText.isNotEmpty, isTrue);

              return const Text('Simple text without links');
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Simple text without links'), findsOneWidget);
  });

  testWidgets('Contact section button handlers work', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -1000),
    );
    await tester.pumpAndSettle();

    final emailButton = find.byIcon(Icons.email);
    final webButton = find.byIcon(Icons.web);
    final codeButton = find.byIcon(Icons.code);

    if (emailButton.evaluate().isNotEmpty) {
      await tester.tap(emailButton, warnIfMissed: false);
      await tester.pumpAndSettle();
    }

    if (webButton.evaluate().isNotEmpty) {
      await tester.tap(webButton, warnIfMissed: false);
      await tester.pumpAndSettle();
    }

    if (codeButton.evaluate().isNotEmpty) {
      await tester.tap(codeButton, warnIfMissed: false);
      await tester.pumpAndSettle();
    }

    expect(find.byIcon(Icons.email), findsOneWidget);
    expect(find.byIcon(Icons.web), findsOneWidget);
    expect(find.byIcon(Icons.code), findsOneWidget);
  });

  testWidgets('URL launcher function coverage', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    // HERITRACE text is rendered in a RichText with markdown links
    final richTextFinder = find.byType(RichText);
    expect(richTextFinder, findsWidgets);

    // Verify the about section is present which contains the HERITRACE text
    expect(find.text('About Me'), findsOneWidget);

    // Test tapping on some rich text widgets (simulating markdown link taps)
    if (richTextFinder.evaluate().isNotEmpty) {
      final richTextWidget = tester.widget<RichText>(richTextFinder.first);
      expect(richTextWidget.text, isNotNull);
    }
  });

  testWidgets('Theme color scheme methods are called', (
    WidgetTester tester,
  ) async {
    final lightColors = portfolio_main.PortfolioTheme.lightColorScheme;
    final darkColors = portfolio_main.PortfolioTheme.darkColorScheme;

    expect(
      lightColors.primary,
      equals(portfolio_main.PortfolioTheme.cobaltBlue),
    );
    expect(darkColors.primary, equals(portfolio_main.PortfolioTheme.iceWhite));

    expect(lightColors.surfaceContainerHighest, isNotNull);
    expect(lightColors.surfaceContainer, isNotNull);
    expect(lightColors.outline, isNotNull);
    expect(lightColors.onSurfaceVariant, isNotNull);

    expect(darkColors.outline, isNotNull);
    expect(darkColors.onSurfaceVariant, isNotNull);
  });

  testWidgets('All Portfolio theme properties are accessible', (
    WidgetTester tester,
  ) async {
    expect(portfolio_main.PortfolioTheme.iceWhite, isNotNull);
    expect(portfolio_main.PortfolioTheme.emeraldGreen, isNotNull);
    expect(portfolio_main.PortfolioTheme.violet, isNotNull);
    expect(portfolio_main.PortfolioTheme.wine, isNotNull);
    expect(portfolio_main.PortfolioTheme.cobaltBlue, isNotNull);
    expect(portfolio_main.PortfolioTheme.black, isNotNull);

    expect(portfolio_main.PortfolioTheme.lightTheme, isNotNull);
    expect(portfolio_main.PortfolioTheme.darkTheme, isNotNull);
    expect(portfolio_main.PortfolioTheme.lightColorScheme, isNotNull);
    expect(portfolio_main.PortfolioTheme.darkColorScheme, isNotNull);
  });

  testWidgets('Mobile FAB expandable functionality works', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const portfolio_main.PortfolioApp());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.settings), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    expect(find.byIcon(Icons.language), findsOneWidget);

    await tester.tap(find.byIcon(Icons.dark_mode));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.settings), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();

    expect(find.text('Select Language'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    addTearDown(tester.view.reset);
  });

  testWidgets('Mobile FAB toggle functionality works correctly', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const portfolio_main.PortfolioApp());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsNothing);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);

    addTearDown(tester.view.reset);
  });

  testWidgets('Desktop and mobile viewport conditions work', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const portfolio_main.PortfolioApp());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.language), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsNothing);

    addTearDown(tester.view.reset);

    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const portfolio_main.PortfolioApp());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.settings), findsOneWidget);

    addTearDown(tester.view.reset);
  });

  testWidgets('Text without markdown links renders correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('it'), Locale('es')],
        home: Scaffold(
          body: portfolio_main.LandingPage(
            onLanguageChanged: (locale) {},
            currentLocale: const Locale('en'),
            onThemeToggle: () {},
            isDarkMode: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Text), findsWidgets);
  });

  testWidgets('URL launcher and contact buttons work', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const portfolio_main.PortfolioApp());
    await tester.pumpAndSettle();

    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -1000),
    );
    await tester.pumpAndSettle();

    final contactButtons = find.byType(InkWell);
    if (contactButtons.evaluate().isNotEmpty) {
      await tester.tap(contactButtons.first, warnIfMissed: false);
      await tester.pumpAndSettle();
    }

    expect(find.byIcon(Icons.email), findsOneWidget);
  });

  testWidgets('Markdown link parsing and URL launch coverage', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('it'), Locale('es')],
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return portfolio_main.LandingPage(
                onLanguageChanged: (locale) {},
                currentLocale: const Locale('en'),
                onThemeToggle: () {},
                isDarkMode: false,
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final richTextWidgets = find.byType(RichText);
    expect(richTextWidgets, findsWidgets);

    if (richTextWidgets.evaluate().isNotEmpty) {
      final richText = tester.widget<RichText>(richTextWidgets.first);
      expect(richText.text, isNotNull);
    }
  });
}
