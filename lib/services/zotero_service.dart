// SPDX-FileCopyrightText: 2025 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/publication.dart';

class ZoteroServiceException implements Exception {
  final String message;

  const ZoteroServiceException(this.message);

  @override
  String toString() => message;
}

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

    late final http.Response response;
    try {
      response = await http.get(
        Uri.parse('$baseUrl/groups/$groupId/items').replace(
          queryParameters: {
            'itemType':
                'journalArticle || conferencePaper || bookSection || computerProgram || presentation || thesis || report',
            'sort': 'date',
            'direction': 'desc',
            'limit': '50',
          },
        ),
        headers: {'Accept': 'application/json'},
      );
    } on http.ClientException catch (error) {
      throw ZoteroServiceException('Failed to load publications: $error');
    }

    if (response.statusCode != 200) {
      throw ZoteroServiceException(
        'Failed to load publications: ${response.statusCode}',
      );
    }

    final jsonData = json.decode(response.body) as List<dynamic>;
    final publications = jsonData
        .map((item) => Publication.fromJson(item as Map<String, dynamic>))
        .where((publication) => publication.title.isNotEmpty)
        .toList();

    _cachedPublications = publications;
    _lastFetch = DateTime.now();

    return publications;
  }

  void clearCache() {
    _cachedPublications = null;
    _lastFetch = null;
  }
}
