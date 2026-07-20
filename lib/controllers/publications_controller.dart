// SPDX-FileCopyrightText: 2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/publication.dart';
import '../services/github_service.dart';
import '../services/opencitations_index_service.dart';
import '../services/opencitations_meta_service.dart';
import '../services/seo_service.dart';
import '../services/zotero_service.dart';
import '../utils/publication_utils.dart';

abstract class UrlLauncher {
  Future<void> openUrl(String url);
}

class DefaultUrlLauncher implements UrlLauncher {
  @override
  Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

typedef GitHubDescriptionLoader = Future<String?> Function(String? url);

class PublicationsController extends ChangeNotifier {
  final ZoteroService _zoteroService;
  final OpenCitationsIndexService _openCitationsService;
  final OpenCitationsMetaService _openCitationsMetaService;
  final UrlLauncher _urlLauncher;
  final GitHubDescriptionLoader _gitHubDescriptionLoader;
  final bool _ownsOpenCitationsService;
  final bool _ownsOpenCitationsMetaService;

  List<Publication>? _publications;
  List<Publication>? _filteredPublications;
  bool _isLoading = true;
  String? _error;
  String _selectedCategoryKey = 'all';
  String _searchQuery = '';
  final Set<String> _expandedAuthors = {};
  final Set<String> _expandedAbstracts = {};
  final Set<String> _expandedCitations = {};
  final Set<String> _expandedCitationAuthors = {};
  final Map<String, List<CitationMetadata>> _citationMetadataCache = {};
  final Map<String, bool> _loadingCitations = {};
  final Map<String, String?> _gitHubDescriptionCache = {};
  final Map<String, bool> _loadingGitHubDescriptions = {};
  final Map<String, Future<void>> _gitHubDescriptionFutures = {};
  int? _totalCitationCount;
  bool _isLoadingTotalCitations = false;
  int _currentPage = 0;
  bool _isDisposed = false;
  Future<void>? _loadFuture;
  Future<void>? _citationCountsFuture;
  Future<void>? _totalCitationCountFuture;
  bool _citationCountsLoaded = false;
  bool _totalCitationCountLoaded = false;

  static const int publicationsPerPage = 10;

  PublicationsController({
    ZoteroService? zoteroService,
    OpenCitationsIndexService? openCitationsService,
    OpenCitationsMetaService? openCitationsMetaService,
    UrlLauncher? urlLauncher,
    GitHubDescriptionLoader? gitHubDescriptionLoader,
  }) : _zoteroService = zoteroService ?? ZoteroService(),
       _openCitationsService =
           openCitationsService ?? OpenCitationsIndexService(),
       _openCitationsMetaService =
           openCitationsMetaService ?? OpenCitationsMetaService(),
       _urlLauncher = urlLauncher ?? DefaultUrlLauncher(),
       _gitHubDescriptionLoader =
           gitHubDescriptionLoader ?? GitHubService.getDescriptionFromUrl,
       _ownsOpenCitationsService = openCitationsService == null,
       _ownsOpenCitationsMetaService = openCitationsMetaService == null;

  List<Publication>? get publications => _publications;
  List<Publication>? get filteredPublications => _filteredPublications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategoryKey => _selectedCategoryKey;
  String get searchQuery => _searchQuery;
  Set<String> get expandedAuthors => _expandedAuthors;
  Set<String> get expandedAbstracts => _expandedAbstracts;
  Set<String> get expandedCitations => _expandedCitations;
  Set<String> get expandedCitationAuthors => _expandedCitationAuthors;
  Map<String, List<CitationMetadata>> get citationMetadataCache =>
      _citationMetadataCache;
  Map<String, bool> get loadingCitations => _loadingCitations;
  Map<String, String?> get gitHubDescriptionCache => _gitHubDescriptionCache;
  Map<String, bool> get loadingGitHubDescriptions => _loadingGitHubDescriptions;
  int? get totalCitationCount => _totalCitationCount;
  bool get isLoadingTotalCitations => _isLoadingTotalCitations;
  int get currentPage => _currentPage;

