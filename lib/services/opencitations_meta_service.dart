import 'dart:convert';
import 'package:http/http.dart' as http;
import 'opencitations_config.dart';
import 'opencitations_index_service.dart';

class AuthorWithOrcid {
  final String name;
  final String orcid;

  const AuthorWithOrcid({required this.name, required this.orcid});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthorWithOrcid && other.orcid == orcid;
  }

  @override
  int get hashCode => orcid.hashCode;

  @override
  String toString() => '$name [$orcid]';
}

class PublicationMetadata {
  final String doi;
  final String title;
  final List<AuthorWithOrcid> authorsWithOrcid;

  const PublicationMetadata({
    required this.doi,
    required this.title,
    required this.authorsWithOrcid,
  });
}

class CollaborationNode {
  final AuthorWithOrcid author;
  final int publicationCount;
  final Set<String> collaboratorOrcids;
  double x = 0.0;
  double y = 0.0;
  double vx = 0.0;
  double vy = 0.0;

  CollaborationNode({
    required this.author,
    required this.publicationCount,
    required this.collaboratorOrcids,
  });

  double get centralityScore => collaboratorOrcids.length.toDouble();
}

class CollaborationEdge {
  final String orcid1;
  final String orcid2;
  final int collaborationCount;
  final List<String> sharedPublications;

  const CollaborationEdge({
    required this.orcid1,
    required this.orcid2,
    required this.collaborationCount,
    required this.sharedPublications,
  });
}

class CollaborationNetwork {
  final Map<String, CollaborationNode> nodes;
  final List<CollaborationEdge> edges;
  final int totalPublications;
  final String dataSource;

  const CollaborationNetwork({
    required this.nodes,
    required this.edges,
    required this.totalPublications,
    required this.dataSource,
  });
}

class OpenCitationsMetaService {
  final http.Client _client;

  OpenCitationsMetaService({http.Client? client})
    : _client = client ?? http.Client();

