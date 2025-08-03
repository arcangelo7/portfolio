import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/models/publication.dart';

void main() {
  group('Publication.fromJson creator type handling', () {
    test('should extract authors from computer program with programmer creator type', () {
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
    });

    test('should extract authors from presentation with presenter creator type', () {
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
      expect(publication.venue, equals('Tech Summit 2023, Conference Center, Rome'));
    });

    test('should extract authors from journal article with author creator type', () {
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
    });

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

      expect(publication.authors, equals(['First Programmer', 'Second Programmer']));
    });

    test('should return empty authors list when no matching creator type found', () {
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

      expect(publication.venue, equals('International AI Conference, Milan, Italy'));
      expect(publication.displayVenue, equals('International AI Conference, Milan, Italy'));
    });

    test('should use only meetingName when place is missing for presentations', () {
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
    });

    test('should use only place when meetingName is missing for presentations', () {
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
    });

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
      expect(publication.displayVenue, equals('International Conference on Testing'));
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

      expect(publication.venue, equals('Proceedings of the Testing Conference'));
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
  });
}