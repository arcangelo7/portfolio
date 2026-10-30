// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const zoteroGroup = '6083677';
const orcid = 'https://orcid.org/0000-0002-8420-0696';
const name = 'Arcangelo Massari';
final jar = '${Platform.environment['HOME']}/.local/share/nanopub/nanopub.jar';
const registries = {
  'test': ['-u', 'https://test.registry.knowledgepixels.com/'],
  'live': <String>[],
};

const assertionTemplate =
    'https://w3id.org/np/RA6NErVvGFJ1AflK02qqnB4jiQeF2EHl7mlbA7kp0d-lk';
const provenanceTemplate =
    'http://purl.org/np/RAGXx_k9eQMnXaCbsXMsJbGClwZtQEGNg0GVJu6amdAVw';
const licenseTemplate =
    'https://w3id.org/np/RACJ58Gvyn91LqCKIO9zu1eijDQIeEff28iyDrJgjSJF8';
const supersedesTemplate =
    'https://w3id.org/np/RAoTD7udB2KtUuOuAe74tJi1t3VzK0DyWS7rYVAq1GRvw';
const creatorTemplate =
    'https://w3id.org/np/RAukAcWHRDlkqxk7H2XNSegc1WnHI569INvNr-xdptDGI';

const articleTypes = {
  'journalArticle': 'Article',
  'bookSection': 'BookChapter',
  'conferencePaper': 'ConferencePaper',
};
const containerFields = {
  'journalArticle': 'publicationTitle',
  'bookSection': 'series',
  'conferencePaper': 'series',
};

Future<void> main(List<String> args) async {
  final network = args.single;
  final stateFile = File('tool/nanopubs/$network.json');
  final state = stateFile.existsSync()
      ? (jsonDecode(stateFile.readAsStringSync()) as Map<String, dynamic>)
      : <String, dynamic>{};
  final workDir = Directory.systemTemp.createTempSync('nanopubs');

  for (final item in await _zoteroArticles()) {
    final data = item['data'] as Map<String, dynamic>;
    final doi = 'https://doi.org/${data['DOI']}';
    final work = await _getJson(
      Uri.https('api.openalex.org', '/works/doi:${data['DOI']}'),
    ) as Map<String, dynamic>;
    final assertion = _assertion(
      doi,
      data,
      item['meta']['parsedDate'] as String,
      work,
    );
    final previous = state[doi] as Map<String, dynamic>?;
    if (previous?['assertion'] == assertion) {
      stdout.writeln('Unchanged: $doi');
      continue;
    }

    final unsigned = File('${workDir.path}/np.trig')
      ..writeAsStringSync(
        _nanopub(assertion, doi, data['title'] as String, [
          'https://www.zotero.org/groups/$zoteroGroup/items/${item['key']}',
          work['id'] as String,
        ], previous?['nanopub'] as String?),
      );
    final signed = File('${workDir.path}/np-signed.trig');
    await _java(['check', unsigned.path]);
    await _java(['sign', '-o', signed.path, unsigned.path]);
    await _java(['publish', ...registries[network]!, signed.path]);

    final uri = RegExp(r'@prefix this: <([^>]+)>')
        .firstMatch(signed.readAsStringSync())![1]!;
    state[doi] = {'nanopub': uri, 'assertion': assertion};
    stateFile
      ..createSync(recursive: true)
      ..writeAsStringSync(const JsonEncoder.withIndent('  ').convert(state));
    stdout.writeln('Published: $doi -> $uri');
  }
  workDir.deleteSync(recursive: true);
}

Future<List<Map<String, dynamic>>> _zoteroArticles() async {
  final items = await _getJson(
    Uri.https('api.zotero.org', '/groups/$zoteroGroup/items', {
      'itemType': articleTypes.keys.join(' || '),
      'limit': '100',
    }),
  ) as List<dynamic>;
  return items
      .cast<Map<String, dynamic>>()
      .where(
        (item) => _text(item['data'] as Map<String, dynamic>, 'DOI') != null,
      )
      .toList();
}

