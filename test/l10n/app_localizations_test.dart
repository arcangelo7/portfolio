import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/l10n/app_localizations.dart';
import 'package:portfolio/l10n/app_localizations_en.dart';
import 'package:portfolio/l10n/app_localizations_it.dart';
import 'package:portfolio/l10n/app_localizations_es.dart';

void main() {
  group('AppLocalizations Tests', () {
    test('should support all required locales', () {
      const supportedLocales = [
        Locale('en'),
        Locale('it'),
        Locale('es'),
      ];

      expect(AppLocalizations.supportedLocales, containsAll(supportedLocales));
    });

    test('should create correct localization instances', () {
      final enLocalizations = AppLocalizationsEn();
      final itLocalizations = AppLocalizationsIt();
      final esLocalizations = AppLocalizationsEs();

      expect(enLocalizations.localeName, equals('en'));
      expect(itLocalizations.localeName, equals('it'));
      expect(esLocalizations.localeName, equals('es'));
    });

    group('English localizations', () {
      late AppLocalizationsEn l10n;

      setUp(() {
        l10n = AppLocalizationsEn();
      });

      test('should have correct English strings', () {
        expect(l10n.appTitle, equals('Arcangelo Massari Portfolio'));
        expect(l10n.name, equals('Arcangelo Massari'));
        expect(l10n.jobTitle, equals('PhD Candidate in Digital Humanities'));
        expect(l10n.aboutMe, equals('About Me'));
        expect(l10n.skills, equals('Skills'));
        expect(l10n.getInTouch, equals('Get In Touch'));
        expect(l10n.publications, equals('Publications'));
        expect(l10n.viewMyWork, equals('Check out my projects'));
        expect(l10n.copyright, equals('© 2025 Arcangelo Massari. All rights reserved.'));
      });

      test('should have correct skill translations', () {
        expect(l10n.skillFlutter, equals('Flutter'));
        expect(l10n.skillDart, equals('Dart'));
        expect(l10n.skillJavaScript, equals('JavaScript'));
        expect(l10n.skillPython, equals('Python'));
        expect(l10n.skillUIUX, equals('UI/UX Design'));
      });

      test('should have correct category translations', () {
        expect(l10n.categoryAll, equals('All'));
        expect(l10n.categoryJournalArticle, equals('Journal Article'));
        expect(l10n.categoryConferencePaper, equals('Conference Paper'));
        expect(l10n.categoryBook, equals('Book'));
        expect(l10n.categoryBookSection, equals('Book Section'));
        expect(l10n.categorySoftware, equals('Software'));
        expect(l10n.categoryPresentation, equals('Presentation'));
        expect(l10n.categoryThesis, equals('Thesis'));
        expect(l10n.categoryReport, equals('Report'));
        expect(l10n.categoryOther, equals('Other'));
      });

      test('should have correct view button translations', () {
        expect(l10n.viewUrl, equals('View Article'));
        expect(l10n.viewPaper, equals('View Paper'));
        expect(l10n.viewBook, equals('View Book'));
        expect(l10n.viewChapter, equals('View Chapter'));
        expect(l10n.viewSoftware, equals('View Software'));
        expect(l10n.viewPresentation, equals('View Presentation'));
      });

      test('should have correct UI element translations', () {
        expect(l10n.loadingPublications, equals('Loading publications...'));
        expect(l10n.noPublications, equals('No publications available'));
        expect(l10n.noPublicationsForCategory, equals('No publications found for the selected category'));
        expect(l10n.showAllAuthors, equals('Show all authors'));
        expect(l10n.showLess, equals('Show less'));
        expect(l10n.readMore, equals('Read more'));
        expect(l10n.abstract, equals('Abstract'));
        expect(l10n.previousPage, equals('Previous page'));
        expect(l10n.nextPage, equals('Next page'));
      });

      test('should handle andMoreAuthors function correctly', () {
        expect(l10n.andMoreAuthors(1), equals('and 1 more...'));
        expect(l10n.andMoreAuthors(5), equals('and 5 more...'));
      });
    });

    group('Italian localizations', () {
      late AppLocalizationsIt l10n;

      setUp(() {
        l10n = AppLocalizationsIt();
      });

      test('should have correct Italian strings', () {
        expect(l10n.appTitle, equals('Portfolio di Arcangelo Massari'));
        expect(l10n.name, equals('Arcangelo Massari'));
        expect(l10n.jobTitle, equals('Dottorando in Digital Humanities'));
        expect(l10n.aboutMe, equals('Chi Sono'));
        expect(l10n.skills, equals('Competenze'));
        expect(l10n.getInTouch, equals('Contattami'));
        expect(l10n.publications, equals('Pubblicazioni'));
        expect(l10n.viewMyWork, equals('Dai un\'occhiata ai miei progetti'));
        expect(l10n.copyright, equals('© 2025 Arcangelo. Tutti i diritti riservati.'));
      });

      test('should have correct Italian category translations', () {
        expect(l10n.categoryAll, equals('Tutte'));
        expect(l10n.categoryJournalArticle, equals('Articolo di Rivista'));
        expect(l10n.categoryConferencePaper, equals('Paper di Conferenza'));
        expect(l10n.categoryBook, equals('Libro'));
        expect(l10n.categoryBookSection, equals('Capitolo di Libro'));
        expect(l10n.categorySoftware, equals('Software'));
        expect(l10n.categoryPresentation, equals('Presentazione'));
        expect(l10n.categoryThesis, equals('Tesi'));
        expect(l10n.categoryReport, equals('Report'));
        expect(l10n.categoryOther, equals('Altro'));
      });

      test('should handle Italian andMoreAuthors function correctly', () {
        expect(l10n.andMoreAuthors(1), equals('e altri 1...'));
        expect(l10n.andMoreAuthors(5), equals('e altri 5...'));
      });
    });

    group('Spanish localizations', () {
      late AppLocalizationsEs l10n;

      setUp(() {
        l10n = AppLocalizationsEs();
      });

      test('should have correct Spanish strings', () {
        expect(l10n.appTitle, equals('Portfolio de Arcangelo Massari'));
        expect(l10n.name, equals('Arcangelo Massari'));
        expect(l10n.jobTitle, equals('Candidato a PhD en Humanidades Digitales'));
        expect(l10n.aboutMe, equals('Sobre Mí'));
        expect(l10n.skills, equals('Habilidades'));
        expect(l10n.getInTouch, equals('Ponte en Contacto'));
        expect(l10n.publications, equals('Publicaciones'));
        expect(l10n.viewMyWork, equals('Echa un vistazo a mis proyectos'));
        expect(l10n.copyright, equals('© 2025 Arcangelo Massari. Todos los derechos reservados.'));
      });

      test('should have correct Spanish category translations', () {
        expect(l10n.categoryAll, equals('Todas'));
        expect(l10n.categoryJournalArticle, equals('Artículo de Revista'));
        expect(l10n.categoryConferencePaper, equals('Paper de Conferencia'));
        expect(l10n.categoryBook, equals('Libro'));
        expect(l10n.categoryBookSection, equals('Capítulo de Libro'));
        expect(l10n.categorySoftware, equals('Software'));
        expect(l10n.categoryPresentation, equals('Presentación'));
        expect(l10n.categoryThesis, equals('Tesis'));
        expect(l10n.categoryReport, equals('Reporte'));
        expect(l10n.categoryOther, equals('Otro'));
      });

      test('should handle Spanish andMoreAuthors function correctly', () {
        expect(l10n.andMoreAuthors(1), equals('y 1 más...'));
        expect(l10n.andMoreAuthors(5), equals('y 5 más...'));
      });
    });

    group('AppLocalizations delegate', () {
      test('should be able to load supported locales', () async {
        const delegate = AppLocalizations.delegate;
        
        final enLocalizations = await delegate.load(const Locale('en'));
        final itLocalizations = await delegate.load(const Locale('it'));
        final esLocalizations = await delegate.load(const Locale('es'));

        expect(enLocalizations, isA<AppLocalizationsEn>());
        expect(itLocalizations, isA<AppLocalizationsIt>());
        expect(esLocalizations, isA<AppLocalizationsEs>());
      });

      test('should throw error for unsupported locale', () async {
        const delegate = AppLocalizations.delegate;
        
        expect(
          () async => await delegate.load(const Locale('fr')),
          throwsA(isA<FlutterError>()),
        );
      });

      test('should check if reload is needed', () {
        const delegate = AppLocalizations.delegate;
        final oldDelegate = AppLocalizations.delegate;

        expect(delegate.shouldReload(oldDelegate), isFalse);
      });
    });
  });
}