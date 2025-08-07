import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/services/zotero_service.dart';

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
  });
}