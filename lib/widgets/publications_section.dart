import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';
import '../l10n/app_localizations.dart';
import '../models/publication.dart';
import '../services/zotero_service.dart';
import '../services/opencitations_service.dart';
import '../services/seo_service.dart';
import 'expandable_authors_widget.dart';
import '../utils/publication_utils.dart';
import 'lazy_image.dart';

/// Interface for URL launching to enable dependency injection and testing
abstract class UrlLauncher {
  Future<void> openUrl(String url);
}

/// Default implementation using url_launcher package
class DefaultUrlLauncher implements UrlLauncher {
  @override
  Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class PublicationsSection extends StatefulWidget {
  final ZoteroService? zoteroService;
  final OpenCitationsService? openCitationsService;
  final UrlLauncher? urlLauncher;

  const PublicationsSection({
    super.key,
    this.zoteroService,
    this.openCitationsService,
    this.urlLauncher,
  });

  @override
  State<PublicationsSection> createState() => _PublicationsSectionState();
}

class _PublicationsSectionState extends State<PublicationsSection> {
  late final ZoteroService _zoteroService;
  late final OpenCitationsService _openCitationsService;
  late final UrlLauncher _urlLauncher;
  List<Publication>? _publications;
  List<Publication>? _filteredPublications;
  bool _isLoading = true;
  String? _error;
  String _selectedCategoryKey = 'all';
  final Set<String> _expandedAuthors = {};
  final Set<String> _expandedAbstracts = {};
  final Set<String> _expandedCitations = {};
  final Set<String> _expandedCitationAuthors = {};
  final Map<String, List<CitationMetadata>> _citationMetadataCache = {};
  final Map<String, bool> _loadingCitations = {};
  int _currentPage = 0;
  static const int _publicationsPerPage = 10;
  final GlobalKey _publicationsSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _zoteroService = widget.zoteroService ?? ZoteroService();
    _openCitationsService =
        widget.openCitationsService ?? OpenCitationsService();
    _urlLauncher = widget.urlLauncher ?? DefaultUrlLauncher();
    _loadPublications();
  }

