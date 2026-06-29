// SPDX-FileCopyrightText: 2025 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/l10n/app_localizations_en.dart';
import 'package:portfolio/models/publication.dart';

final appLocalizations = AppLocalizationsEn();

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
      final thesis = Publication(
        key: 'test',
        title: 'Test Thesis',
        authors: ['Test Author'],
        itemType: 'thesis',
        venue: 'University of Bologna, Bologna, Italy',
      );

      final displayName = thesis.getCategoryDisplayName(appLocalizations);
      expect(displayName, equals('Thesis'));
    });

    test('should get correct view button text for thesis', () {
      final thesis = Publication(
        key: 'test',
        title: 'Test Thesis',
        authors: ['Test Author'],
        itemType: 'thesis',
        venue: 'University of Bologna, Bologna, Italy',
      );

      final viewText = thesis.getViewButtonText(appLocalizations);
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
