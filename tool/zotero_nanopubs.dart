// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';

const zoteroGroup = '6083677';
const orcid = 'https://orcid.org/0000-0002-8420-0696';
const name = 'Arcangelo Massari';
final jar = '${Platform.environment['HOME']}/.local/share/nanopub/nanopub.jar';
const registries = {
  'test': ['-u', 'https://test.registry.knowledgepixels.com/'],
  'live': <String>[],
};

const articleTemplate =
    'https://w3id.org/np/RA6NErVvGFJ1AflK02qqnB4jiQeF2EHl7mlbA7kp0d-lk';
const presentationTemplate =
    'https://w3id.org/np/RAzoLHv8ylucz6QrRhr7EcCcvCQSlWnCwdTpqqmfLV5Ec';
const softwareTemplate =
    'https://w3id.org/np/RApD2dPXssVDtmR7x4mqhqxf0B7GACteNRKPobntQyGXc';
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
const softwarePublishers = {
  'arcangelo7': orcid,
  'opencitations': 'https://opencitations.net/',
};
const presentation = 'sub:presentation';

typedef Draft = ({
  String key,
  String assertion,
  String label,
  String? introduces,
  String? nanopubType,
  String template,
  List<String> sources,
  Map<String, String> agentNames,
});

Future<void> main(List<String> args) async {
  final network = args.single;
  final stateFile = File('tool/nanopubs/$network.json');
  final state = stateFile.existsSync()
      ? (jsonDecode(stateFile.readAsStringSync()) as Map<String, dynamic>)
      : <String, dynamic>{};
  final drafts = [
    for (final item in await _zoteroItems(articleTypes.keys))
      if (_text(item['data'] as Map<String, dynamic>, 'DOI') != null)
        await _article(item),
    for (final item in await _zoteroItems(['presentation']))
      if (_extra(item['data'] as Map<String, dynamic>, 'Start') != null)
        await _presentation(item),
    for (final item in await _zoteroItems(['computerProgram']))
      if (_text(item['data'] as Map<String, dynamic>, 'DOI') != null)
        await _software(item),
  ];

  final changed = <Draft>[];
  for (final draft in drafts) {
    final previous = state[draft.key] as Map<String, dynamic>?;
    if (previous?['assertion'] == draft.assertion) {
      stdout.writeln('Unchanged: ${draft.key}');
    } else {
      changed.add(draft);
    }
  }
  if (changed.isEmpty) return;

  final workDir = Directory.systemTemp.createTempSync('nanopubs');
  final unsigned = [
    for (final (index, draft) in changed.indexed)
      File('${workDir.path}/$index.trig')..writeAsStringSync(
        _nanopub(draft, state[draft.key] as Map<String, dynamic>?),
      ),
  ];
  final signed = [
    for (final (index, _) in changed.indexed)
      File('${workDir.path}/signed.$index.trig'),
  ];
  await _java(['check', ...unsigned.map((file) => file.path)]);
  await _java(['sign', ...unsigned.map((file) => file.path)]);
  final publish = await Process.run('java', [
    '-jar',
    jar,
    'publish',
    '-v',
    ...registries[network]!,
    ...signed.map((file) => file.path),
  ]);

  final published = RegExp(
    r'^Published: \S*(RA[\w-]{43})',
    multiLine: true,
  ).allMatches(publish.stderr as String).map((match) => match[1]).toSet();
  for (final (index, draft) in changed.indexed) {
    final uri = RegExp(r'@prefix this: <([^>]+)>')
        .firstMatch(signed[index].readAsStringSync())![1]!;
    if (!published.contains(uri.split('/').last)) continue;
    final resource =
        (state[draft.key] as Map<String, dynamic>?)?['resource'] as String?;
    state[draft.key] = {
      'nanopub': uri,
      'assertion': draft.assertion,
      if (draft.introduces == presentation)
        'resource': resource ?? '$uri/presentation',
    };
    stdout.writeln('Published: ${draft.key} -> $uri');
  }
  stateFile
    ..createSync(recursive: true)
    ..writeAsStringSync(const JsonEncoder.withIndent('  ').convert(state));
  workDir.deleteSync(recursive: true);
  if (publish.exitCode != 0) {
    throw ProcessException('java', ['publish'], '${publish.stderr}');
  }
}

Future<List<Map<String, dynamic>>> _zoteroItems(Iterable<String> types) async {
  final items = await _getJson(
    Uri.https('api.zotero.org', '/groups/$zoteroGroup/items', {
      'itemType': types.join(' || '),
      'limit': '100',
    }),
  ) as List<dynamic>;
  return items.cast<Map<String, dynamic>>();
}

