import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../models/publication.dart';
import '../services/zotero_service.dart';

class PublicationsSection extends StatefulWidget {
  const PublicationsSection({super.key});

  @override
  State<PublicationsSection> createState() => _PublicationsSectionState();
}

class _PublicationsSectionState extends State<PublicationsSection> {
  final ZoteroService _zoteroService = ZoteroService();
  List<Publication>? _publications;
  List<Publication>? _filteredPublications;
  bool _isLoading = true;
  String? _error;
  String _selectedCategoryKey = 'all';

  @override
  void initState() {
    super.initState();
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
      if (categoryKey == 'all') {
        _filteredPublications = _publications;
      } else {
        _filteredPublications = _publications!
            .where((pub) => pub.itemType == categoryKey)
            .toList();
      }
    });
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
    };
  }

  List<String> _getAvailableCategoryKeys() {
    if (_publications == null) return ['all'];
    
    final categories = <String>{'all'};
    for (final pub in _publications!) {
      categories.add(pub.itemType);
    }
    
    final sortedCategories = categories.where((cat) => cat != 'all').toList()..sort();
    return ['all', ...sortedCategories];
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 32),
      padding: const EdgeInsets.all(64),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
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
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (!_isLoading && _publications != null && _publications!.isNotEmpty)
            _buildCategoryFilter(l10n),
          const SizedBox(height: 24),
          _buildPublicationsList(l10n),
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
      children: categoryKeys.map((categoryKey) {
        final categoryName = categoryMapping[categoryKey] ?? categoryKey;
        final isSelected = categoryKey == _selectedCategoryKey;
        return FilterChip(
          selected: isSelected,
          label: Text(categoryName),
          onSelected: (_) => _filterPublications(categoryKey, l10n),
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          checkmarkColor: Theme.of(context).colorScheme.primary,
          labelStyle: TextStyle(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
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

    if (_error != null || _filteredPublications == null || _filteredPublications!.isEmpty) {
      return Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _filteredPublications != null && _filteredPublications!.isEmpty
                ? l10n.noPublicationsForCategory
                : l10n.noPublications,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      );
    }

    return Column(
      children: _filteredPublications!
          .take(10)
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
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
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
          Text(
            publication.authorsString,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  publication.getCategoryDisplayName(l10n),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  publication.displayVenue,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  publication.displayYear,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
              ),
            ],
          ),
          if (publication.abstractText != null && publication.abstractText!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              publication.abstractText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (publication.doi != null || publication.url != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _launchUrl(
                publication.doi != null 
                    ? 'https://doi.org/${publication.doi}'
                    : publication.url!
              ),
              icon: const Icon(Icons.open_in_new, size: 16),
              label: Text(publication.getViewButtonText(l10n)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                foregroundColor: Theme.of(context).colorScheme.onTertiary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}