  int get totalPages {
    final publications = _filteredPublications;
    if (publications == null || publications.isEmpty) {
      return 1;
    }
    return (publications.length / publicationsPerPage).ceil();
  }

  List<Publication> get currentPagePublications {
    final publications = _filteredPublications;
    if (publications == null) {
      return [];
    }

    final startIndex = _currentPage * publicationsPerPage;
    final endIndex = (startIndex + publicationsPerPage).clamp(
      0,
      publications.length,
    );
    return publications.sublist(startIndex, endIndex);
  }

  List<String> get availableCategoryKeys {
    final publications = _publications;
    if (publications == null) {
      return ['all'];
    }

    final categories = <String>{'all'};
    for (final publication in publications) {
      categories.add(publication.itemType);
    }

    final categoryOrder = PublicationUtils.getCategoryOrder();
    final sortedCategories = categoryOrder.where(categories.contains).toList();
    final unknownCategories =
        categories
            .where(
              (category) =>
                  category != 'all' && !categoryOrder.contains(category),
            )
            .toList()
          ..sort();

    return ['all', ...sortedCategories, ...unknownCategories];
  }

  Future<void> loadPublications() {
    return _loadFuture ??= _loadPublications();
  }

  Future<void> prepareLayout() async {
    if (_isLoading) {
      await loadPublications();
    }
    final publications = _publications;
    if (publications == null) {
      return;
    }

    final citationCountsFuture = _citationCountsFuture;
    final totalCitationCountFuture = _totalCitationCountFuture;
    await Future.wait([
      if (!_citationCountsLoaded && citationCountsFuture != null)
        citationCountsFuture,
      if (!_totalCitationCountLoaded && totalCitationCountFuture != null)
        totalCitationCountFuture,
      ...publications
          .where((publication) => publication.itemType == 'computerProgram')
          .map(loadGitHubDescription),
    ]);
  }

  Future<void> _loadPublications() async {
    try {
      final publications = await _zoteroService.getPublications();
      _publications = List<Publication>.of(publications);
      _isLoading = false;
      _error = null;
      _applyFilters();
      _notifyListeners();

      SEOService.addStructuredDataForPublications(
        publications
            .map(
              (publication) => {
                'title': publication.title,
                'type': publication.itemType,
                'doi': publication.doi,
                'datePublished': publication.year,
                'venue': publication.venue,
                'authors': publication.authors,
                'abstract': publication.abstractText,
                'url': publication.url,
                'journal': publication.journal,
                'volume': publication.volume,
                'issue': publication.issue,
                'pages': publication.pages,
              },
            )
            .toList(),
      );

      _citationCountsFuture = _loadCitationCounts();
      _totalCitationCountFuture = _loadTotalCitationCount();
      unawaited(_citationCountsFuture);
      unawaited(_totalCitationCountFuture);
    } on ZoteroServiceException catch (error) {
      _publications = null;
      _filteredPublications = null;
      _isLoading = false;
      _error = error.toString();
      _notifyListeners();
    }
  }

  Future<void> _loadCitationCounts() async {
    final publications = _publications;
    if (publications == null) {
      _citationCountsLoaded = true;
      return;
    }

    for (final publication in publications.where(
      (publication) => publication.hasDoi,
    )) {
      if (publication.hasLoadedCitations) {
        continue;
      }

      final citationCount = await _openCitationsService.getCitationCount(
        publication.doi!,
      );
      final index = publications.indexWhere(
        (candidate) => candidate.key == publication.key,
      );
      if (index == -1) {
        continue;
      }

      publications[index] = publication.copyWith(
        citationCount: citationCount,
        hasLoadedCitations: true,
      );
      _applyFilters();
      _notifyListeners();
    }
    _citationCountsLoaded = true;
  }

  Future<void> _loadTotalCitationCount() async {
    final publications = _publications;
    if (publications == null || _isLoadingTotalCitations) {
      _totalCitationCountLoaded = true;
      return;
    }

    final dois = publications
        .where((publication) => publication.hasDoi)
        .map((publication) => publication.doi!)
        .toList();
    if (dois.isEmpty) {
      _totalCitationCountLoaded = true;
      return;
    }

    _isLoadingTotalCitations = true;
    _notifyListeners();

    _totalCitationCount = await _openCitationsService.getTotalCitationCount(
      dois,
    );
    _isLoadingTotalCitations = false;
    _totalCitationCountLoaded = true;
    _notifyListeners();
  }

