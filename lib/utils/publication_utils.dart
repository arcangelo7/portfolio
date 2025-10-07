import '../models/publication.dart';
import '../l10n/app_localizations.dart';

class PublicationUtils {
  /// Build venue display with volume, issue and pages information
  static String buildVenueWithDetails(String venue, String? volume, String? issue, String? pages) {
    final parts = <String>[];
    
    if (volume != null && volume.isNotEmpty) {
      parts.add(volume);
    }
    
    if (issue != null && issue.isNotEmpty) {
      parts.add('($issue)');
    }
    
    if (pages != null && pages.isNotEmpty) {
      parts.add('pp. $pages');
    }
    
    if (parts.isNotEmpty) {
      return '$venue, ${parts.join(', ')}';
    }
    
    return venue;
  }

  /// Check if publication type should show venue details (volume, issue, pages)
  static bool shouldShowVenueDetails(String itemType) {
    return itemType == 'journalArticle' || 
           itemType == 'bookSection' || 
           itemType == 'conferencePaper';
  }

  /// Check if a publication should show a launch button (DOI or URL)
  static bool shouldShowLaunchButton(Publication publication) {
    return (publication.doi != null && publication.doi!.isNotEmpty) ||
           (publication.url != null && publication.url!.isNotEmpty);
  }

  /// Get the URL to launch for a publication (DOI takes precedence over URL)
  static String getLaunchUrl(Publication publication) {
    if (publication.doi != null && publication.doi!.isNotEmpty) {
      return 'https://doi.org/${publication.doi}';
    } else {
      return publication.url!;
    }
  }

  /// Normalize URL by adding protocol if missing
  static String normalizeUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      if (url.startsWith('www.')) {
        return 'https://$url';
      } else if (url.contains('@')) {
        return 'mailto:$url';
      } else {
        return 'https://$url';
      }
    }
    return url;
  }

  /// Check if text contains HTML tags
  static bool containsHtml(String text) {
    final htmlTags = RegExp(r'<[^>]+>');
    return htmlTags.hasMatch(text);
  }

  /// Get category display name with localization
  static String getCategoryDisplayName(String categoryKey, AppLocalizations l10n) {
    switch (categoryKey) {
      case 'journalArticle':
        return l10n.categoryJournalArticle;
      case 'conferencePaper':
        return l10n.categoryConferencePaper;
      case 'bookSection':
        return l10n.categoryBookSection;
      case 'computerProgram':
        return l10n.categorySoftware;
      case 'presentation':
        return l10n.categoryPresentation;
      case 'thesis':
        return l10n.categoryThesis;
      case 'report':
        return l10n.categoryReport;
      default:
        return categoryKey;
    }
  }

  /// Get ordered list of publication categories by importance
  static List<String> getCategoryOrder() {
    return [
      'journalArticle',
      'conferencePaper',
      'bookSection',
      'thesis',
      'presentation',
      'report',
      'computerProgram',
    ];
  }

  /// Group publications by category and return them in order of importance
  static Map<String, List<Publication>> groupPublicationsByCategory(List<Publication> publications) {
    final Map<String, List<Publication>> grouped = {};
    final categoryOrder = getCategoryOrder();

    // Initialize groups for all categories
    for (final category in categoryOrder) {
      grouped[category] = [];
    }

    // Group publications by category
    for (final publication in publications) {
      final category = publication.itemType;
      if (grouped.containsKey(category)) {
        grouped[category]!.add(publication);
      } else {
        // For unknown categories, add them to a separate list
        grouped.putIfAbsent('other', () => []).add(publication);
      }
    }

    // Remove empty categories
    grouped.removeWhere((key, value) => value.isEmpty);

    return grouped;
  }
}