import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenCitationsService {
  static const String baseUrl = 'https://api.opencitations.net/index/v2';
  static const String metaUrl = 'https://api.opencitations.net/meta/v1';
  static const String _apiToken =
      'f1027252-c9dc-43df-a762-5f9dbd430421-1754571028';

  Map<String, int>? _cachedCitationCounts;
  Map<String, List<CitationData>>? _cachedCitations;
  Map<String, List<CitationMetadata>>? _cachedCitationMetadata;
  DateTime? _lastFetch;
  static const Duration cacheExpiry = Duration(hours: 6);

  Future<int> getCitationCount(String doi) async {
    _initializeCache();

    if (_cachedCitationCounts!.containsKey(doi) && _isCacheValid()) {
      return _cachedCitationCounts![doi]!;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/citation-count/doi:$doi'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Portfolio di Arcangelo/1.0',
          'authorization': _apiToken,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final count =
            jsonData.isNotEmpty
                ? (jsonData.first['count'] as String? ?? '0')
                : '0';
        final citationCount = int.tryParse(count) ?? 0;

        _cachedCitationCounts![doi] = citationCount;
        _lastFetch = DateTime.now();

        return citationCount;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  Future<List<CitationData>> getCitations(String doi) async {
    _initializeCache();

    if (_cachedCitations!.containsKey(doi) && _isCacheValid()) {
      return _cachedCitations![doi]!;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/citations/doi:$doi'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Portfolio di Arcangelo/1.0',
          'authorization': _apiToken,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final citations =
            jsonData
                .map(
                  (item) => CitationData.fromJson(item as Map<String, dynamic>),
                )
                .toList();

        _cachedCitations![doi] = citations;
        _lastFetch = DateTime.now();

        return citations;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<CitationMetadata>> getCitationMetadata(String doi) async {
    _initializeCache();

    if (_cachedCitationMetadata!.containsKey(doi) && _isCacheValid()) {
      return _cachedCitationMetadata![doi]!;
    }

    try {
      // First get the citation data to extract OMIDs
      final citations = await getCitations(doi);
      if (citations.isEmpty) {
        _cachedCitationMetadata![doi] = [];
        return [];
      }

      final List<CitationMetadata> metadataList = [];

      // For each citation, get the metadata of the citing work using OMID
      for (final citation in citations) {
        final citingOmid = _extractCitingOmidFromOci(citation.oci);
        if (citingOmid != null) {
          final metadata = await _getMetadataById('omid:br/$citingOmid');
          if (metadata != null) {
            metadataList.add(metadata);
          }
        }
      }

      _cachedCitationMetadata![doi] = metadataList;
      _lastFetch = DateTime.now();

      return metadataList;
    } catch (e) {
      _cachedCitationMetadata![doi] = [];
      return [];
    }
  }

  String? _extractCitingOmidFromOci(String oci) {
    // OCI format: citingOMID-citedOMID
    final parts = oci.split('-');
    if (parts.length >= 2) {
      return parts[0]; // This is the citing OMID
    }
    return null;
  }

  Future<CitationMetadata?> _getMetadataById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$metaUrl/metadata/$id'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Portfolio di Arcangelo/1.0',
          'authorization': _apiToken,
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
    } catch (e) {
      // Error fetching metadata for $id: $e
      return null;
    }
  }

  void _initializeCache() {
    _cachedCitationCounts ??= {};
    _cachedCitations ??= {};
    _cachedCitationMetadata ??= {};
  }

  bool _isCacheValid() {
    return _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < cacheExpiry;
  }

  void clearCache() {
    _cachedCitationCounts?.clear();
    _cachedCitations?.clear();
    _cachedCitationMetadata?.clear();
    _lastFetch = null;
  }
}

class CitationData {
  final String oci;
  final String citing;
  final String cited;
  final String? creation;
  final String? timespan;
  final String? journalSc;
  final String? authorSc;

  const CitationData({
    required this.oci,
    required this.citing,
    required this.cited,
    this.creation,
    this.timespan,
    this.journalSc,
    this.authorSc,
  });

  factory CitationData.fromJson(Map<String, dynamic> json) {
    return CitationData(
      oci: json['oci'] as String? ?? '',
      citing: json['citing'] as String? ?? '',
      cited: json['cited'] as String? ?? '',
      creation: json['creation'] as String?,
      timespan: json['timespan'] as String?,
      journalSc: json['journal_sc'] as String?,
      authorSc: json['author_sc'] as String?,
    );
  }

  String? get citingDoi {
    // Extract DOI from citing field which contains PIDs like "doi:10.1000/182"
    final doiMatch = RegExp(r'doi:([^\s;]+)').firstMatch(citing);
    return doiMatch?.group(1);
  }

  String displayTitle(dynamic l10n) =>
      '${l10n.citation} ${oci.substring(0, 8)}...';
  String displayAuthor(dynamic l10n) =>
      '${l10n.citationFrom} ${creation ?? l10n.unknownDate}';
  String displayYear(dynamic l10n) {
    if (creation == null || creation!.isEmpty) return l10n.unknownYear;
    final yearMatch = RegExp(r'\d{4}').firstMatch(creation!);
    return yearMatch?.group(0) ?? creation!;
  }

  String displayJournal(dynamic l10n) =>
      timespan != null ? '${l10n.citedAfter} $timespan' : l10n.unknownJournal;

  String get doiUrl => citingDoi != null ? 'https://doi.org/$citingDoi' : '';
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
    
    // Parse authors string which are separated by '; ' (semicolon space)
    // Comma is used to separate last name from first name, not authors
    final authors = author!.split(';')
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
      // Extract DOI from composite ID that might contain multiple identifiers
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
