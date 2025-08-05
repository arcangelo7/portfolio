import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:portfolio/l10n/app_localizations.dart';
import 'package:portfolio/main.dart';

void main() {
  group('Portfolio App Basic Tests', () {
    testWidgets('PortfolioTheme colors are defined correctly', (WidgetTester tester) async {
      expect(PortfolioTheme.iceWhite, equals(const Color(0xFFF0F8FF)));
      expect(PortfolioTheme.emeraldGreen, equals(const Color(0xFF226C3B)));
      expect(PortfolioTheme.violet, equals(const Color(0xFF420075)));
      expect(PortfolioTheme.wine, equals(const Color(0xFF800020)));
      expect(PortfolioTheme.cobaltBlue, equals(const Color(0xFF000075)));
      expect(PortfolioTheme.black, equals(const Color(0xFF1A1A1A)));
    });

    testWidgets('Light theme has correct properties', (WidgetTester tester) async {
      final lightTheme = PortfolioTheme.lightTheme;
      expect(lightTheme.brightness, equals(Brightness.light));
      expect(lightTheme.useMaterial3, isTrue);
      expect(lightTheme.scaffoldBackgroundColor, equals(PortfolioTheme.iceWhite));
    });

    testWidgets('Dark theme has correct properties', (WidgetTester tester) async {
      final darkTheme = PortfolioTheme.darkTheme;
      expect(darkTheme.brightness, equals(Brightness.dark));
      expect(darkTheme.useMaterial3, isTrue);
      expect(darkTheme.scaffoldBackgroundColor, equals(PortfolioTheme.black));
    });

    testWidgets('AppLocalizations handles unsupported locale', (WidgetTester tester) async {
      final delegate = AppLocalizations.delegate;
      
      expect(
        () async => await delegate.load(const Locale('unsupported')),
        throwsA(isA<FlutterError>()),
      );
    });

    testWidgets('Basic MaterialApp creation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('it'), Locale('es')],
          home: const Scaffold(
            body: Center(
              child: Text('Test App'),
            ),
          ),
        ),
      );
      
      expect(find.text('Test App'), findsOneWidget);
    });
  });
}