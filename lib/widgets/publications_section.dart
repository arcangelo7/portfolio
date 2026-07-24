// SPDX-FileCopyrightText: 2025 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../controllers/publications_controller.dart';
import '../l10n/app_localizations.dart';
import '../models/publication.dart';
import '../services/opencitations_meta_service.dart';
import '../utils/publication_utils.dart';
import '../utils/responsive.dart';
import 'expandable_authors_widget.dart';
import 'lazy_image.dart';
import 'section_header.dart';

class PublicationsSection extends StatefulWidget {
  static const int chunkCount = 5;

  final PublicationsController controller;
  final int? chunkIndex;
  final VoidCallback? onPageChanged;

  const PublicationsSection({
    super.key,
    required this.controller,
    this.chunkIndex,
    this.onPageChanged,
  }) : assert(
         chunkIndex == null || (chunkIndex >= 0 && chunkIndex < chunkCount),
       );

  @override
  State<PublicationsSection> createState() => _PublicationsSectionState();
}

class _PublicationsSectionState extends State<PublicationsSection> {
  final GlobalKey _publicationsSectionKey = GlobalKey();
  late final TextEditingController _searchController;

  List<Publication>? get _publications => widget.controller.publications;
  List<Publication>? get _filteredPublications =>
      widget.controller.filteredPublications;
  bool get _isLoading => widget.controller.isLoading;
  String? get _error => widget.controller.error;
  String get _selectedCategoryKey => widget.controller.selectedCategoryKey;
  String get _searchQuery => widget.controller.searchQuery;
  Set<String> get _expandedAuthors => widget.controller.expandedAuthors;
  Set<String> get _expandedAbstracts => widget.controller.expandedAbstracts;
  Set<String> get _expandedCitations => widget.controller.expandedCitations;
  Set<String> get _expandedCitationAuthors =>
      widget.controller.expandedCitationAuthors;
  Map<String, List<CitationMetadata>> get _citationMetadataCache =>
      widget.controller.citationMetadataCache;
  Map<String, bool> get _loadingCitations => widget.controller.loadingCitations;
  Map<String, String?> get _gitHubDescriptionCache =>
      widget.controller.gitHubDescriptionCache;
  Map<String, bool> get _loadingGitHubDescriptions =>
      widget.controller.loadingGitHubDescriptions;
  int? get _totalCitationCount => widget.controller.totalCitationCount;
  bool get _isLoadingTotalCitations =>
      widget.controller.isLoadingTotalCitations;
  int get _currentPage => widget.controller.currentPage;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.controller.searchQuery,
    );
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(PublicationsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      return;
    }
    oldWidget.controller.removeListener(_onControllerChanged);
    widget.controller.addListener(_onControllerChanged);
    _searchController.text = widget.controller.searchQuery;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _filterPublications(String categoryKey) {
    widget.controller.selectCategory(categoryKey);
  }

  void _onSearchChanged(String query) {
    widget.controller.updateSearch(query);
  }

  void _scrollToPublications() {
    if (widget.onPageChanged case final onPageChanged?) {
      onPageChanged();
      return;
    }
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
    widget.controller.nextPage();
    _scrollToPublications();
  }

  void _previousPage() {
    widget.controller.previousPage();
    _scrollToPublications();
  }

  void _goToPage(int page) {
    widget.controller.goToPage(page);
    _scrollToPublications();
  }

  List<Publication> _getCurrentPagePublications() {
    final publications = widget.controller.currentPagePublications;
    final chunkIndex = widget.chunkIndex;
    if (chunkIndex == null) {
      return publications;
    }

    final cardsPerChunk =
        PublicationsController.publicationsPerPage ~/
        PublicationsSection.chunkCount;
    final start = chunkIndex * cardsPerChunk;
    if (start >= publications.length) {
      return [];
    }
    final end = (start + cardsPerChunk).clamp(0, publications.length).toInt();
    return publications.sublist(start, end);
  }

  int get _totalPages => widget.controller.totalPages;

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
    return widget.controller.availableCategoryKeys;
  }

  Future<void> _launchUrl(String url) async {
    await widget.controller.openUrl(url);
  }

  Color _neutralBorderColor([double alpha = 0.12]) {
    return Theme.of(context).colorScheme.onSurface.withValues(alpha: alpha);
  }

  Color _neutralBackgroundColor([double alpha = 0.06]) {
    return Theme.of(context).colorScheme.onSurface.withValues(alpha: alpha);
  }

  Future<void> _handleLaunchButtonPress(Publication publication) async {
    final url = PublicationUtils.getLaunchUrl(publication);
    await _launchUrl(url);
  }

  Widget _buildLaunchButton(Publication publication, AppLocalizations l10n) {
    return ElevatedButton.icon(
      onPressed: () => _handleLaunchButtonPress(publication),
      icon: const Icon(Icons.open_in_new, size: 16),
      label: Text(publication.getViewButtonText(l10n)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
        onLinkTap: (url, _, _) {
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
      onToggle: widget.controller.toggleAuthors,
      threshold: 5,
      textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildAbstractSection(Publication publication, AppLocalizations l10n) {
    if (publication.itemType == 'computerProgram') {
      return _buildSoftwareDescriptionSection(publication, l10n);
    }

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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _neutralBorderColor()),
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
                  widget.controller.toggleAbstract(publicationKey);
                },
                icon: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                label: Text(
                  isExpanded ? l10n.showLess : l10n.readMore,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
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

  Widget _buildSoftwareDescriptionSection(
    Publication publication,
    AppLocalizations l10n,
  ) {
    final key = publication.key;

    if (!_gitHubDescriptionCache.containsKey(key) &&
        _loadingGitHubDescriptions[key] != true) {
      widget.controller.loadGitHubDescription(publication);
    }

    final isLoading = _loadingGitHubDescriptions[key] == true;
    final description = _gitHubDescriptionCache[key];

    if (isLoading) {
      return Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _neutralBorderColor()),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.loadingDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (description == null || description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _neutralBorderColor()),
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
                l10n.description,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SelectableText(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.6,
            ),
          ),
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

    if ((!publication.hasLoadedCitations && citationCount == null) ||
        citationCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _neutralBorderColor()),
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
                    color: _neutralBackgroundColor(),
                    borderRadius: BorderRadius.circular(8),
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
                    widget.controller.expandCitations(publicationKey);
                    if (publication.doi != null) {
                      widget.controller.loadCitations(
                        publication.doi!,
                        publicationKey,
                      );
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
                      border: Border.all(color: _neutralBorderColor(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          citation.displayTitle,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
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
                          onToggle: widget.controller.toggleCitationAuthors,
                          threshold: 3,
                          textStyle: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
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
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.8),
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
                                color: _neutralBackgroundColor(),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SelectableText(
                                citation.displayYear,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
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
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          l10n.viewUrl,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(
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
                    widget.controller.collapseCitations(publicationKey);
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
    final isMobile = Responsive.isMobile(context);
    final chunkIndex = widget.chunkIndex;
    final isFirstChunk = chunkIndex == null || chunkIndex == 0;
    final isLastChunk =
        chunkIndex == null || chunkIndex == PublicationsSection.chunkCount - 1;

    return Container(
      key: isFirstChunk ? _publicationsSectionKey : null,
      margin: EdgeInsets.only(
        top: isFirstChunk ? 32 : 0,
        bottom: isLastChunk ? 32 : 0,
      ),
      padding: EdgeInsets.fromLTRB(
        isMobile ? 20 : 64,
        isFirstChunk ? (isMobile ? 20 : 64) : 0,
        isMobile ? 20 : 64,
        isLastChunk ? (isMobile ? 20 : 64) : 0,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: chunkIndex == null
            ? [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          if (isFirstChunk) ...[
            SectionHeader(title: l10n.publications),
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
            if (_isLoadingTotalCitations || _totalCitationCount != null) ...[
              const SizedBox(height: 24),
              _buildTotalCitationCountWidget(l10n),
            ],
            const SizedBox(height: 32),
            if (!_isLoading &&
                _publications != null &&
                _publications!.isNotEmpty) ...[
              _buildSearchBar(l10n),
              const SizedBox(height: 24),
              _buildCategoryFilter(l10n),
            ],
            const SizedBox(height: 24),
          ],
          if (isFirstChunk ||
              (!_isLoading &&
                  _filteredPublications != null &&
                  _filteredPublications!.isNotEmpty))
            _buildPublicationsList(l10n),
          if (isLastChunk &&
              !_isLoading &&
              _filteredPublications != null &&
              _filteredPublications!.isNotEmpty &&
              _totalPages > 1)
            _buildPaginationControls(l10n),
          if (isLastChunk) const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTotalCitationCountWidget(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: _neutralBackgroundColor(),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _neutralBorderColor(), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.format_quote_rounded,
            size: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          if (_isLoadingTotalCitations) ...[
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            SelectableText(
              l10n.calculatingTotalCitations,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else if (_totalCitationCount != null) ...[
            SelectableText(
              l10n.totalCitations(_totalCitationCount!),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: l10n.searchPublications,
          hintStyle: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.primary,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: _neutralBorderColor(), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
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
      children: categoryKeys.map((categoryKey) {
        final categoryName = categoryMapping[categoryKey] ?? categoryKey;
        final isSelected = categoryKey == _selectedCategoryKey;
        return FilterChip(
          selected: isSelected,
          label: Text(categoryName),
          onSelected: (_) => _filterPublications(categoryKey),
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.2),
          checkmarkColor: Theme.of(context).colorScheme.primary,
          labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : _neutralBorderColor(),
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
      children: _getCurrentPagePublications()
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
        borderRadius: BorderRadius.circular(8),
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
                  color: _neutralBackgroundColor(),
                  borderRadius: BorderRadius.circular(8),
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
                  color: _neutralBackgroundColor(),
                  borderRadius: BorderRadius.circular(8),
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
                    color: isCurrentPage
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCurrentPage
                          ? Theme.of(context).colorScheme.primary
                          : _neutralBorderColor(),
                    ),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: isCurrentPage
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: isCurrentPage
                          ? FontWeight.bold
                          : FontWeight.normal,
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
