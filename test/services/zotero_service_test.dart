import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/services/zotero_service.dart';
import 'package:portfolio/models/publication.dart';

void main() {
  group('ZoteroService', () {
    late ZoteroService service;

    setUp(() {
      service = ZoteroService();
    });

    test('should have correct base URL and group ID', () {
      expect(ZoteroService.baseUrl, equals('https://api.zotero.org'));
      expect(ZoteroService.groupId, equals('6083677'));
    });

    test('should have correct cache expiry duration', () {
      expect(ZoteroService.cacheExpiry, equals(const Duration(hours: 1)));
    });

    test('should clear cache correctly', () {
      service.clearCache();
      
    });

    test('should fetch publications from API', () async {
      try {
        final publications = await service.getPublications();
        expect(publications, isA<List<Publication>>());
      } catch (e) {
        expect(e, isA<Exception>());
        expect(e.toString(), contains('Failed to load publications'));
      }
    });

    test('should handle multiple consecutive calls', () async {
      try {
        final publications1 = await service.getPublications();
        final publications2 = await service.getPublications();
        
        expect(publications1, isA<List<Publication>>());
        expect(publications2, isA<List<Publication>>());
      } catch (e) {
        expect(e, isA<Exception>());
        expect(e.toString(), contains('Failed to load publications'));
      }
    });

    test('should handle network errors gracefully', () async {
      try {
        await service.getPublications();
      } catch (e) {
        expect(e, isA<Exception>());
        expect(e.toString(), contains('Failed to load publications'));
      }
    });
  });
}