  Future<void> loadCitations(String doi, String publicationKey) async {
    if (_citationMetadataCache.containsKey(publicationKey) ||
        _loadingCitations[publicationKey] == true) {
      return;
    }

    _loadingCitations[publicationKey] = true;
    _notifyListeners();

    _citationMetadataCache[publicationKey] = await _openCitationsMetaService
        .getCitationMetadataForDoi(doi, indexService: _openCitationsService);
    _loadingCitations[publicationKey] = false;
    _notifyListeners();
  }

  Future<void> loadGitHubDescription(Publication publication) {
    final key = publication.key;
    if (_gitHubDescriptionCache.containsKey(key)) {
      return Future.value();
    }
    return _gitHubDescriptionFutures[key] ??= _loadGitHubDescription(
      publication,
    );
  }

  Future<void> _loadGitHubDescription(Publication publication) async {
    final key = publication.key;
    _loadingGitHubDescriptions[key] = true;
    _notifyListeners();
    _gitHubDescriptionCache[key] = await _gitHubDescriptionLoader(
      publication.url,
    );
    _loadingGitHubDescriptions[key] = false;
    _notifyListeners();
  }

  Future<void> openUrl(String url) => _urlLauncher.openUrl(url);

  void selectCategory(String categoryKey) {
    if (_publications == null) {
      return;
    }
    _selectedCategoryKey = categoryKey;
    _currentPage = 0;
    _applyFilters();
    _notifyListeners();
  }

  void updateSearch(String query) {
    _searchQuery = query;
    _currentPage = 0;
    _applyFilters();
    _notifyListeners();
  }

  void nextPage() {
    if (_currentPage >= totalPages - 1) {
      return;
    }
    _currentPage++;
    _notifyListeners();
  }

  void previousPage() {
    if (_currentPage == 0) {
      return;
    }
    _currentPage--;
    _notifyListeners();
  }

  void goToPage(int page) {
    _currentPage = page.clamp(0, totalPages - 1);
    _notifyListeners();
  }

  void toggleAuthors(String key) {
    _toggle(_expandedAuthors, key);
  }

  void toggleAbstract(String key) {
    _toggle(_expandedAbstracts, key);
  }

  void expandCitations(String key) {
    if (_expandedCitations.add(key)) {
      _notifyListeners();
    }
  }

  void collapseCitations(String key) {
    if (_expandedCitations.remove(key)) {
      _notifyListeners();
    }
  }

  void toggleCitationAuthors(String key) {
    _toggle(_expandedCitationAuthors, key);
  }

  void _toggle(Set<String> values, String key) {
    if (!values.remove(key)) {
      values.add(key);
    }
    _notifyListeners();
  }

  void _applyFilters() {
    final publications = _publications;
    if (publications == null) {
      return;
    }

    Iterable<Publication> filtered = publications;
    if (_selectedCategoryKey != 'all') {
      filtered = filtered.where(
        (publication) => publication.itemType == _selectedCategoryKey,
      );
    }

    final normalizedQuery = _searchQuery.toLowerCase();
    if (normalizedQuery.isNotEmpty) {
      filtered = filtered.where((publication) {
        return publication.title.toLowerCase().contains(normalizedQuery) ||
            publication.authorsString.toLowerCase().contains(normalizedQuery) ||
            publication.displayVenue.toLowerCase().contains(normalizedQuery) ||
            publication.displayYear.toLowerCase().contains(normalizedQuery) ||
            (publication.abstractText?.toLowerCase().contains(
                  normalizedQuery,
                ) ??
                false);
      });
    }

    _filteredPublications = filtered.toList();
  }

  void _notifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    if (_ownsOpenCitationsService) {
      _openCitationsService.dispose();
    }
    if (_ownsOpenCitationsMetaService) {
      _openCitationsMetaService.dispose();
    }
    super.dispose();
  }
}