  Future<void> _loadPublications() async {
    try {
      final publications = await _zoteroService.getPublications();
      if (mounted) {
        setState(() {
          _publications = publications;
          _filteredPublications = publications;
          _isLoading = false;
          _error = null;
        });

        // Update SEO structured data for publications
        final publicationsData =
            publications
                .map(
                  (pub) => {
                    'title': pub.title,
                    'type': pub.itemType,
                    'doi': pub.doi,
                    'datePublished': pub.year,
                    'venue': pub.venue,
                    'authors': pub.authors,
                    'abstract': pub.abstractText,
                    'url': pub.url,
                    'journal': pub.journal,
                    'volume': pub.volume,
                    'issue': pub.issue,
                    'pages': pub.pages,
                  },
                )
                .toList();
        SEOService.addStructuredDataForPublications(publicationsData);

        _loadCitationCounts();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _publications = null;
          _filteredPublications = null;
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _loadCitationCounts() async {
    if (_publications == null) return;

    final publicationsWithDoi =
        _publications!.where((pub) => pub.hasDoi).toList();

    for (final publication in publicationsWithDoi) {
      if (publication.doi != null && !publication.hasLoadedCitations) {
        try {
          final citationCount = await _openCitationsService.getCitationCount(
            publication.doi!,
          );
          final updatedPublication = publication.copyWith(
            citationCount: citationCount,
            hasLoadedCitations: true,
          );

          if (mounted) {
            setState(() {
              final index = _publications!.indexWhere(
                (p) => p.key == publication.key,
              );
              if (index != -1) {
                _publications![index] = updatedPublication;
                _filterPublications(
                  _selectedCategoryKey,
                  AppLocalizations.of(context)!,
                );
              }
            });
          }
        } catch (e) {
          // Citation count loading failed, continue without citation data
        }
      }
    }
  }

  Future<void> _loadCitations(String doi, String publicationKey) async {
    if (_citationMetadataCache.containsKey(publicationKey) ||
        _loadingCitations[publicationKey] == true) {
      return;
    }

    setState(() {
      _loadingCitations[publicationKey] = true;
    });

    try {
      final citationMetadata = await _openCitationsService.getCitationMetadata(
        doi,
      );
      if (mounted) {
        setState(() {
          _citationMetadataCache[publicationKey] = citationMetadata;
          _loadingCitations[publicationKey] = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _citationMetadataCache[publicationKey] = [];
          _loadingCitations[publicationKey] = false;
        });
      }
    }
  }

  void _filterPublications(String categoryKey, AppLocalizations l10n) {
    if (_publications == null) return;

    setState(() {
      _selectedCategoryKey = categoryKey;
      _currentPage = 0;
      if (categoryKey == 'all') {
        _filteredPublications = _publications;
      } else {
        _filteredPublications =
            _publications!.where((pub) => pub.itemType == categoryKey).toList();
      }
    });
  }

  void _scrollToPublications() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _publicationsSectionKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.0,
        );
      }
    });
  }

  void _nextPage() {
    if (_filteredPublications == null) return;
    final maxPage =
        (_filteredPublications!.length / _publicationsPerPage).ceil() - 1;

    setState(() {
      if (_currentPage < maxPage) {
        _currentPage++;
      }
    });
    _scrollToPublications();
  }

  void _previousPage() {
    setState(() {
      if (_currentPage > 0) {
        _currentPage--;
      }
    });
    _scrollToPublications();
  }

  void _goToPage(int page) {
    if (_filteredPublications == null) return;
    final maxPage =
        (_filteredPublications!.length / _publicationsPerPage).ceil() - 1;

    setState(() {
      _currentPage = page.clamp(0, maxPage);
    });
    _scrollToPublications();
  }

  List<Publication> _getCurrentPagePublications() {
    if (_filteredPublications == null) return [];

    final startIndex = _currentPage * _publicationsPerPage;
    final endIndex = (startIndex + _publicationsPerPage).clamp(
      0,
      _filteredPublications!.length,
    );

    return _filteredPublications!.sublist(startIndex, endIndex);
  }

  int get _totalPages {
    if (_filteredPublications == null || _filteredPublications!.isEmpty) {
      return 1;
    }
    return (_filteredPublications!.length / _publicationsPerPage).ceil();
  }

  Map<String, String> _getCategoryMapping(AppLocalizations l10n) {
    return {
      'all': l10n.categoryAll,
      'journalArticle': l10n.categoryJournalArticle,
      'conferencePaper': l10n.categoryConferencePaper,
      'book': l10n.categoryBook,
      'bookSection': l10n.categoryBookSection,
      'computerProgram': l10n.categorySoftware,
      'presentation': l10n.categoryPresentation,
      'thesis': l10n.categoryThesis,
      'report': l10n.categoryReport,
    };
  }

  List<String> _getAvailableCategoryKeys() {
    if (_publications == null) return ['all'];

    final categories = <String>{'all'};
    for (final pub in _publications!) {
      categories.add(pub.itemType);
    }

    // Use priority order from PublicationUtils instead of alphabetical
    final categoryOrder = PublicationUtils.getCategoryOrder();
    final sortedCategories =
        categoryOrder.where((cat) => categories.contains(cat)).toList();

    // Add any unknown categories at the end
    final unknownCategories =
        categories
            .where((cat) => cat != 'all' && !categoryOrder.contains(cat))
            .toList()
          ..sort();

    return ['all', ...sortedCategories, ...unknownCategories];
  }

  Future<void> _launchUrl(String url) async {
    await _urlLauncher.openUrl(url);
  }

  /// Handle the launch button press for a publication
  Future<void> _handleLaunchButtonPress(Publication publication) async {
    final url = PublicationUtils.getLaunchUrl(publication);
    await _launchUrl(url);
  }

  /// Build the launch button for a publication
  Widget _buildLaunchButton(Publication publication, AppLocalizations l10n) {
    return ElevatedButton.icon(
      onPressed: () => _handleLaunchButtonPress(publication),
      icon: const Icon(Icons.open_in_new, size: 16),
      label: Text(publication.getViewButtonText(l10n)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        foregroundColor: Theme.of(context).colorScheme.onTertiary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildTextWithClickableLinks(String text, TextStyle? style) {
    final urlRegex = RegExp(
      r'https?://[^\s<>"{}|\\^`\[\]]+',
      caseSensitive: false,
    );

    final matches = urlRegex.allMatches(text);
    if (matches.isEmpty) {
      return SelectableText(text, style: style);
    }

    List<TextSpan> spans = [];
    int lastEnd = 0;

    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(text: text.substring(lastEnd, match.start), style: style),
        );
      }

      final url = match.group(0)!;
      spans.add(
        TextSpan(
          text: url,
          style: style?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()..onTap = () => _launchUrl(url),
        ),
      );

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd), style: style));
    }

    return SelectableText.rich(TextSpan(children: spans));
  }

  Widget _buildAbstractContent(String content) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
      height: 1.6,
    );

    if (PublicationUtils.containsHtml(content)) {
      return Html(
        data: content,
        style: {
          "body": Style(
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
            fontSize: FontSize(textStyle?.fontSize ?? 14),
            color: textStyle?.color,
            lineHeight: const LineHeight(1.6),
          ),
          "p": Style(margin: Margins.zero),
          "a": Style(
            color: Theme.of(context).colorScheme.primary,
            textDecoration: TextDecoration.underline,
          ),
        },
        onLinkTap: (url, _, __) {
          if (url != null) {
            _launchUrl(url);
          }
        },
      );
    } else {
      return _buildTextWithClickableLinks(content, textStyle);
    }
  }

  Widget _buildAuthorsSection(Publication publication, AppLocalizations l10n) {
    return ExpandableAuthorsWidget(
      authors: publication.authors,
      uniqueKey: publication.key,
      expandedAuthors: _expandedAuthors,
      onToggle: (key) {
        setState(() {
          if (_expandedAuthors.contains(key)) {
            _expandedAuthors.remove(key);
          } else {
            _expandedAuthors.add(key);
          }
        });
      },
      threshold: 5,
      textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildAbstractSection(Publication publication, AppLocalizations l10n) {
    if (publication.abstractText == null || publication.abstractText!.isEmpty) {
      return const SizedBox.shrink();
    }

    final publicationKey = publication.key;
    final isExpanded = _expandedAbstracts.contains(publicationKey);
    final abstractText = publication.abstractText!;
    final isLongAbstract = abstractText.length > 250;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              SelectableText(
                l10n.abstract,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildAbstractContent(
            isExpanded || !isLongAbstract
                ? abstractText
                : '${abstractText.substring(0, 250)}...',
          ),
          if (isLongAbstract) ...[
            const SizedBox(height: 12),
            Container(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedAbstracts.remove(publicationKey);
                    } else {
                      _expandedAbstracts.add(publicationKey);
                    }
                  });
                },
                icon: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                label: Text(
                  isExpanded ? l10n.showLess : l10n.readMore,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.centerLeft,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCitationSection(Publication publication, AppLocalizations l10n) {
    final publicationKey = publication.key;
    final isExpanded = _expandedCitations.contains(publicationKey);
    final isLoading = _loadingCitations[publicationKey] == true;
    final citationMetadata = _citationMetadataCache[publicationKey] ?? [];
    final citationCount = publication.citationCount;

    if (!publication.hasLoadedCitations && citationCount == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_quote,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              SelectableText(
                l10n.citations,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Spacer(),
              if (citationCount != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(
                    l10n.citationCount(citationCount),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          if (citationCount == null) ...[
            SelectableText(
              l10n.noCitations,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ] else ...[
            if (!isExpanded) ...[
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: InkWell(
                  onTap: () => _launchUrl('https://opencitations.net/'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        l10n.citationsFrom,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.8),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Semantics(
                        label:
                            AppLocalizations.of(
                              context,
                            )?.openCitationsLogoAlt ??
                            'OpenCitations',
                        button: true,
                        child: ExcludeSemantics(
                          child: LazyImage(
                            assetPath: 'assets/images/icon_oc_positive.png',
                            height: 20,
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _expandedCitations.add(publicationKey);
                    });
                    if (publication.doi != null) {
                      _loadCitations(publication.doi!, publicationKey);
                    }
                  },
                  icon: const Icon(Icons.expand_more, size: 16),
                  label: Text(l10n.viewCitations),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
            ] else ...[
              if (isLoading) ...[
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 8),
                SelectableText(
                  l10n.loadingCitations,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ] else if (citationMetadata.isEmpty) ...[
                SelectableText(
                  l10n.noCitations,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ] else ...[
                for (final citation in citationMetadata)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          citation.displayTitle,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ExpandableAuthorsWidget(
                          authors: citation.authorsList,
                          uniqueKey:
                              'citation_${citation.id ?? citation.title}_$publicationKey',
                          expandedAuthors: _expandedCitationAuthors,
                          onToggle: (key) {
                            setState(() {
                              if (_expandedCitationAuthors.contains(key)) {
                                _expandedCitationAuthors.remove(key);
                              } else {
                                _expandedCitationAuthors.add(key);
                              }
                            });
                          },
                          threshold: 3,
                          textStyle: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (citation.displayVenue != 'Unknown Venue') ...[
                          SelectableText(
                            PublicationUtils.buildVenueWithDetails(
                              citation.displayVenue,
                              citation.volume,
                              citation.issue,
                              citation.page,
                            ),
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.tertiary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SelectableText(
                                citation.displayYear,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            if (citation.hasDoi) ...[
                              const Spacer(),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () => _launchUrl(citation.doiUrl),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.open_in_new,
                                          size: 12,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          l10n.viewUrl,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.copyWith(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                            decoration:
                                                TextDecoration.underline,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: 12),
              Container(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _expandedCitations.remove(publicationKey);
                    });
                  },
                  icon: const Icon(Icons.expand_less, size: 16),
                  label: Text(l10n.showLess),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      key: _publicationsSectionKey,
      margin: const EdgeInsets.symmetric(vertical: 32),
      padding: EdgeInsets.all(isMobile ? 20 : 64),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Semantics(
            header: true,
            child: SelectableText(
              l10n.publications,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              semanticsLabel: 'Section heading: ${l10n.publications}',
            ),
          ),
          const SizedBox(height: 16),
          SelectableText(
            l10n.publicationsDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (!_isLoading && _publications != null && _publications!.isNotEmpty)
            _buildCategoryFilter(l10n),
          const SizedBox(height: 24),
          _buildPublicationsList(l10n),
          if (!_isLoading &&
              _filteredPublications != null &&
              _filteredPublications!.isNotEmpty &&
              _totalPages > 1)
            _buildPaginationControls(l10n),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(AppLocalizations l10n) {
    final categoryKeys = _getAvailableCategoryKeys();
    final categoryMapping = _getCategoryMapping(l10n);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children:
          categoryKeys.map((categoryKey) {
            final categoryName = categoryMapping[categoryKey] ?? categoryKey;
            final isSelected = categoryKey == _selectedCategoryKey;
            return FilterChip(
              selected: isSelected,
              label: Text(categoryName),
              onSelected: (_) => _filterPublications(categoryKey, l10n),
              backgroundColor: Theme.of(context).colorScheme.surface,
              selectedColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
              checkmarkColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.3),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildPublicationsList(AppLocalizations l10n) {
    if (_isLoading) {
      return Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          SelectableText(
            l10n.loadingPublications,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
    }

    if (_error != null ||
        _filteredPublications == null ||
        _filteredPublications!.isEmpty) {
      return Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          SelectableText(
            _filteredPublications != null && _filteredPublications!.isEmpty
                ? l10n.noPublicationsForCategory
                : l10n.noPublications,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      );
    }

    return Column(
      children:
          _getCurrentPagePublications()
              .map((publication) => _buildPublicationCard(publication, l10n))
              .toList(),
    );
  }

  Widget _buildPublicationCard(Publication publication, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            publication.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          _buildAuthorsSection(publication, l10n),
          const SizedBox(height: 12),
          if (publication.itemType != 'computerProgram' &&
              publication.displayVenue != 'Unknown Venue') ...[
            SelectableText(
              PublicationUtils.shouldShowVenueDetails(publication.itemType)
                  ? PublicationUtils.buildVenueWithDetails(
                    publication.displayVenue,
                    publication.volume,
                    publication.issue,
                    publication.pages,
                  )
                  : publication.displayVenue,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(
                  publication.getCategoryDisplayName(l10n),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.tertiary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(
                  publication.displayYear,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          _buildAbstractSection(publication, l10n),
          if (publication.hasDoi) _buildCitationSection(publication, l10n),
          if (PublicationUtils.shouldShowLaunchButton(publication)) ...[
            const SizedBox(height: 16),
            _buildLaunchButton(publication, l10n),
          ],
        ],
      ),
    );
  }

  Widget _buildPaginationControls(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 0 ? _previousPage : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: l10n.previousPage,
          ),
          const SizedBox(width: 16),
          ...List.generate(_totalPages, (index) {
            final isCurrentPage = index == _currentPage;
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _goToPage(index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isCurrentPage
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          isCurrentPage
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color:
                          isCurrentPage
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                      fontWeight:
                          isCurrentPage ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 16),
          IconButton(
            onPressed: _currentPage < _totalPages - 1 ? _nextPage : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: l10n.nextPage,
          ),
        ],
      ),
    );
  }
}
