import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/publication.dart';

class ZoteroService {
  static const String baseUrl = 'https://api.zotero.org';

  static const String groupId = '6083677';

  List<Publication>? _cachedPublications;
  DateTime? _lastFetch;
  static const Duration cacheExpiry = Duration(hours: 1);

  Future<List<Publication>> getPublications() async {
    if (_cachedPublications != null &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < cacheExpiry) {
      return _cachedPublications!;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/groups/$groupId/items').replace(
          queryParameters: {
            'itemType':
                'journalArticle || conferencePaper || book || bookSection || computerProgram || presentation',
            'sort': 'date',
            'direction': 'desc',
            'limit': '50',
          },
        ),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Portfolio App/1.0',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final publications =
            jsonData
                .map(
                  (item) => Publication.fromJson(item as Map<String, dynamic>),
                )
                .where((pub) => pub.title.isNotEmpty)
                .toList();

        _cachedPublications = publications;
        _lastFetch = DateTime.now();

        return publications;
      } else {
        throw Exception('Failed to load publications: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load publications: $e');
    }
  }


  void clearCache() {
    _cachedPublications = null;
    _lastFetch = null;
  }
}
