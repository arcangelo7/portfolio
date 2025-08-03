import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';
import '../l10n/app_localizations.dart';
import '../models/publication.dart';
import '../services/zotero_service.dart';

class PublicationsSection extends StatefulWidget {
  final ZoteroService? zoteroService;

  const PublicationsSection({super.key, this.zoteroService});

  @override
  State<PublicationsSection> createState() => _PublicationsSectionState();
}

class _PublicationsSectionState extends State<PublicationsSection> {
  late final ZoteroService _zoteroService;
  List<Publication>? _publications;
  List<Publication>? _filteredPublications;
  bool _isLoading = true;
  String? _error;
  String _selectedCategoryKey = 'all';
  final Set<String> _expandedAuthors = {};
  final Set<String> _expandedAbstracts = {};
  int _currentPage = 0;
  static const int _publicationsPerPage = 10;
  final GlobalKey _publicationsSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _zoteroService = widget.zoteroService ?? ZoteroService();
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

    final sortedCategories =
        categories.where((cat) => cat != 'all').toList()..sort();
    return ['all', ...sortedCategories];
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  bool _containsHtml(String text) {
    final htmlTags = RegExp(r'<[^>]+>');
    return htmlTags.hasMatch(text);
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

    if (_containsHtml(content)) {
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
    const int authorThreshold = 5;
    final authors = publication.authors;
    final publicationKey = publication.key;
    final isExpanded = _expandedAuthors.contains(publicationKey);

    if (authors.length <= authorThreshold) {
      return Text(
        publication.authorsString,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isExpanded
              ? publication.authorsString
              : '${authors.take(3).join(', ')} ${l10n.andMoreAuthors(authors.length - 3)}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                if (isExpanded) {
                  _expandedAuthors.remove(publicationKey);
                } else {
                  _expandedAuthors.add(publicationKey);
                }
              });
            },
            icon: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: Text(
              isExpanded ? l10n.showLess : l10n.showAllAuthors,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: Alignment.centerLeft,
            ),
          ),
        ),
      ],
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
              Text(
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      key: _publicationsSectionKey,
      margin: const EdgeInsets.symmetric(vertical: 32),
      padding: const EdgeInsets.all(64),
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
          Text(
            l10n.publications,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
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
          Text(
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
          Text(
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
          Text(
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
            Text(
              publication.displayVenue,
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
                child: Text(
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
                child: Text(
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
          if (publication.doi != null || publication.url != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed:
                  () => _launchUrl(
                    publication.doi != null
                        ? 'https://doi.org/${publication.doi}'
                        : publication.url!,
                  ),
              icon: const Icon(Icons.open_in_new, size: 16),
              label: Text(publication.getViewButtonText(l10n)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                foregroundColor: Theme.of(context).colorScheme.onTertiary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
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