String _assertion(
  String doi,
  Map<String, dynamic> data,
  String date,
  Map<String, dynamic> work,
) {
  final itemType = data['itemType'] as String;
  final issn = work['primary_location']['source']['issn_l'] as String;
  final journal = '<http://id.crossref.org/issn/$issn>';
  final pages = _text(data, 'pages')?.split('-');
  final authorships = (work['authorships'] as List<dynamic>)
      .cast<Map<String, dynamic>>();
  final authors = (data['creators'] as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .where((creator) => creator['creatorType'] == 'author')
      .toList();
  if (authors.length != authorships.length) {
    throw StateError('$doi: Zotero and OpenAlex list different authors');
  }
  final organizations = <String, String>{};
  final lines = <String>[
    '<$doi> a fabio:${articleTypes[itemType]} ;',
    '    dct:title ${_literal(data['title'] as String)} ;',
    '    dct:date "$date" ;',
    '    dct:isPartOf $journal ;',
    for (final (predicate, value) in [
      ('volume', _text(data, 'volume')),
      ('issue', _text(data, 'issue')),
      ('pageStart', pages?.first),
      ('pageEnd', pages != null && pages.length == 2 ? pages.last : null),
    ])
      if (value != null) '    bibo:$predicate ${_literal(value)} ;',
    '    bibo:authorList sub:author-list .',
    '$journal dct:title ${_literal(_text(data, containerFields[itemType]!)!)} .',
  ];

  for (final (index, authorship) in authorships.indexed) {
    final author = authorship['author'] as Map<String, dynamic>;
    final id = author['orcid'] ?? author['id'];
    final iri = id == null ? 'sub:author-${index + 1}' : '<$id>';
    final authorName =
        '${authors[index]['firstName']} ${authors[index]['lastName']}';
    lines
      ..add('sub:author-list rdf:_${index + 1} $iri .')
      ..add('$iri foaf:name ${_literal(authorName)} .');
    for (final institution
        in (authorship['institutions'] as List<dynamic>)
            .cast<Map<String, dynamic>>()) {
      organizations[institution['ror'] as String] =
          institution['display_name'] as String;
      lines.add('$iri schema:affiliation <${institution['ror']}> .');
    }
  }
  for (final MapEntry(key: ror, value: label) in organizations.entries) {
    lines.add('<$ror> foaf:name ${_literal(label)} .');
  }
  return lines.join('\n  ');
}

String _nanopub(
  String assertion,
  String doi,
  String title,
  List<String> sources,
  String? supersedes,
) {
  final created = DateTime.now().toUtc().toIso8601String();
  return '''
@prefix this: <http://purl.org/nanopub/temp/np001/> .
@prefix sub: <http://purl.org/nanopub/temp/np001/> .
@prefix np: <http://www.nanopub.org/nschema#> .
@prefix npx: <http://purl.org/nanopub/x/> .
@prefix nt: <https://w3id.org/np/o/ntemplate/> .
@prefix dct: <http://purl.org/dc/terms/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix prov: <http://www.w3.org/ns/prov#> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
@prefix schema: <http://schema.org/> .
@prefix fabio: <http://purl.org/spar/fabio/> .
@prefix bibo: <http://purl.org/ontology/bibo/> .

sub:Head {
  this: a np:Nanopublication ;
    np:hasAssertion sub:assertion ;
    np:hasProvenance sub:provenance ;
    np:hasPublicationInfo sub:pubinfo .
}

sub:assertion {
  $assertion
}

sub:provenance {
  sub:assertion prov:wasAttributedTo <$orcid> ;
    prov:wasDerivedFrom ${sources.map((source) => '<$source>').join(', ')} .
}

sub:pubinfo {
  this: dct:created "$created"^^xsd:dateTime ;
    dct:creator <$orcid> ;
    dct:license <https://creativecommons.org/publicdomain/zero/1.0/> ;
    rdfs:label ${_literal(title)} ;
    npx:introduces <$doi> ;
    npx:hasNanopubType fabio:ScholarlyWork ;
    ${supersedes == null ? '' : 'npx:supersedes <$supersedes> ;'}
    nt:wasCreatedFromTemplate <$assertionTemplate> ;
    nt:wasCreatedFromProvenanceTemplate <$provenanceTemplate> ;
    nt:wasCreatedFromPubinfoTemplate <$licenseTemplate>, <$creatorTemplate>${supersedes == null ? '' : ', <$supersedesTemplate>'} .
  <$orcid> foaf:name "$name" .
}
''';
}

String _literal(String value) => jsonEncode(value);

String? _text(Map<String, dynamic> map, String key) {
  final value = (map[key] as String?)?.trim();
  return value == null || value.isEmpty ? null : value;
}

Future<dynamic> _getJson(Uri uri) async {
  final response = await http.get(uri);
  if (response.statusCode != 200) {
    throw HttpException('$uri returned ${response.statusCode}');
  }
  return jsonDecode(response.body);
}

Future<void> _java(List<String> args) async {
  final result = await Process.run('java', ['-jar', jar, ...args]);
  if (result.exitCode != 0) {
    throw ProcessException('java', args, '${result.stdout}${result.stderr}');
  }
}
