// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const personId = 'https://arcangelomassari.com/#person';
const ownNames = {'Arcangelo Massari', 'Massari, Arcangelo'};

const schemaTypes = {
  'journalArticle': 'ScholarlyArticle',
  'conferencePaper': 'ScholarlyArticle',
  'bookSection': 'Chapter',
  'thesis': 'Thesis',
  'report': 'Report',
  'computerProgram': 'SoftwareSourceCode',
  'presentation': 'PresentationDigitalDocument',
};

Future<void> main(List<String> args) async {
  final indexFile = File(args.single);
  final response = await http.get(
    Uri.https('api.zotero.org', '/groups/6083677/items', {
      'itemType': schemaTypes.keys.join(' || '),
      'sort': 'date',
      'direction': 'desc',
      'limit': '50',
    }),
  );
  if (response.statusCode != 200) {
    throw HttpException('Zotero returned ${response.statusCode}');
  }

  final items = (jsonDecode(response.body) as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .where(
        (item) => _text(item['data'] as Map<String, dynamic>, 'title') != null,
      );
  final graph = {
    '@context': 'https://schema.org',
    '@graph': items.map(_toSchemaOrg).toList(),
  };
  final script =
      '<script type="application/ld+json">'
      '${jsonEncode(graph).replaceAll('<', r'\u003c')}'
      '</script>';

  final html = indexFile.readAsStringSync();
  indexFile.writeAsStringSync(html.replaceFirst('</head>', '$script\n</head>'));
}

Map<String, Object> _toSchemaOrg(Map<String, dynamic> item) {
  final data = item['data'] as Map<String, dynamic>;
  final itemType = data['itemType'] as String;
  final doi = _text(data, 'DOI');
  final doiUrl = doi == null ? null : 'https://doi.org/$doi';

  return {
    '@type': schemaTypes[itemType]!,
    '@id': ?doiUrl,
    'name': _text(data, 'title')!,
    'author': _authors(data, itemType),
    'datePublished': ?_text(item['meta'] as Map<String, dynamic>, 'parsedDate'),
    'url': ?(_text(data, 'url') ?? doiUrl),
    if (doi != null)
      'identifier': {
        '@type': 'PropertyValue',
        'propertyID': 'DOI',
        'value': doi,
      },
    'abstract': ?_text(data, 'abstractNote'),
    'pagination': ?_text(data, 'pages'),
    ..._container(data, itemType),
  };
}

List<Map<String, String>> _authors(Map<String, dynamic> data, String itemType) {
  final creatorType = switch (itemType) {
    'computerProgram' => 'programmer',
    'presentation' => 'presenter',
    _ => 'author',
  };
  return (data['creators'] as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .where((creator) => creator['creatorType'] == creatorType)
      .map((creator) => '${creator['firstName']} ${creator['lastName']}'.trim())
      .map(
        (name) => ownNames.contains(name)
            ? {'@id': personId}
            : {'@type': 'Person', 'name': name},
      )
      .toList();
}

Map<String, Object> _container(Map<String, dynamic> data, String itemType) {
  Map<String, Object>? named(String type, String key) {
    final name = _text(data, key);
    return name == null ? null : {'@type': type, 'name': name};
  }

  return switch (itemType) {
    'journalArticle' => {'isPartOf': ?_journalIssue(data)},
    'conferencePaper' => {'isPartOf': ?named('Book', 'proceedingsTitle')},
    'bookSection' => {'isPartOf': ?named('Book', 'bookTitle')},
    'thesis' => {
      'sourceOrganization': ?named('CollegeOrUniversity', 'university'),
    },
    'report' => {'publisher': ?named('Organization', 'institution')},
    _ => {},
  };
}

Map<String, Object>? _journalIssue(Map<String, dynamic> data) {
  final journal = _text(data, 'publicationTitle');
  if (journal == null) return null;

  Map<String, Object> container = {
    '@type': 'Periodical',
    'name': journal,
    'issn': ?_text(data, 'ISSN'),
  };
  final volume = _text(data, 'volume');
  if (volume != null) {
    container = {
      '@type': 'PublicationVolume',
      'volumeNumber': volume,
      'isPartOf': container,
    };
  }
  final issue = _text(data, 'issue');
  if (issue != null) {
    container = {
      '@type': 'PublicationIssue',
      'issueNumber': issue,
      'isPartOf': container,
    };
  }
  return container;
}

String? _text(Map<String, dynamic> map, String key) {
  final value = (map[key] as String?)?.trim();
  return value == null || value.isEmpty ? null : value;
}
