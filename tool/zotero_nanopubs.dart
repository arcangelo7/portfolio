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

const workTemplate =
    'https://w3id.org/np/RAL07AhiliV7p9d-766rTjSv5-3gW7eTcLftiYdzscel4';
const provenanceTemplate =
    'http://purl.org/np/RAGXx_k9eQMnXaCbsXMsJbGClwZtQEGNg0GVJu6amdAVw';
const licenseTemplate =
    'https://w3id.org/np/RACJ58Gvyn91LqCKIO9zu1eijDQIeEff28iyDrJgjSJF8';
const supersedesTemplate =
    'https://w3id.org/np/RAoTD7udB2KtUuOuAe74tJi1t3VzK0DyWS7rYVAq1GRvw';
const creatorTemplate =
    'https://w3id.org/np/RAukAcWHRDlkqxk7H2XNSegc1WnHI569INvNr-xdptDGI';

const workTypes = {
  'journalArticle': 'JournalArticle',
  'bookSection': 'BookChapter',
  'conferencePaper': 'ProceedingsPaper',
  'presentation': 'Presentation',
  'computerProgram': 'ComputerProgram',
};
const authorCreatorTypes = {
  'presentation': 'presenter',
  'computerProgram': 'programmer',
};
const dateDatatypes = {10: 'date', 7: 'gYearMonth', 4: 'gYear'};
const workNode = 'sub:br';

typedef Agent = ({String? givenName, String? familyName, String? name});
typedef Sourced = ({String value, String? source});
typedef Identifier = ({String scheme, String value});
typedef Container = ({
  String id,
  String type,
  String? title,
  String? number,
  List<Identifier> identifiers,
  List<Agent> editors,
});
typedef Work = ({
  String key,
  String type,
  String title,
  String? date,
  List<Identifier> identifiers,
  List<Agent> authors,
  List<Container> containers,
  String? pages,
  Map<String, Sourced> orcids,
  Map<String, Sourced> agentOmids,
  List<String> sources,
});
typedef Draft = ({
  String key,
  String assertion,
  String label,
  List<String> sources,
});

