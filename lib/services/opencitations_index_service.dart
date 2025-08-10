import 'dart:convert';
import 'package:http/http.dart' as http;
import 'opencitations_config.dart';

/// Service for interacting with the OpenCitations Index API (v2).
///
/// Responsibilities:
/// - Retrieve citation count for a DOI
/// - Retrieve list of citation relations for a DOI
/// - Provide simple caching with time-based invalidation
class OpenCitationsIndexService {
  final http.Client _client;

  Map<String, int>? _cachedCitationCounts;
  Map<String, List<CitationData>>? _cachedCitations;
  DateTime? _lastFetch;
  static const Duration cacheExpiry = Duration(hours: 6);

  OpenCitationsIndexService({http.Client? client})
    : _client = client ?? http.Client();

  Future<int> getCitationCount(String doi) async {
    _initializeCache();

    if (_cachedCitationCounts!.containsKey(doi) && _isCacheValid()) {
      return _cachedCitationCounts![doi]!;
    }

    try {
      final response = await _client.get(
        Uri.parse(
          '${OpenCitationsConfig.indexBaseUrl}/citation-count/doi:$doi',
        ),
        headers: {
          'Accept': 'application/json',
          'User-Agent': OpenCitationsConfig.userAgent,
          'authorization': OpenCitationsConfig.apiToken,
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
    } catch (_) {
      return 0;
    }
  }

  Future<List<CitationData>> getCitations(String doi) async {
    _initializeCache();

    if (_cachedCitations!.containsKey(doi) && _isCacheValid()) {
      return _cachedCitations![doi]!;
    }

    try {
      final response = await _client.get(
        Uri.parse('${OpenCitationsConfig.indexBaseUrl}/citations/doi:$doi'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': OpenCitationsConfig.userAgent,
          'authorization': OpenCitationsConfig.apiToken,
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
    } catch (_) {
      return [];
    }
  }

  Future<int> getTotalCitationCount(List<String> dois) async {
    int totalCount = 0;
    for (final doi in dois) {
      final count = await getCitationCount(doi);
      totalCount += count;
    }
    return totalCount;
  }

  void clearCache() {
    _cachedCitationCounts?.clear();
    _cachedCitations?.clear();
    _lastFetch = null;
  }

  void dispose() {
    _client.close();
  }

  void _initializeCache() {
    _cachedCitationCounts ??= {};
    _cachedCitations ??= {};
  }

  bool _isCacheValid() {
    return _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < cacheExpiry;
  }
}

/// Data structure describing a citation relation returned by the Index API.
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

  /// Extract DOI from the `citing` field which can contain identifiers like `doi:10.xxxx/xxxx`.
  String? get citingDoi {
    final doiMatch = RegExp(r'doi:([^\s;]+)').firstMatch(citing);
    return doiMatch?.group(1);
  }
}