Future<Draft> _article(Map<String, dynamic> item) async {
  final data = item['data'] as Map<String, dynamic>;
  final doi = 'https://doi.org/${data['DOI']}';
  final work = await _getJson(
    Uri.https('api.openalex.org', '/works/doi:${data['DOI']}'),
  ) as Map<String, dynamic>;
  final itemType = data['itemType'] as String;
  final issn = work['primary_location']['source']['issn_l'] as String;
  final journal = '<http://id.crossref.org/issn/$issn>';
  final pages = _text(data, 'pages')?.split('-');
  final authorships = (work['authorships'] as List<dynamic>)
      .cast<Map<String, dynamic>>();
  final authors = _creators(data, 'author');
  if (authors.length != authorships.length) {
    throw StateError('$doi: Zotero and OpenAlex list different authors');
  }
  final organizations = <String, String>{};
  final lines = <String>[
    '<$doi> a fabio:${articleTypes[itemType]} ;',
    '    dct:title ${_literal(data['title'] as String)} ;',
    '    dct:date "${item['meta']['parsedDate']}" ;',
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
    lines
      ..add('sub:author-list rdf:_${index + 1} $iri .')
      ..add('$iri foaf:name ${_literal(authors[index])} .');
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
  return (
    key: doi,
    assertion: lines.join('\n  '),
    label: data['title'] as String,
    introduces: '<$doi>',
    nanopubType: 'fabio:ScholarlyWork',
    template: articleTemplate,
    sources: [_zoteroUrl(item), work['id'] as String],
    agentNames: const <String, String>{},
  );
}

Future<Draft> _presentation(Map<String, dynamic> item) async {
  final data = item['data'] as Map<String, dynamic>;
  final doi = RegExp(r'10\.\d+/\S+')
      .firstMatch('${data['DOI']} ${data['url']}')![0]!;
  final record = await _getJson(
    Uri.https('api.datacite.org', '/dois/$doi'),
  ) as Map<String, dynamic>;
  final creators = (record['data']['attributes']['creators'] as List<dynamic>)
      .cast<Map<String, dynamic>>();
  final presenters = _creators(data, 'presenter');
  if (presenters.length != creators.length) {
    throw StateError('$doi: Zotero and DataCite list different presenters');
  }
  final end = _extra(data, 'End');
  final agentNames = <String, String>{};
  final lines = <String>[
    '$presentation a wd:Q604733 ;',
    '    rdfs:label ${_literal(data['title'] as String)} ;',
    '    sdo:startDate "${_extra(data, 'Start')}"^^xsd:dateTime ;',
    if (end != null) '    sdo:endDate "$end"^^xsd:dateTime ;',
    if (_text(data, 'place') case final place?)
      '    sdo:location ${_literal(place)} ;',
    if (_text(data, 'abstractNote') case final abstract?)
      '    dct:description ${_literal(abstract)} ;',
    '    rdfs:seeAlso <${data['url']}> .',
  ];
  for (final (index, creator) in creators.indexed) {
    final identifier =
        (creator['nameIdentifiers'] as List<dynamic>).first['nameIdentifier']
            as String;
    final iri = _orcidIri(identifier);
    lines.add('$presentation wd:P823 <$iri> .');
    agentNames[iri] = presenters[index];
  }
  return (
    key: 'https://doi.org/$doi',
    assertion: lines.join('\n  '),
    label: data['title'] as String,
    introduces: presentation,
    nanopubType: null,
    template: presentationTemplate,
    sources: [_zoteroUrl(item), 'https://doi.org/$doi'],
    agentNames: agentNames,
  );
}

Future<Draft> _software(Map<String, dynamic> item) async {
  final data = item['data'] as Map<String, dynamic>;
  final doi = 'https://doi.org/${data['DOI']}';
  final url = data['url'] as String;
  final repository = Uri.parse(url);
  final orcids = {name: orcid, ...await _citationOrcids(repository)};
  final agentNames = <String, String>{};
  final github = await _getJson(
    Uri.https('api.github.com', '/repos${repository.path}'),
  ) as Map<String, dynamic>;
  final lines = <String>[
    '<$doi> a dcmitype:Software ;',
    '    dct:title ${_literal(data['title'] as String)} ;',
    '    dct:publisher <${softwarePublishers[repository.pathSegments.first]!}> ;',
    '    sosa:isHostedBy <${repository.origin}/> ;',
    '    dct:license <https://spdx.org/licenses/${data['rights']}> ;',
    if (_text(data, 'programmingLanguage') case final language?)
      '    <https://w3id.org/np/RA2v1C5z6oymMYKLs04ya7jUTNHcGBYA3j0IGZji0-j2E> ${_literal(language)} ;',
    if (_text(github, 'description') case final description?)
      '    dct:description ${_literal(description)} ;',
    '    <https://w3id.org/np/RA_KFwzv06xqCE16OvGjmlQpR-ExXVoT1xNxlPXjZQ8p0> <$url> .',
  ];
  for (final developer in _creators(data, 'programmer')) {
    if (orcids[developer] case final iri?) {
      lines.add('<$doi> dct:creator <$iri> .');
      agentNames[iri] = developer;
    } else {
      lines.add('<$doi> dct:creator ${_literal(developer)} .');
    }
  }
  return (
    key: doi,
    assertion: lines.join('\n  '),
    label: data['title'] as String,
    introduces: null,
    nanopubType: 'dcmitype:Software',
    template: softwareTemplate,
    sources: [_zoteroUrl(item), url],
    agentNames: agentNames,
  );
}

String _nanopub(Draft draft, Map<String, dynamic>? previous) {
  final resource = previous?['resource'] as String?;
  final supersedes = previous?['nanopub'] as String?;
  final created = DateTime.now().toUtc().toIso8601String();
  final assertion = resource == null
      ? draft.assertion
      : draft.assertion.replaceAll(presentation, '<$resource>');
  final introduces = draft.introduces == presentation && resource != null
      ? '<$resource>'
      : draft.introduces;
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
@prefix sdo: <https://schema.org/> .
@prefix fabio: <http://purl.org/spar/fabio/> .
@prefix bibo: <http://purl.org/ontology/bibo/> .
@prefix wd: <http://www.wikidata.org/entity/> .
@prefix sosa: <http://www.w3.org/ns/sosa/> .
@prefix dcmitype: <http://purl.org/dc/dcmitype/> .

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
    prov:wasDerivedFrom ${draft.sources.map((source) => '<$source>').join(', ')} .
}

sub:pubinfo {
  this: dct:created "$created"^^xsd:dateTime ;
    dct:creator <$orcid> ;
    dct:license <https://creativecommons.org/publicdomain/zero/1.0/> ;
    rdfs:label ${_literal(draft.label)} ;
    ${introduces == null ? '' : 'npx:introduces $introduces ;'}
    ${draft.nanopubType == null ? '' : 'npx:hasNanopubType ${draft.nanopubType} ;'}
    ${supersedes == null ? '' : 'npx:supersedes <$supersedes> ;'}
    nt:wasCreatedFromTemplate <${draft.template}> ;
    nt:wasCreatedFromProvenanceTemplate <$provenanceTemplate> ;
    nt:wasCreatedFromPubinfoTemplate <$licenseTemplate>, <$creatorTemplate>${supersedes == null ? '' : ', <$supersedesTemplate>'} .
${{...draft.agentNames, orcid: name}.entries.map((agent) => '  <${agent.key}> foaf:name ${_literal(agent.value)} .').join('\n')}
}
''';
}

List<String> _creators(Map<String, dynamic> data, String creatorType) =>
    (data['creators'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .where((creator) => creator['creatorType'] == creatorType)
        .map((creator) => '${creator['firstName']} ${creator['lastName']}')
        .toList();

String _orcidIri(String identifier) => identifier.startsWith('https://')
    ? identifier
    : 'https://orcid.org/$identifier';

String _zoteroUrl(Map<String, dynamic> item) =>
    'https://www.zotero.org/groups/$zoteroGroup/items/${item['key']}';

String? _extra(Map<String, dynamic> data, String field) => RegExp(
  '^$field: (.+)\$',
  multiLine: true,
).firstMatch(data['extra'] as String)?[1];

String _literal(String value) => jsonEncode(value);

String? _text(Map<String, dynamic> map, String key) {
  final value = (map[key] as String?)?.trim();
  return value == null || value.isEmpty ? null : value;
}

Future<Map<String, String>> _citationOrcids(Uri repository) async {
  final response = await http.get(
    Uri.https(
      'raw.githubusercontent.com',
      '${repository.path}/HEAD/CITATION.cff',
    ),
  );
  if (response.statusCode == 404) return {};
  if (response.statusCode != 200) {
    throw HttpException(
      '${response.request!.url} returned ${response.statusCode}',
    );
  }
  final citation = loadYaml(response.body) as YamlMap;
  final people = [
    ...citation['authors'] as YamlList,
    ...?(citation['preferred-citation'] as YamlMap?)?['authors'] as YamlList?,
  ].cast<YamlMap>();
  return {
    for (final person in people)
      if (person['orcid'] case final String identifier)
        '${person['given-names']} ${person['family-names']}': _orcidIri(
          identifier,
        ),
  };
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
