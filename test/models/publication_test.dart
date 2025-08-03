import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/models/publication.dart';

class MockLocalizations {
  String get categoryJournalArticle => 'Journal Article';
  String get categoryConferencePaper => 'Conference Paper';
  String get categoryBook => 'Book';
  String get categoryBookSection => 'Book Section';
  String get categorySoftware => 'Software';
  String get categoryPresentation => 'Presentation';
  String get categoryThesis => 'Thesis';
  String get categoryReport => 'Report';
  String get categoryOther => 'Other';
  String get viewUrl => 'View Article';
  String get viewPaper => 'View Paper';
  String get viewBook => 'View Book';
  String get viewChapter => 'View Chapter';
  String get viewSoftware => 'View Software';
  String get viewPresentation => 'View Presentation';
}

void main() {
  group('Publication.fromJson creator type handling', () {
    test(
      'should extract authors from computer program with programmer creator type',
      () {
        final json = {
          'key': 'TEST123',
          'data': {
            'title': 'Test Software',
            'itemType': 'computerProgram',
            'creators': [
              {
                'creatorType': 'programmer',
                'firstName': 'John',
                'lastName': 'Doe',
              },
              {
                'creatorType': 'author',
                'firstName': 'Jane',
                'lastName': 'Smith',
              },
            ],
          },
        };

        final publication = Publication.fromJson(json);

        expect(publication.authors, equals(['John Doe']));
        expect(publication.itemType, equals('computerProgram'));
      },
    );

    test(
      'should extract authors from presentation with presenter creator type',
      () {
        final json = {
          'key': 'TEST456',
          'data': {
            'title': 'Test Presentation',
            'itemType': 'presentation',
            'meetingName': 'Tech Summit 2023',
            'place': 'Conference Center, Rome',
            'creators': [
              {
                'creatorType': 'presenter',
                'firstName': 'Alice',
                'lastName': 'Johnson',
              },
              {
                'creatorType': 'author',
                'firstName': 'Bob',
                'lastName': 'Wilson',
              },
            ],
          },
        };

        final publication = Publication.fromJson(json);

        expect(publication.authors, equals(['Alice Johnson']));
        expect(publication.itemType, equals('presentation'));
        expect(
          publication.venue,
          equals('Tech Summit 2023, Conference Center, Rome'),
        );
      },
    );

    test(
      'should extract authors from journal article with author creator type',
      () {
        final json = {
          'key': 'TEST789',
          'data': {
            'title': 'Test Article',
            'itemType': 'journalArticle',
            'creators': [
              {
                'creatorType': 'author',
                'firstName': 'Charlie',
                'lastName': 'Brown',
              },
              {
                'creatorType': 'editor',
                'firstName': 'Dana',
                'lastName': 'White',
              },
            ],
          },
        };

        final publication = Publication.fromJson(json);

        expect(publication.authors, equals(['Charlie Brown']));
        expect(publication.itemType, equals('journalArticle'));
      },
    );

    test('should handle multiple creators of the same type', () {
      final json = {
        'key': 'TEST999',
        'data': {
          'title': 'Multi-Author Software',
          'itemType': 'computerProgram',
          'creators': [
            {
              'creatorType': 'programmer',
              'firstName': 'First',
              'lastName': 'Programmer',
            },
            {
              'creatorType': 'programmer',
              'firstName': 'Second',
              'lastName': 'Programmer',
            },
          ],
        },
      };

      final publication = Publication.fromJson(json);

      expect(
        publication.authors,
        equals(['First Programmer', 'Second Programmer']),
      );
    });

    test(
      'should return empty authors list when no matching creator type found',
      () {
        final json = {
          'key': 'TEST000',
          'data': {
            'title': 'Software with Only Authors',
            'itemType': 'computerProgram',
            'creators': [
              {
                'creatorType': 'author',
                'firstName': 'Wrong',
                'lastName': 'Type',
              },
            ],
          },
        };

        final publication = Publication.fromJson(json);

        expect(publication.authors, isEmpty);
        expect(publication.authorsString, equals('Unknown Author'));
      },
    );

    test('should handle empty or null creators list', () {
      final json = {
        'key': 'TEST_EMPTY',
        'data': {
          'title': 'Publication without creators',
          'itemType': 'journalArticle',
        },
      };

      final publication = Publication.fromJson(json);

      expect(publication.authors, isEmpty);
      expect(publication.authorsString, equals('Unknown Author'));
    });

    test('should handle creators with missing names', () {
      final json = {
        'key': 'TEST_MISSING_NAMES',
        'data': {
          'title': 'Publication with incomplete creators',
          'itemType': 'journalArticle',
          'creators': [
            {'creatorType': 'author', 'firstName': '', 'lastName': ''},
            {'creatorType': 'author', 'firstName': 'John'},
            {'creatorType': 'author', 'lastName': 'Doe'},
          ],
        },
      };

      final publication = Publication.fromJson(json);

      expect(publication.authors, equals(['John', 'Doe']));
    });
  });

  group('Publication venue extraction', () {
    test('should combine meetingName and place for presentations', () {
      final json = {
        'key': 'VENUE001',
        'data': {
          'title': 'Presentation at Conference',
          'itemType': 'presentation',
          'meetingName': 'International AI Conference',
          'place': 'Milan, Italy',
          'conferenceName': 'Should Not Use This',
          'creators': [
            {
              'creatorType': 'presenter',
              'firstName': 'Test',
              'lastName': 'Presenter',
            },
          ],
        },
      };

      final publication = Publication.fromJson(json);

      expect(
        publication.venue,
        equals('International AI Conference, Milan, Italy'),
      );
      expect(
        publication.displayVenue,
        equals('International AI Conference, Milan, Italy'),
      );
    });

    test(
      'should use only meetingName when place is missing for presentations',
      () {
        final json = {
          'key': 'VENUE001B',
          'data': {
            'title': 'Presentation without Place',
            'itemType': 'presentation',
            'meetingName': 'Virtual Conference 2023',
            'creators': [
              {
                'creatorType': 'presenter',
                'firstName': 'Test',
                'lastName': 'Presenter',
              },
            ],
          },
        };

        final publication = Publication.fromJson(json);

        expect(publication.venue, equals('Virtual Conference 2023'));
      },
    );

    test(
      'should use only place when meetingName is missing for presentations',
      () {
        final json = {
          'key': 'VENUE001C',
          'data': {
            'title': 'Presentation without Meeting Name',
            'itemType': 'presentation',
            'place': 'Rome, Italy',
            'creators': [
              {
                'creatorType': 'presenter',
                'firstName': 'Test',
                'lastName': 'Presenter',
              },
            ],
          },
        };

        final publication = Publication.fromJson(json);

        expect(publication.venue, equals('Rome, Italy'));
      },
    );

    test('should extract venue from conferenceName for conference papers', () {
      final json = {
        'key': 'VENUE002',
        'data': {
          'title': 'Conference Paper',
          'itemType': 'conferencePaper',
          'conferenceName': 'International Conference on Testing',
          'place': 'Should Not Use This',
          'creators': [
            {
              'creatorType': 'author',
              'firstName': 'Test',
              'lastName': 'Author',
            },
          ],
        },
      };

      final publication = Publication.fromJson(json);

      expect(publication.venue, equals('International Conference on Testing'));
      expect(
        publication.displayVenue,
        equals('International Conference on Testing'),
      );
    });

    test('should fallback to proceedingsTitle when conferenceName is null', () {
      final json = {
        'key': 'VENUE003',
        'data': {
          'title': 'Paper in Proceedings',
          'itemType': 'conferencePaper',
          'proceedingsTitle': 'Proceedings of the Testing Conference',
          'creators': [
            {
              'creatorType': 'author',
              'firstName': 'Test',
              'lastName': 'Author',
            },
          ],
        },
      };

      final publication = Publication.fromJson(json);

      expect(
        publication.venue,
        equals('Proceedings of the Testing Conference'),
      );
    });

    test('should return null venue for computer programs', () {
      final json = {
        'key': 'VENUE004',
        'data': {
          'title': 'Software Application',
          'itemType': 'computerProgram',
          'place': 'Should Not Use This',
          'conferenceName': 'Should Not Use This Either',
          'creators': [
            {
              'creatorType': 'programmer',
              'firstName': 'Test',
              'lastName': 'Programmer',
            },
          ],
        },
      };

      final publication = Publication.fromJson(json);

      expect(publication.venue, isNull);
      expect(publication.displayVenue, equals('Unknown Venue'));
    });

    test('should extract venue from bookTitle for book sections', () {
      final json = {
        'key': 'VENUE005',
        'data': {
          'title': 'Chapter about Testing',
          'itemType': 'bookSection',
          'bookTitle': 'Handbook of Software Testing',
          'conferenceName': 'Should Not Use This',
          'creators': [
            {
              'creatorType': 'author',
              'firstName': 'Test',
              'lastName': 'Author',
            },
          ],
        },
      };

      final publication = Publication.fromJson(json);

      expect(publication.venue, equals('Handbook of Software Testing'));
      expect(publication.displayVenue, equals('Handbook of Software Testing'));
    });

    test('should extract venue from report with institution and place', () {
      final json = {
        'key': 'VENUE006',
        'data': {
          'title': 'Technical Report',
          'itemType': 'report',
          'institution': 'University of Testing',
          'place': 'Test City',
          'creators': [
            {
              'creatorType': 'author',
              'firstName': 'Report',
              'lastName': 'Author',
            },
          ],
        },
      };

      final publication = Publication.fromJson(json);

      expect(publication.venue, equals('University of Testing, Test City'));
    });

    test('should extract venue from report with only institution', () {
      final json = {
        'key': 'VENUE007',
        'data': {
          'title': 'Technical Report Without Place',
          'itemType': 'report',
          'institution': 'University of Testing',
          'creators': [
            {
              'creatorType': 'author',
              'firstName': 'Report',
              'lastName': 'Author',
            },
          ],
        },
      };

      final publication = Publication.fromJson(json);

      expect(publication.venue, equals('University of Testing'));
    });

    test('should extract venue from report with only place', () {
      final json = {
        'key': 'VENUE008',
        'data': {
          'title': 'Technical Report Without Institution',
          'itemType': 'report',
          'place': 'Test City',
          'creators': [
            {
              'creatorType': 'author',
              'firstName': 'Report',
              'lastName': 'Author',
            },
          ],
        },
      };

      final publication = Publication.fromJson(json);

      expect(publication.venue, equals('Test City'));
    });
  });

  group('Publication authors string formatting', () {
    test('should return single author name', () {
      const publication = Publication(
        key: 'SINGLE_AUTHOR',
        title: 'Test Publication',
        authors: ['John Doe'],
        itemType: 'journalArticle',
      );

      expect(publication.authorsString, equals('John Doe'));
    });

    test('should return two authors with ampersand', () {
      const publication = Publication(
        key: 'TWO_AUTHORS',
        title: 'Test Publication',
        authors: ['John Doe', 'Jane Smith'],
        itemType: 'journalArticle',
      );

      expect(publication.authorsString, equals('John Doe & Jane Smith'));
    });

    test('should return multiple authors with commas', () {
      const publication = Publication(
        key: 'MULTI_AUTHORS',
        title: 'Test Publication',
        authors: ['John Doe', 'Jane Smith', 'Bob Wilson'],
        itemType: 'journalArticle',
      );

      expect(
        publication.authorsString,
        equals('John Doe, Jane Smith, Bob Wilson'),
      );
    });
  });

  group('Publication display methods', () {
    test('should return journal as display venue when available', () {
      const publication = Publication(
        key: 'WITH_JOURNAL',
        title: 'Test Article',
        authors: ['Author'],
        itemType: 'journalArticle',
        journal: 'Nature',
        venue: 'Some Conference',
      );

      expect(publication.displayVenue, equals('Nature'));
    });

    test('should return venue as display venue when journal is null', () {
      const publication = Publication(
        key: 'WITH_VENUE',
        title: 'Test Paper',
        authors: ['Author'],
        itemType: 'conferencePaper',
        venue: 'IEEE Conference',
      );

      expect(publication.displayVenue, equals('IEEE Conference'));
    });

    test(
      'should return Unknown Venue when both journal and venue are null',
      () {
        const publication = Publication(
          key: 'NO_VENUE',
          title: 'Test Publication',
          authors: ['Author'],
          itemType: 'journalArticle',
        );

        expect(publication.displayVenue, equals('Unknown Venue'));
      },
    );

    test('should extract year from date string', () {
      const publication = Publication(
        key: 'WITH_YEAR',
        title: 'Test Publication',
        authors: ['Author'],
        itemType: 'journalArticle',
        year: '2023-12-01',
      );

      expect(publication.displayYear, equals('2023'));
    });

    test('should return full year string when no year pattern found', () {
      const publication = Publication(
        key: 'WEIRD_YEAR',
        title: 'Test Publication',
        authors: ['Author'],
        itemType: 'journalArticle',
        year: 'sometime in the past',
      );

      expect(publication.displayYear, equals('sometime in the past'));
    });

    test('should return Unknown Year when year is null or empty', () {
      const publication = Publication(
        key: 'NO_YEAR',
        title: 'Test Publication',
        authors: ['Author'],
        itemType: 'journalArticle',
      );

      expect(publication.displayYear, equals('Unknown Year'));
    });
  });

  group('Publication category display names', () {
    late MockLocalizations mockL10n;

    setUp(() {
      mockL10n = MockLocalizations();
    });

    test('should return correct category display names', () {
      const journalArticle = Publication(
        key: 'test',
        title: 'test',
        authors: [],
        itemType: 'journalArticle',
      );
      const conferencePaper = Publication(
        key: 'test',
        title: 'test',
        authors: [],
        itemType: 'conferencePaper',
      );
      const book = Publication(
        key: 'test',
        title: 'test',
        authors: [],
        itemType: 'book',
      );
      const bookSection = Publication(
        key: 'test',
        title: 'test',
        authors: [],
        itemType: 'bookSection',
      );
      const computerProgram = Publication(
        key: 'test',
        title: 'test',
        authors: [],
        itemType: 'computerProgram',
      );
      const presentation = Publication(
        key: 'test',
        title: 'test',
        authors: [],
        itemType: 'presentation',
      );
      const thesis = Publication(
        key: 'test',
        title: 'test',
        authors: [],
        itemType: 'thesis',
      );
      const report = Publication(
        key: 'test',
        title: 'test',
        authors: [],
        itemType: 'report',
      );
      const unknown = Publication(
        key: 'test',
        title: 'test',
        authors: [],
        itemType: 'unknown',
      );

      expect(
        journalArticle.getCategoryDisplayName(mockL10n),
        equals('Journal Article'),
      );
      expect(
        conferencePaper.getCategoryDisplayName(mockL10n),
        equals('Conference Paper'),
      );
      expect(book.getCategoryDisplayName(mockL10n), equals('Book'));
      expect(
        bookSection.getCategoryDisplayName(mockL10n),
        equals('Book Section'),
      );
      expect(
        computerProgram.getCategoryDisplayName(mockL10n),
        equals('Software'),
      );
      expect(
        presentation.getCategoryDisplayName(mockL10n),
        equals('Presentation'),
      );
      expect(thesis.getCategoryDisplayName(mockL10n), equals('Thesis'));
      expect(report.getCategoryDisplayName(mockL10n), equals('Report'));
      expect(unknown.getCategoryDisplayName(mockL10n), equals('Other'));
    });
  });

  group('Publication view button text', () {
    late MockLocalizations mockL10n;

    setUp(() {
      mockL10n = MockLocalizations();
    });

    test('should return correct view button text for each item type', () {
      const journalArticle = Publication(
        key: 'test',
        title: 'test',
        authors: [],
        itemType: 'journalArticle',
      );
      const conferencePaper = Publication(
        key: 'test',
        title: 'test',
        authors: [],
        itemType: 'conferencePaper',
      );
      const book = Publication(
        key: 'test',
        title: 'test',
        authors: [],
        itemType: 'book',
      );
      const bookSection = Publication(
        key: 'test',
        title: 'test',
        authors: [],
        itemType: 'bookSection',
      );
      const computerProgram = Publication(
        key: 'test',
        title: 'test',
        authors: [],
        itemType: 'computerProgram',
      );
      const presentation = Publication(
        key: 'test',
        title: 'test',
        authors: [],
        itemType: 'presentation',
      );
      const thesis = Publication(
        key: 'test',
        title: 'test',
        authors: [],
        itemType: 'thesis',
      );
      const report = Publication(
        key: 'test',
        title: 'test',
        authors: [],
        itemType: 'report',
      );
      const unknown = Publication(
        key: 'test',
        title: 'test',
        authors: [],
        itemType: 'unknown',
      );

      expect(
        journalArticle.getViewButtonText(mockL10n),
        equals('View Article'),
      );
      expect(conferencePaper.getViewButtonText(mockL10n), equals('View Paper'));
      expect(book.getViewButtonText(mockL10n), equals('View Book'));
      expect(bookSection.getViewButtonText(mockL10n), equals('View Chapter'));
      expect(
        computerProgram.getViewButtonText(mockL10n),
        equals('View Software'),
      );
      expect(
        presentation.getViewButtonText(mockL10n),
        equals('View Presentation'),
      );
      expect(thesis.getViewButtonText(mockL10n), equals('View Article'));
      expect(report.getViewButtonText(mockL10n), equals('View Article'));
      expect(unknown.getViewButtonText(mockL10n), equals('View Article'));
    });
  });

  group('Publication citation formatting', () {
    test('should format citation with venue', () {
      const publication = Publication(
        key: 'CITATION_TEST',
        title: 'Test Publication Title',
        authors: ['John Doe', 'Jane Smith'],
        itemType: 'journalArticle',
        journal: 'Test Journal',
        year: '2023',
      );

      expect(
        publication.citation,
        equals(
          'John Doe & Jane Smith (2023). Test Publication Title. Test Journal.',
        ),
      );
    });

    test('should format citation without venue', () {
      const publication = Publication(
        key: 'CITATION_NO_VENUE',
        title: 'Test Publication Title',
        authors: ['John Doe'],
        itemType: 'computerProgram',
        year: '2023',
      );

      expect(
        publication.citation,
        equals('John Doe (2023). Test Publication Title. Unknown Venue.'),
      );
    });

    test('should format citation with unknown venue', () {
      const publication = Publication(
        key: 'CITATION_UNKNOWN_VENUE',
        title: 'Test Publication Title',
        authors: ['John Doe'],
        itemType: 'journalArticle',
        year: '2023',
      );

      expect(
        publication.citation,
        equals('John Doe (2023). Test Publication Title. Unknown Venue.'),
      );
    });

    test('should format citation fallback when no venue info', () {
      const publication = Publication(
        key: 'CITATION_FALLBACK',
        title: 'Test Publication Title',
        authors: ['John Doe'],
        itemType: 'other',
        year: '2023',
        journal: null,
        venue: null,
      );

      expect(
        publication.citation,
        equals('John Doe (2023). Test Publication Title. Unknown Venue.'),
      );
    });
  });

  group('Publication equality and hashCode', () {
    test('should be equal when keys are the same', () {
      const pub1 = Publication(
        key: 'SAME_KEY',
        title: 'Title 1',
        authors: ['Author 1'],
        itemType: 'journalArticle',
      );
      const pub2 = Publication(
        key: 'SAME_KEY',
        title: 'Title 2',
        authors: ['Author 2'],
        itemType: 'book',
      );

      expect(pub1, equals(pub2));
      expect(pub1.hashCode, equals(pub2.hashCode));
    });

    test('should not be equal when keys are different', () {
      const pub1 = Publication(
        key: 'KEY_1',
        title: 'Same Title',
        authors: ['Same Author'],
        itemType: 'journalArticle',
      );
      const pub2 = Publication(
        key: 'KEY_2',
        title: 'Same Title',
        authors: ['Same Author'],
        itemType: 'journalArticle',
      );

      expect(pub1, isNot(equals(pub2)));
      expect(pub1.hashCode, isNot(equals(pub2.hashCode)));
    });

    test('should have same identity when same object', () {
      const publication = Publication(
        key: 'TEST',
        title: 'Test',
        authors: ['Author'],
        itemType: 'journalArticle',
      );

      expect(identical(publication, publication), isTrue);
    });
  });

  group('Publication toString', () {
    test('should return citation as string representation', () {
      const publication = Publication(
        key: 'TO_STRING_TEST',
        title: 'Test Publication',
        authors: ['Author Name'],
        itemType: 'journalArticle',
        journal: 'Test Journal',
        year: '2023',
      );

      expect(publication.toString(), equals(publication.citation));
    });
  });

  group('Publication JSON parsing edge cases', () {
    test('should handle missing title', () {
      final json = {
        'key': 'NO_TITLE',
        'data': {
          'itemType': 'journalArticle',
          'creators': [
            {
              'creatorType': 'author',
              'firstName': 'Test',
              'lastName': 'Author',
            },
          ],
        },
      };

      final publication = Publication.fromJson(json);

      expect(publication.title, equals('Untitled'));
    });

    test('should handle missing itemType', () {
      final json = {
        'key': 'NO_ITEM_TYPE',
        'data': {
          'title': 'Test Publication',
          'creators': [
            {
              'creatorType': 'author',
              'firstName': 'Test',
              'lastName': 'Author',
            },
          ],
        },
      };

      final publication = Publication.fromJson(json);

      expect(publication.itemType, equals('unknown'));
    });

    test('should parse dates correctly', () {
      final json = {
        'key': 'WITH_DATES',
        'data': {
          'title': 'Test Publication',
          'itemType': 'journalArticle',
          'dateAdded': '2023-01-01T00:00:00Z',
          'dateModified': '2023-12-31T23:59:59Z',
          'creators': [
            {
              'creatorType': 'author',
              'firstName': 'Test',
              'lastName': 'Author',
            },
          ],
        },
      };

      final publication = Publication.fromJson(json);

      expect(publication.dateAdded, isNotNull);
      expect(publication.dateModified, isNotNull);
      expect(publication.dateAdded!.year, equals(2023));
      expect(publication.dateModified!.year, equals(2023));
    });

    test('should handle invalid dates', () {
      final json = {
        'key': 'INVALID_DATES',
        'data': {
          'title': 'Test Publication',
          'itemType': 'journalArticle',
          'dateAdded': 'invalid-date',
          'dateModified': 'another-invalid-date',
          'creators': [
            {
              'creatorType': 'author',
              'firstName': 'Test',
              'lastName': 'Author',
            },
          ],
        },
      };

      final publication = Publication.fromJson(json);

      expect(publication.dateAdded, isNull);
      expect(publication.dateModified, isNull);
    });
  });
}