  Future<PublicationMetadata?> getPublicationMetadata(String doi) async {
    try {
      final url = '${OpenCitationsConfig.metaBaseUrl}/metadata/doi:$doi';
      final response = await _client.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'User-Agent': OpenCitationsConfig.userAgent,
          'authorization': OpenCitationsConfig.apiToken,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final item = data.first as Map<String, dynamic>;
          return _parsePublicationMetadata(item, doi);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Retrieve metadata for works citing the given DOI.
  ///
  /// This method uses the Index API (via [OpenCitationsIndexService]) to
  /// obtain the list of citations (and corresponding OCIs), extracts the
  /// citing OMIDs, and then resolves each citing work through the Meta API.
  Future<List<CitationMetadata>> getCitationMetadataForDoi(
    String doi, {
    required OpenCitationsIndexService indexService,
  }) async {
    try {
      final citations = await indexService.getCitations(doi);
      if (citations.isEmpty) return [];

      final List<CitationMetadata> metadataList = [];
      for (final citation in citations) {
        final citingOmid = _extractCitingOmidFromOci(citation.oci);
        if (citingOmid != null) {
          final metadata = await _getMetadataById('omid:br/$citingOmid');
          if (metadata != null) {
            metadataList.add(metadata);
          }
        }
      }
      return metadataList;
    } catch (_) {
      return [];
    }
  }

  String? _extractCitingOmidFromOci(String oci) {
    final parts = oci.split('-');
    if (parts.length >= 2) {
      return parts[0];
    }
    return null;
  }

  Future<CitationMetadata?> _getMetadataById(String id) async {
    try {
      final response = await _client.get(
        Uri.parse('${OpenCitationsConfig.metaBaseUrl}/metadata/$id'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': OpenCitationsConfig.userAgent,
          'authorization': OpenCitationsConfig.apiToken,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        if (jsonData.isNotEmpty) {
          return CitationMetadata.fromJson(
            jsonData.first as Map<String, dynamic>,
          );
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  PublicationMetadata _parsePublicationMetadata(
    Map<String, dynamic> data,
    String doi,
  ) {
    final title = data['title'] as String? ?? 'Unknown Title';
    final authorString = data['author'] as String? ?? '';
    final authorsWithOrcid = _parseAuthorsWithOrcid(authorString);

    return PublicationMetadata(
      doi: doi,
      title: title,
      authorsWithOrcid: authorsWithOrcid,
    );
  }

  /// Parse the OpenCitations Meta `author` field into a list of
  /// `AuthorWithOrcid`.
  ///
  /// Supports entries such as:
  /// - "Surname, Name [orcid:0000-0000-0000-000X]"
  /// - "Surname, Name [ORCID:0000-0000-0000-000X]"
  List<AuthorWithOrcid> _parseAuthorsWithOrcid(String authorString) {
    final authors = <AuthorWithOrcid>[];

    if (authorString.isEmpty) return authors;

    final authorParts = authorString.split(';');

    for (final part in authorParts) {
      final trimmed = part.trim();
      if (trimmed.isEmpty) continue;

      final lower = trimmed.toLowerCase();
      final schemaIndex = lower.indexOf('orcid:');

      if (schemaIndex != -1) {
        final afterSchema =
            trimmed.substring(schemaIndex + 'orcid:'.length).trim();

        final schemaIdMatch = RegExp(
          r'([0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[0-9X])',
          caseSensitive: false,
        ).firstMatch(afterSchema);

        if (schemaIdMatch != null) {
          final orcid = schemaIdMatch.group(1)!;
          var name = trimmed.substring(0, schemaIndex).trim();
          name = name.replaceAll(RegExp(r'[\[\(\{]+$'), '').trim();

          if (name.isNotEmpty) {
            authors.add(AuthorWithOrcid(name: name, orcid: orcid));
          }
          continue;
        }
      }
    }

    return authors;
  }

  Future<CollaborationNetwork> buildCollaborationNetwork(
    List<String> dois,
  ) async {
    final publicationMetadata = <PublicationMetadata>[];
    final nodes = <String, CollaborationNode>{};
    final collaborations = <String, Map<String, CollaborationData>>{};

    for (final doi in dois) {
      final metadata = await getPublicationMetadata(doi);
      if (metadata != null && metadata.authorsWithOrcid.isNotEmpty) {
        publicationMetadata.add(metadata);

        for (final author in metadata.authorsWithOrcid) {
          nodes[author.orcid] =
              nodes[author.orcid]?.copyWithIncrementedCount() ??
              CollaborationNode(
                author: author,
                publicationCount: 1,
                collaboratorOrcids: <String>{},
              );

          for (final otherAuthor in metadata.authorsWithOrcid) {
            if (author.orcid != otherAuthor.orcid) {
              nodes[author.orcid]!.collaboratorOrcids.add(otherAuthor.orcid);

              collaborations[author.orcid] ??= <String, CollaborationData>{};
              collaborations[author.orcid]![otherAuthor
                  .orcid] = (collaborations[author.orcid]![otherAuthor.orcid] ??
                      CollaborationData(count: 0, publications: []))
                  .copyWithAddedPublication(metadata.title);
            }
          }
        }
      }
    }

    final edges = _buildEdges(collaborations);

    return CollaborationNetwork(
      nodes: nodes,
      edges: edges,
      totalPublications: publicationMetadata.length,
      dataSource:
          'OpenCitations Meta API (https://api.opencitations.net/meta/v1)',
    );
  }

  List<CollaborationEdge> _buildEdges(
    Map<String, Map<String, CollaborationData>> collaborations,
  ) {
    final edges = <CollaborationEdge>[];
    final processedPairs = <String>{};

    for (final entry in collaborations.entries) {
      final orcid1 = entry.key;

      for (final collaboratorEntry in entry.value.entries) {
        final orcid2 = collaboratorEntry.key;
        final data = collaboratorEntry.value;

        final pairKey = _createPairKey(orcid1, orcid2);

        if (!processedPairs.contains(pairKey)) {
          processedPairs.add(pairKey);

          edges.add(
            CollaborationEdge(
              orcid1: orcid1,
              orcid2: orcid2,
              collaborationCount: data.count,
              sharedPublications: data.publications,
            ),
          );
        }
      }
    }

    return edges;
  }

  String _createPairKey(String orcid1, String orcid2) {
    final sorted = [orcid1, orcid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  void dispose() {
    _client.close();
  }
}

class CitationMetadata {
  final String? id;
  final String? title;
  final String? author;
  final String? pubDate;
  final String? venue;
  final String? volume;
  final String? issue;
  final String? page;
  final String? type;
  final String? publisher;
  final String? editor;

  const CitationMetadata({
    this.id,
    this.title,
    this.author,
    this.pubDate,
    this.venue,
    this.volume,
    this.issue,
    this.page,
    this.type,
    this.publisher,
    this.editor,
  });

  factory CitationMetadata.fromJson(Map<String, dynamic> json) {
    return CitationMetadata(
      id: json['id'] as String?,
      title: json['title'] as String?,
      author: json['author'] as String?,
      pubDate: json['pub_date'] as String?,
      venue: json['venue'] as String?,
      volume: json['volume'] as String?,
      issue: json['issue'] as String?,
      page: json['page'] as String?,
      type: json['type'] as String?,
      publisher: json['publisher'] as String?,
      editor: json['editor'] as String?,
    );
  }

  String get displayTitle => title ?? 'Unknown Title';
  String get displayAuthor => author ?? 'Unknown Author';

  List<String> get authorsList {
    if (author == null || author!.isEmpty) return ['Unknown Author'];
    final authors =
        author!
            .split(';')
            .map((a) => a.trim())
            .where((a) => a.isNotEmpty)
            .toList();
    return authors.isEmpty ? ['Unknown Author'] : authors;
  }

  String get displayYear {
    if (pubDate == null || pubDate!.isEmpty) return 'Unknown Year';
    final yearMatch = RegExp(r'\d{4}').firstMatch(pubDate!);
    return yearMatch?.group(0) ?? pubDate!;
  }

  String get displayVenue => venue ?? volume ?? 'Unknown Venue';

  String get doiUrl {
    if (id != null && id!.contains('doi:')) {
      final doiMatch = RegExp(r'doi:([^\s;]+)').firstMatch(id!);
      if (doiMatch != null) {
        final doi = doiMatch.group(1)!;
        return 'https://doi.org/$doi';
      }
    }
    return '';
  }

  bool get hasDoi => id != null && id!.contains('doi:');
}

class CollaborationData {
  final int count;
  final List<String> publications;

  const CollaborationData({required this.count, required this.publications});

  CollaborationData copyWithAddedPublication(String publication) {
    return CollaborationData(
      count: count + 1,
      publications: [...publications, publication],
    );
  }
}

extension on CollaborationNode {
  CollaborationNode copyWithIncrementedCount() {
    return CollaborationNode(
      author: author,
      publicationCount: publicationCount + 1,
      collaboratorOrcids: collaboratorOrcids,
    );
  }
}