Future<void> main(List<String> args) async {
  final network = args.single;
  final stateFile = File('tool/nanopubs/$network.json');
  final state = stateFile.existsSync()
      ? (jsonDecode(stateFile.readAsStringSync()) as Map<String, dynamic>)
      : <String, dynamic>{};
  final works = [
    for (final item in await _zoteroItems(workTypes.keys)) await _work(item),
  ];
  final orcids = {for (final work in works) ...work.orcids};
  final agentOmids = {for (final work in works) ...work.agentOmids};
  final drafts = <Draft>[];
  for (final work in works) {
    final (:assertion, :sources) = _assertion(
      work,
      {...orcids, ...work.orcids, name: (value: orcid, source: null)},
      {...agentOmids, ...work.agentOmids},
    );
    drafts.add((
      key: work.key,
      assertion: assertion,
      label: work.title,
      sources: {...work.sources, ...sources}.toList(),
    ));
  }

  final changed = <Draft>[];
  for (final draft in drafts) {
    final previous = state[draft.key] as Map<String, dynamic>?;
    if (previous?['assertion'] == draft.assertion &&
        jsonEncode(previous?['sources']) == jsonEncode(draft.sources)) {
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
    final resource = _resource(state[draft.key] as Map<String, dynamic>?);
    state[draft.key] = {
      'nanopub': uri,
      'assertion': draft.assertion,
      'sources': draft.sources,
      'resource': resource ?? '$uri/br',
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

Future<Work> _work(Map<String, dynamic> item) async {
  final data = item['data'] as Map<String, dynamic>;
  final itemType = data['itemType'] as String;
  final url = data['url'] as String;
  final doi = RegExp(r'10\.\d+/\S+').firstMatch('${data['DOI']} $url')?[0];
  final authors = _agents(data, authorCreatorTypes[itemType] ?? 'author');
  final scholarly = !authorCreatorTypes.containsKey(itemType);
  final journal = itemType == 'journalArticle';
  final meta = doi == null ? null : await _metaRecord(doi);
  final metaIri = meta == null
      ? null
      : 'https://w3id.org/oc/meta/${_omids(meta['id'] as String).single}';
  final metaOrcids = meta == null
      ? List<String?>.filled(authors.length, null)
      : _metaOrcids(meta, authors);
  final metaIssns = meta == null ? const <String>[] : _metaIssns(meta);
  final openAlex =
      scholarly &&
          doi != null &&
          (metaOrcids.contains(null) || (journal && metaIssns.isEmpty))
      ? await _getJson(Uri.https('api.openalex.org', '/works/doi:$doi'))
            as Map<String, dynamic>
      : null;
  final openAlexOrcids = openAlex == null
      ? List<String?>.filled(authors.length, null)
      : _openAlexOrcids(openAlex, authors);
  final issnsFromOpenAlex = journal && metaIssns.isEmpty;
  return (
    key: doi == null ? url : 'https://doi.org/$doi',
    type: workTypes[itemType]!,
    title: data['title'] as String,
    date: _text(item['meta'] as Map<String, dynamic>, 'parsedDate'),
    identifiers: [
      if (doi != null) (scheme: 'doi', value: doi.toLowerCase()),
      if (doi == null || itemType == 'computerProgram')
        (scheme: 'url', value: url),
      if (meta != null)
        (scheme: 'omid', value: _omids(meta['id'] as String).single),
    ],
    authors: authors,
    containers: _containers(data, [
      for (final issn
          in issnsFromOpenAlex
              ? (openAlex!['primary_location']['source']['issn'] as List)
                    .cast<String>()
              : metaIssns)
        (scheme: 'issn', value: issn),
      if (meta != null)
        for (final omid in _omids(meta['venue'] as String))
          (scheme: 'omid', value: omid),
    ]),
    pages: _text(data, 'pages'),
    orcids: switch (itemType) {
      'presentation' => await _dataciteOrcids(doi!, authors),
      'computerProgram' => await _citationOrcids(Uri.parse(url)),
      _ => {
        for (final (index, author) in authors.indexed)
          if (metaOrcids[index] case final iri?)
            _fullName(author): (value: iri, source: metaIri)
          else if (openAlexOrcids[index] case final iri?)
            _fullName(author): (value: iri, source: openAlex!['id'] as String),
      },
    },
    agentOmids: {
      if (meta != null)
        for (final MapEntry(key: orcidId, value: omid) in _agentOmids(
          meta,
        ).entries)
          orcidId: (value: omid, source: metaIri),
    },
    sources: [
      _zoteroUrl(item),
      ?metaIri,
      if (issnsFromOpenAlex) openAlex!['id'] as String,
    ],
  );
}

List<Container> _containers(
  Map<String, dynamic> data,
  List<Identifier> venueIdentifiers,
) {
  final editors = _agents(data, 'editor');
  return switch (data['itemType']) {
    'journalArticle' => [
      if (_text(data, 'issue') case final issue?)
        (
          id: 'issue',
          type: 'JournalIssue',
          title: null,
          number: issue,
          identifiers: const [],
          editors: const [],
        ),
      if (_text(data, 'volume') case final volume?)
        (
          id: 'volume',
          type: 'JournalVolume',
          title: null,
          number: volume,
          identifiers: const [],
          editors: const [],
        ),
      (
        id: 'journal',
        type: 'Journal',
        title: data['publicationTitle'] as String,
        number: null,
        identifiers: venueIdentifiers,
        editors: const [],
      ),
    ],
    'bookSection' => [
      (
        id: 'book',
        type: 'Book',
        title: data['bookTitle'] as String,
        number: null,
        identifiers: [
          if (_text(data, 'ISBN') case final isbns?)
            for (final isbn in isbns.split(' '))
              (scheme: 'isbn', value: isbn.replaceAll('-', '')),
          ...venueIdentifiers,
        ],
        editors: editors,
      ),
    ],
    'conferencePaper' => [
      (
        id: 'proceedings',
        type: 'AcademicProceedings',
        title: data['proceedingsTitle'] as String,
        number: null,
        identifiers: [
          if (Uri.parse(data['url'] as String) case final paper
              when paper.host.endsWith('ceur-ws.org'))
            (scheme: 'url', value: paper.resolve('.').toString()),
          ...venueIdentifiers,
        ],
        editors: editors,
      ),
    ],
    _ => const [],
  };
}

({String assertion, Set<String> sources}) _assertion(
  Work work,
  Map<String, Sourced> orcids,
  Map<String, Sourced> agentOmids,
) {
  final lines = <String>[];
  final sources = <String>{};
  final agentIds = <String, String>{};
  var identifierCount = 0;

  void addIdentifier(String subject, Identifier identifier) {
    final id = identifierCount == 0
        ? 'sub:identifier'
        : 'sub:identifier__$identifierCount';
    identifierCount++;
    lines
      ..add('$subject datacite:hasIdentifier $id .')
      ..add(
        '$id a datacite:Identifier ;\n'
        '    datacite:usesIdentifierScheme datacite:${identifier.scheme} ;\n'
        '    literal:hasLiteralValue ${_literal(identifier.value)} .',
      );
  }

  void addRoles(String context, String role, List<Agent> agents) {
    for (final (index, agent) in agents.indexed) {
      final roleId = 'sub:$role-${index + 1}';
      final fullName = _fullName(agent);
      final known = agentIds.containsKey(fullName);
      final agentId = agentIds.putIfAbsent(
        fullName,
        () => 'sub:agent-${agentIds.length + 1}',
      );
      lines.add(
        '$context pro:isDocumentContextFor $roleId .\n'
        '  $roleId a pro:RoleInTime ;\n'
        '    pro:withRole pro:$role ;\n'
        '    pro:isHeldBy $agentId .',
      );
      if (index > 0) lines.add('sub:$role-$index oco:hasNext $roleId .');
      if (known) continue;
      lines.add(
        _subject([
          '$agentId a foaf:Agent',
          if (agent.givenName case final given?)
            'foaf:givenName ${_literal(given)}',
          if (agent.familyName case final family?)
            'foaf:familyName ${_literal(family)}',
          if (agent.name case final name?) 'foaf:name ${_literal(name)}',
        ]),
      );
      if (orcids[fullName] case final orcid?) {
        final orcidId = orcid.value.split('/').last;
        addIdentifier(agentId, (scheme: 'orcid', value: orcidId));
        if (orcid.source case final source?) sources.add(source);
        if (agentOmids[orcidId] case final omid?) {
          addIdentifier(agentId, (scheme: 'omid', value: omid.value));
          sources.add(omid.source!);
        }
      }
    }
  }

  lines.add(
    _subject([
      '$workNode a fabio:Expression, fabio:${work.type}',
      'dct:title ${_literal(work.title)}',
      if (work.date case final date?)
        'prism:publicationDate "$date"^^xsd:${dateDatatypes[date.length]!}',
    ]),
  );
  for (final identifier in work.identifiers) {
    addIdentifier(workNode, identifier);
  }
  addRoles(workNode, 'author', work.authors);

  var part = workNode;
  for (final container in work.containers) {
    final id = 'sub:${container.id}';
    lines
      ..add('$part frbr:partOf $id .')
      ..add(
        _subject([
          '$id a fabio:Expression, fabio:${container.type}',
          if (container.title case final title?) 'dct:title ${_literal(title)}',
          if (container.number case final number?)
            'fabio:hasSequenceIdentifier ${_literal(number)}',
        ]),
      );
    for (final identifier in container.identifiers) {
      addIdentifier(id, identifier);
    }
    addRoles(id, 'editor', container.editors);
    part = id;
  }

  if (work.pages case final pages?) {
    final range = pages.split(RegExp('[-–]'));
    lines.add(
      '$workNode frbr:embodiment sub:manifestation .\n'
      '  sub:manifestation a fabio:Manifestation ;\n'
      '    prism:startingPage ${_literal(range.first)} ;\n'
      '    prism:endingPage ${_literal(range.last)} .',
    );
  }
  return (assertion: lines.join('\n  '), sources: sources);
}

String? _resource(Map<String, dynamic>? previous) =>
    previous?['resource'] as String?;

String _nanopub(Draft draft, Map<String, dynamic>? previous) {
  final resource = _resource(previous);
  final supersedes = previous?['nanopub'] as String?;
  final created = DateTime.now().toUtc().toIso8601String();
  final introduces = resource == null ? workNode : '<$resource>';
  final assertion = draft.assertion.replaceAll(
    RegExp('${RegExp.escape(workNode)}\\b'),
    introduces,
  );
  return '''
@prefix this: <http://purl.org/nanopub/temp/np001/> .
@prefix sub: <http://purl.org/nanopub/temp/np001/> .
@prefix np: <http://www.nanopub.org/nschema#> .
@prefix npx: <http://purl.org/nanopub/x/> .
@prefix nt: <https://w3id.org/np/o/ntemplate/> .
@prefix dct: <http://purl.org/dc/terms/> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix prov: <http://www.w3.org/ns/prov#> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
@prefix fabio: <http://purl.org/spar/fabio/> .
@prefix datacite: <http://purl.org/spar/datacite/> .
@prefix literal: <http://www.essepuntato.it/2010/06/literalreification/> .
@prefix pro: <http://purl.org/spar/pro/> .
@prefix frbr: <http://purl.org/vocab/frbr/core#> .
@prefix prism: <http://prismstandard.org/namespaces/basic/2.0/> .
@prefix oco: <https://w3id.org/oc/ontology/> .

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
    npx:introduces $introduces ;
    npx:hasNanopubType fabio:Expression ;
    ${supersedes == null ? '' : 'npx:supersedes <$supersedes> ;'}
    nt:wasCreatedFromTemplate <$workTemplate> ;
    nt:wasCreatedFromProvenanceTemplate <$provenanceTemplate> ;
    nt:wasCreatedFromPubinfoTemplate <$licenseTemplate>, <$creatorTemplate>${supersedes == null ? '' : ', <$supersedesTemplate>'} .
  <$orcid> foaf:name ${_literal(name)} .
}
''';
}

List<Agent> _agents(Map<String, dynamic> data, String creatorType) => [
  for (final creator
      in (data['creators'] as List<dynamic>).cast<Map<String, dynamic>>())
    if (creator['creatorType'] == creatorType)
      (
        givenName: _text(creator, 'firstName'),
        familyName: _text(creator, 'lastName'),
        name: _text(creator, 'name'),
      ),
];

String _fullName(Agent agent) =>
    agent.name ?? '${agent.givenName} ${agent.familyName}';

List<String?> _openAlexOrcids(
  Map<String, dynamic> openAlex,
  List<Agent> authors,
) {
  final authorships = (openAlex['authorships'] as List<dynamic>)
      .cast<Map<String, dynamic>>();
  if (authorships.length != authors.length) {
    throw StateError(
      '${openAlex['doi']}: Zotero and OpenAlex list different authors',
    );
  }
  return [
    for (final authorship in authorships)
      authorship['author']['orcid'] as String?,
  ];
}

Future<Map<String, dynamic>?> _metaRecord(String doi) async {
  final records = await _getJson(
    Uri.https('api.opencitations.net', '/meta/v1/metadata/doi:$doi'),
  ) as List<dynamic>;
  return records.isEmpty ? null : records.single as Map<String, dynamic>;
}

Iterable<String> _omids(String ids) =>
    RegExp(r'omid:(\w+/\d+)').allMatches(ids).map((match) => match[1]!);

List<String?> _metaOrcids(Map<String, dynamic> meta, List<Agent> authors) {
  final entries = (meta['author'] as String).split('; ');
  if (entries.length != authors.length) {
    throw StateError('${meta['id']}: Zotero and Meta list different authors');
  }
  return [
    for (final entry in entries)
      if (RegExp(r'orcid:(\S+?)[\s\]]').firstMatch(entry) case final orcid?)
        _orcidIri(orcid[1]!)
      else
        null,
  ];
}

List<String> _metaIssns(Map<String, dynamic> meta) => [
  for (final issn in RegExp(
    r'issn:(\S+?)[\s\]]',
  ).allMatches(meta['venue'] as String))
    issn[1]!,
];

Map<String, String> _agentOmids(Map<String, dynamic> meta) => {
  for (final field in ['author', 'editor'])
    for (final ids in RegExp(r'\[([^\]]*)\]').allMatches(meta[field] as String))
      if (RegExp(r'orcid:(\S+)').firstMatch(ids[1]!) case final orcid?)
        orcid[1]!: _omids(ids[1]!).single,
};

Future<Map<String, Sourced>> _dataciteOrcids(
  String doi,
  List<Agent> presenters,
) async {
  final record = Uri.https('api.datacite.org', '/dois/$doi');
  final creators =
      ((await _getJson(record))['data']['attributes']['creators']
              as List<dynamic>)
          .cast<Map<String, dynamic>>();
  if (creators.length != presenters.length) {
    throw StateError('$doi: Zotero and DataCite list different presenters');
  }
  return {
    for (final (index, creator) in creators.indexed)
      for (final identifier
          in (creator['nameIdentifiers'] as List<dynamic>)
              .cast<Map<String, dynamic>>())
        if (identifier['nameIdentifierScheme'] == 'ORCID')
          _fullName(presenters[index]): (
            value: _orcidIri(identifier['nameIdentifier'] as String),
            source: record.toString(),
          ),
  };
}

Future<Map<String, Sourced>> _citationOrcids(Uri repository) async {
  final response = await http.get(
    Uri.https(
      'api.github.com',
      '/repos${repository.path}/contents/CITATION.cff',
    ),
  );
  if (response.statusCode == 404) return {};
  if (response.statusCode != 200) {
    throw HttpException(
      '${response.request!.url} returned ${response.statusCode}',
    );
  }
  final file = jsonDecode(response.body) as Map<String, dynamic>;
  final sha = file['sha'] as String;
  await _getJson(
    Uri.https('archive.softwareheritage.org', '/api/1/content/sha1_git:$sha/'),
  );
  final source = 'https://archive.softwareheritage.org/swh:1:cnt:$sha';
  final citation = loadYaml(
    utf8.decode(
      base64.decode((file['content'] as String).replaceAll('\n', '')),
    ),
  ) as YamlMap;
  final people = [
    ...citation['authors'] as YamlList,
    ...?(citation['preferred-citation'] as YamlMap?)?['authors'] as YamlList?,
  ].cast<YamlMap>();
  return {
    for (final person in people)
      if (person['orcid'] case final String identifier)
        '${person['given-names']} ${person['family-names']}': (
          value: _orcidIri(identifier),
          source: source,
        ),
  };
}

String _orcidIri(String identifier) => identifier.startsWith('https://')
    ? identifier
    : 'https://orcid.org/$identifier';

String _zoteroUrl(Map<String, dynamic> item) =>
    'https://www.zotero.org/groups/$zoteroGroup/items/${item['key']}';

String _subject(List<String> predicates) => '${predicates.join(' ;\n    ')} .';

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
