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
  String get viewThesis => 'View Thesis';
  String get viewReport => 'View Report';
}

void main() {
  group('DynamicCVGeneratorService thesis venue handling', () {
    test('should create thesis publication with correct venue format', () {
      final json = {
        'key': 'TEST_THESIS',
        'data': {
          'title': 'Test Thesis',
          'itemType': 'thesis',
          'university': 'University of Bologna',
          'place': 'Bologna, Italy',
          'creators': [
            {
              'creatorType': 'author',
              'firstName': 'Thesis',
              'lastName': 'Author',
            },
          ],
        },
      };

      final publication = Publication.fromJson(json);

      expect(publication.authors, equals(['Thesis Author']));
      expect(publication.itemType, equals('thesis'));
      expect(
        publication.venue,
        equals('University of Bologna, Bologna, Italy'),
      );
      expect(
        publication.displayVenue,
        equals('University of Bologna, Bologna, Italy'),
      );
    });

    test('should get correct category display name for thesis', () {
      final mockL10n = MockLocalizations();
      final thesis = Publication(
        key: 'test',
        title: 'Test Thesis',
        authors: ['Test Author'],
        itemType: 'thesis',
        venue: 'University of Bologna, Bologna, Italy',
      );

      final displayName = thesis.getCategoryDisplayName(mockL10n);
      expect(displayName, equals('Thesis'));
    });

    test('should get correct view button text for thesis', () {
      final mockL10n = MockLocalizations();
      final thesis = Publication(
        key: 'test',
        title: 'Test Thesis',
        authors: ['Test Author'],
        itemType: 'thesis',
        venue: 'University of Bologna, Bologna, Italy',
      );

      final viewText = thesis.getViewButtonText(mockL10n);
      expect(viewText, equals('View Thesis'));
    });

    test('should display venue correctly for thesis', () {
      final thesis = Publication(
        key: 'test',
        title: 'Test Thesis',
        authors: ['Test Author'],
        itemType: 'thesis',
        venue: 'University of Bologna, Bologna, Italy',
      );

      expect(
        thesis.displayVenue,
        equals('University of Bologna, Bologna, Italy'),
      );
    });
  });
}
