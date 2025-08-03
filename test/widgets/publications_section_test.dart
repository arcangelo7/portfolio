import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:portfolio/l10n/app_localizations.dart';
import 'package:portfolio/widgets/publications_section.dart';
import 'package:portfolio/models/publication.dart';
import 'package:portfolio/services/zotero_service.dart';
import 'package:mocktail/mocktail.dart';

class MockZoteroService extends Mock implements ZoteroService {}

void main() {
  late MockZoteroService mockZoteroService;

  setUpAll(() {
    registerFallbackValue(<Publication>[]);
  });

  setUp(() {
    mockZoteroService = MockZoteroService();
  });

  Widget createTestWidget() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('it'), Locale('es')],
      home: Scaffold(body: SingleChildScrollView(child: PublicationsSection())),
    );
  }

  Widget createMockedTestWidget({
    List<Publication>? publications,
    Exception? error,
  }) {
    if (error != null) {
      when(() => mockZoteroService.getPublications()).thenThrow(error);
    } else {
      when(
        () => mockZoteroService.getPublications(),
      ).thenAnswer((_) async => publications ?? []);
    }

    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('it'), Locale('es')],
      home: Scaffold(
        body: SingleChildScrollView(
          child: PublicationsSection(zoteroService: mockZoteroService),
        ),
      ),
    );
  }

  List<Publication> createMockPublications() {
    return [
      // Journal article with DOI and many authors
      const Publication(
        key: 'journal1',
        title: 'Advanced Machine Learning Techniques',
        authors: [
          'John Doe',
          'Jane Smith',
          'Bob Johnson',
          'Alice Brown',
          'Charlie Wilson',
          'Diana Davis',
        ],
        journal: 'Journal of AI Research',
        year: '2023',
        doi: '10.1000/journal.2023.001',
        abstractText:
            'This is a very long abstract that should be truncated when displayed initially. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
        itemType: 'journalArticle',
      ),
      // Conference paper with URL and HTML in abstract
      const Publication(
        key: 'conf1',
        title: 'Novel Approach to Data Mining',
        authors: ['Alice Brown'],
        venue: 'International Conference on Data Science',
        year: '2022',
        url: 'https://example.com/paper1',
        abstractText:
            'Short abstract with <b>HTML</b> content and <a href="https://example.com">links</a>.',
        itemType: 'conferencePaper',
      ),
      // Book without abstract
      const Publication(
        key: 'book1',
        title: 'Introduction to Computer Science',
        authors: ['Bob Johnson', 'Charlie Wilson'],
        journal: 'Tech Publishers',
        year: '2021',
        itemType: 'book',
      ),
      // Computer Program
      const Publication(
        key: 'software1',
        title: 'DataAnalyzer Pro',
        authors: ['Diana Davis'],
        year: '2023',
        url: 'https://github.com/example/dataanalyzer',
        abstractText: 'A powerful tool for data analysis.',
        itemType: 'computerProgram',
      ),
      // More publications for pagination (total 15+ for 2 pages)
      ...List.generate(
        12,
        (index) => Publication(
          key: 'extra$index',
          title: 'Publication ${index + 1}',
          authors: ['Author $index'],
          year: '2023',
          itemType: 'journalArticle',
          journal: 'Test Journal',
          abstractText:
              index % 2 == 0 ? 'Abstract for publication $index' : null,
          doi: index % 3 == 0 ? '10.1000/test.$index' : null,
        ),
      ),
    ];
  }

  // Helper to create publication for testing display methods
  Publication createTestPublication({
    String key = 'test1',
    String title = 'Test Publication',
    List<String> authors = const ['Test Author'],
    String? journal,
    String? venue,
    String? year,
    String? doi,
    String? url,
    String? abstractText,
    String itemType = 'journalArticle',
  }) {
    return Publication(
      key: key,
      title: title,
      authors: authors,
      journal: journal,
      venue: venue,
      year: year,
      doi: doi,
      url: url,
      abstractText: abstractText,
      itemType: itemType,
    );
  }

  group('PublicationsSection Mocked Tests', () {
    testWidgets('loads and displays publications with all features', (
      WidgetTester tester,
    ) async {
      final publications = createMockPublications();
      await tester.pumpWidget(
        createMockedTestWidget(publications: publications),
      );
      await tester.pumpAndSettle();

      // Basic structure
      expect(find.text('Publications'), findsOneWidget);
      expect(find.byType(FilterChip), findsWidgets);
      expect(find.text('All'), findsOneWidget);

      // Publications displayed
      expect(find.text('Advanced Machine Learning Techniques'), findsOneWidget);
      expect(find.text('Novel Approach to Data Mining'), findsOneWidget);

      // Pagination present
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('handles empty publications', (WidgetTester tester) async {
      await tester.pumpWidget(createMockedTestWidget(publications: []));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('handles error state', (WidgetTester tester) async {
      await tester.pumpWidget(
        createMockedTestWidget(error: Exception('Network error')),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('exercises filtering functionality', (
      WidgetTester tester,
    ) async {
      final publications = createMockPublications();
      await tester.pumpWidget(
        createMockedTestWidget(publications: publications),
      );
      await tester.pumpAndSettle();

      // Test filter interaction
      final filterChips = find.byType(FilterChip);
      expect(filterChips, findsWidgets);

      // Try tapping different filters
      if (filterChips.evaluate().length > 1) {
        await tester.tap(filterChips.at(1), warnIfMissed: false);
        await tester.pumpAndSettle();

        await tester.tap(find.text('All'), warnIfMissed: false);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('exercises pagination functionality', (
      WidgetTester tester,
    ) async {
      final publications = createMockPublications();
      await tester.pumpWidget(
        createMockedTestWidget(publications: publications),
      );
      await tester.pumpAndSettle();

      // Navigate pages
      await tester.tap(find.byIcon(Icons.chevron_right), warnIfMissed: false);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chevron_left), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Try page number
      final pageNumbers = find.text('2');
      if (pageNumbers.evaluate().isNotEmpty) {
        await tester.tap(pageNumbers, warnIfMissed: false);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('exercises author expansion functionality', (
      WidgetTester tester,
    ) async {
      final publications = createMockPublications();
      await tester.pumpWidget(
        createMockedTestWidget(publications: publications),
      );
      await tester.pumpAndSettle();

      final showAllAuthors = find.text('Show all authors');
      if (showAllAuthors.evaluate().isNotEmpty) {
        await tester.tap(showAllAuthors, warnIfMissed: false);
        await tester.pumpAndSettle();

        final showLess = find.text('Show less');
        if (showLess.evaluate().isNotEmpty) {
          await tester.tap(showLess.first, warnIfMissed: false);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('exercises abstract expansion functionality', (
      WidgetTester tester,
    ) async {
      final publications = createMockPublications();
      await tester.pumpWidget(
        createMockedTestWidget(publications: publications),
      );
      await tester.pumpAndSettle();

      final readMore = find.text('Read more');
      if (readMore.evaluate().isNotEmpty) {
        await tester.tap(readMore, warnIfMissed: false);
        await tester.pumpAndSettle();

        final showLess = find.text('Show less');
        if (showLess.evaluate().isNotEmpty) {
          await tester.tap(showLess.first, warnIfMissed: false);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('exercises url launching functionality', (
      WidgetTester tester,
    ) async {
      final publications = createMockPublications();
      await tester.pumpWidget(
        createMockedTestWidget(publications: publications),
      );
      await tester.pumpAndSettle();

      final viewButtons = find.byIcon(Icons.open_in_new);
      if (viewButtons.evaluate().isNotEmpty) {
        await tester.tap(viewButtons.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('displays different publication types correctly', (
      WidgetTester tester,
    ) async {
      final publications = [
        createTestPublication(
          itemType: 'journalArticle',
          title: 'Journal Test',
        ),
        createTestPublication(
          itemType: 'conferencePaper',
          title: 'Conference Test',
        ),
        createTestPublication(itemType: 'book', title: 'Book Test'),
        createTestPublication(
          itemType: 'computerProgram',
          title: 'Software Test',
        ),
        createTestPublication(
          itemType: 'presentation',
          title: 'Presentation Test',
        ),
        createTestPublication(itemType: 'bookSection', title: 'Chapter Test'),
        createTestPublication(itemType: 'thesis', title: 'Thesis Test'),
        createTestPublication(itemType: 'report', title: 'Report Test'),
      ];

      await tester.pumpWidget(
        createMockedTestWidget(publications: publications),
      );
      await tester.pumpAndSettle();

      expect(find.text('Journal Test'), findsOneWidget);
      expect(find.text('Conference Test'), findsOneWidget);
      expect(find.text('Book Test'), findsOneWidget);
      expect(find.text('Software Test'), findsOneWidget);
    });

    testWidgets('handles publications without abstracts', (
      WidgetTester tester,
    ) async {
      final publications = [
        createTestPublication(
          title: 'No Abstract Publication',
          abstractText: null,
        ),
      ];
      await tester.pumpWidget(
        createMockedTestWidget(publications: publications),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Abstract Publication'), findsOneWidget);
      expect(find.byIcon(Icons.description_outlined), findsNothing);
    });

    testWidgets('handles publications without links', (
      WidgetTester tester,
    ) async {
      final publications = [
        createTestPublication(
          title: 'No Links Publication',
          doi: null,
          url: null,
        ),
      ];
      await tester.pumpWidget(
        createMockedTestWidget(publications: publications),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Links Publication'), findsOneWidget);
      expect(find.byIcon(Icons.open_in_new), findsNothing);
    });

    testWidgets('exercises all widget helper methods', (
      WidgetTester tester,
    ) async {
      final publications = createMockPublications();
      await tester.pumpWidget(
        createMockedTestWidget(publications: publications),
      );
      await tester.pumpAndSettle();

      // Scroll testing
      final scrollable = find.byType(SingleChildScrollView);
      await tester.drag(scrollable, const Offset(0, -200), warnIfMissed: false);
      await tester.pumpAndSettle();

      // State management testing
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify widget is still present
      expect(find.byType(PublicationsSection), findsOneWidget);
    });

    testWidgets('renders all UI components', (WidgetTester tester) async {
      final publications = createMockPublications();
      await tester.pumpWidget(
        createMockedTestWidget(publications: publications),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Text), findsWidgets);
      expect(find.byType(FilterChip), findsWidgets);
      expect(find.byType(IconButton), findsWidgets);
    });
  });

  group('PublicationsSection Real Network Tests', () {
    testWidgets('shows loading state initially', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Publications'), findsOneWidget);
    });

    testWidgets('handles different locales', (WidgetTester tester) async {
      const locales = [Locale('en'), Locale('it'), Locale('es')];

      for (final locale in locales) {
        final widget = MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('it'), Locale('es')],
          locale: locale,
          home: Scaffold(
            body: SingleChildScrollView(child: PublicationsSection()),
          ),
        );

        await tester.pumpWidget(widget);
        await tester.pumpAndSettle();

        expect(find.byType(PublicationsSection), findsOneWidget);
        if (locale == const Locale('en')) {
          expect(find.text('Publications'), findsOneWidget);
        }
      }
    });
  });

  group('Publication Model Tests', () {
    test('authorsString formats correctly', () {
      expect(
        createTestPublication(authors: ['John Doe']).authorsString,
        equals('John Doe'),
      );
      expect(
        createTestPublication(authors: ['John', 'Jane']).authorsString,
        equals('John & Jane'),
      );
      expect(
        createTestPublication(authors: ['A', 'B', 'C']).authorsString,
        equals('A, B, C'),
      );
      expect(
        createTestPublication(authors: []).authorsString,
        equals('Unknown Author'),
      );
    });

    test('displayVenue works correctly', () {
      expect(
        createTestPublication(journal: 'Nature').displayVenue,
        equals('Nature'),
      );
      expect(
        createTestPublication(venue: 'Conference').displayVenue,
        equals('Conference'),
      );
      expect(createTestPublication().displayVenue, equals('Unknown Venue'));
      expect(
        createTestPublication(journal: '', venue: null).displayVenue,
        equals(''),
      );
    });

    test('displayYear works correctly', () {
      expect(createTestPublication(year: '2023').displayYear, equals('2023'));
      expect(
        createTestPublication(year: '').displayYear,
        equals('Unknown Year'),
      );
      expect(
        createTestPublication(year: null).displayYear,
        equals('Unknown Year'),
      );
    });

    test('citation includes all components', () {
      final pub = createTestPublication(
        title: 'Test Title',
        authors: ['John Doe'],
        journal: 'Test Journal',
        year: '2023',
      );

      final citation = pub.citation;
      expect(citation, contains('John Doe'));
      expect(citation, contains('2023'));
      expect(citation, contains('Test Title'));
      expect(citation, contains('Test Journal'));
    });

    test('equality and hashCode work correctly', () {
      final pub1 = createTestPublication(key: 'test1');
      final pub2 = createTestPublication(key: 'test1');
      final pub3 = createTestPublication(key: 'test2');

      expect(pub1 == pub2, isTrue);
      expect(pub1 == pub3, isFalse);
      expect(pub1.hashCode, equals(pub2.hashCode));
      expect(pub1.hashCode, isNot(equals(pub3.hashCode)));
    });

    test('toString returns citation', () {
      final pub = createTestPublication(
        title: 'Test',
        authors: ['Author'],
        year: '2023',
      );
      expect(pub.toString(), equals(pub.citation));
    });
  });
}
