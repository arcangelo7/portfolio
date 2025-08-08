import 'package:web/web.dart';
import 'package:flutter/foundation.dart';
import '../l10n/app_localizations.dart';

class SEOService {
  static void updateMetaTags(AppLocalizations l10n, String languageCode) {
    if (!kIsWeb) return;

    document.title = l10n.appTitle;

    document.documentElement?.setAttribute('lang', languageCode);

    _updateMetaTag('name', 'description', l10n.seoDescription);
    _updateMetaTag('property', 'og:title', l10n.appTitle);
    _updateMetaTag('property', 'og:description', l10n.seoDescription);
    _updateMetaTag('property', 'twitter:title', l10n.appTitle);
    _updateMetaTag('property', 'twitter:description', l10n.seoDescription);

    _updateMetaTag('property', 'og:locale', _getLocaleCode(languageCode));

    _updateHrefLangLinks(languageCode);
  }

  static void _updateMetaTag(String attribute, String value, String content) {
    final existing = document.querySelector('meta[$attribute="$value"]');
    if (existing != null) {
      existing.setAttribute('content', content);
    } else {
      final meta = HTMLMetaElement();
      meta.setAttribute(attribute, value);
      meta.content = content;
      document.head?.appendChild(meta);
    }
  }

  static String _getLocaleCode(String languageCode) {
    switch (languageCode) {
      case 'it':
        return 'it_IT';
      case 'es':
        return 'es_ES';
      case 'en':
      default:
        return 'en_US';
    }
  }

  static void _updateHrefLangLinks(String currentLang) {
    // Remove existing hreflang links
    final hrefLangLinks = document.querySelectorAll('link[hreflang]');
    for (var i = 0; i < hrefLangLinks.length; i++) {
      final element = hrefLangLinks.item(i);
      if (element != null) {
        element.parentNode?.removeChild(element);
      }
    }

    // Add new hreflang links
    final baseUrl = window.location.origin;
    final languages = ['en', 'it', 'es'];

    for (final lang in languages) {
      final link = HTMLLinkElement();
      link.rel = 'alternate';
      link.href = '$baseUrl/?lang=$lang';
      link.setAttribute('hreflang', lang);
      document.head?.appendChild(link);
    }

    // Add x-default
    final defaultLink = HTMLLinkElement();
    defaultLink.rel = 'alternate';
    defaultLink.href = baseUrl;
    defaultLink.setAttribute('hreflang', 'x-default');
    document.head?.appendChild(defaultLink);
  }

  static void addStructuredDataForPublications(
    List<Map<String, dynamic>> publications,
  ) {
    if (!kIsWeb) return;

    // Remove existing publication structured data
    final existingScripts = document.querySelectorAll(
      'script[type="application/ld+json"][data-type="publications"]',
    );
    for (var i = 0; i < existingScripts.length; i++) {
      final element = existingScripts.item(i);
      if (element != null) {
        element.parentNode?.removeChild(element);
      }
    }

    if (publications.isEmpty) return;

    // Create structured data for publications
    final publicationsData = {
      '@context': 'https://schema.org',
      '@type': 'Person',
      'name': 'Arcangelo Massari',
      'jobTitle': 'PhD Candidate in Cultural Heritage in the Digital Ecosystem',
      'affiliation': {
        '@type': 'Organization',
        'name': 'University of Bologna',
        'url': 'https://www.unibo.it',
      },
      'url': 'https://www.unibo.it/sitoweb/arcangelo.massari/en',
      'sameAs': [
        'https://orcid.org/0000-0002-8420-0696',
        'https://github.com/arcangelo7',
        'https://www.linkedin.com/in/arcangelo-massari-4a736822b',
      ],
      'creator':
          publications
              .where(
                (pub) => pub['doi'] != null && pub['doi'].toString().isNotEmpty,
              )
              .map(
                (pub) => {
                  '@type': _getPublicationType(pub['type']),
                  'name': pub['title'],
                  'author': _buildAuthors(pub['authors']),
                  'identifier': [
                    {
                      '@type': 'PropertyValue',
                      'propertyID': 'DOI',
                      'value': pub['doi'],
                    },
                  ],
                  if (pub['url'] != null && pub['url'].toString().isNotEmpty)
                    'url': pub['url'],
                  if (pub['datePublished'] != null)
                    'datePublished': _normalizeDate(pub['datePublished']),
                  if (pub['venue'] != null || pub['journal'] != null)
                    'publisher': {
                      '@type': 'Organization',
                      'name': pub['venue'] ?? pub['journal'],
                    },
                  if (pub['abstract'] != null &&
                      pub['abstract'].toString().isNotEmpty)
                    'description': pub['abstract'],
                  if (pub['volume'] != null) 'volumeNumber': pub['volume'],
                  if (pub['issue'] != null) 'issueNumber': pub['issue'],
                  if (pub['pages'] != null) 'pagination': pub['pages'],
                  'inLanguage': 'en',
                  'genre': _getGenre(pub['type']),
                },
              )
              .toList(),
    };

    final script = HTMLScriptElement();
    script.type = 'application/ld+json';
    script.setAttribute('data-type', 'publications');
    script.text = _jsonEncode(publicationsData);
    document.head?.appendChild(script);
  }

  static String _getPublicationType(String? type) {
    switch (type) {
      case 'journalArticle':
        return 'ScholarlyArticle';
      case 'book':
        return 'Book';
      case 'chapter':
      case 'bookSection':
        return 'Chapter';
      case 'conferencePaper':
        return 'ScholarlyArticle';
      case 'thesis':
        return 'Thesis';
      case 'report':
        return 'Report';
      case 'computerProgram':
        return 'SoftwareApplication';
      case 'presentation':
        return 'PresentationDigitalDocument';
      default:
        return 'CreativeWork';
    }
  }

  static String _getGenre(String? type) {
    switch (type) {
      case 'journalArticle':
        return 'research article';
      case 'conferencePaper':
        return 'conference paper';
      case 'book':
        return 'book';
      case 'bookSection':
        return 'book chapter';
      case 'thesis':
        return 'thesis';
      case 'report':
        return 'research report';
      case 'computerProgram':
        return 'software';
      case 'presentation':
        return 'presentation';
      default:
        return 'publication';
    }
  }

  static String _normalizeDate(String? date) {
    if (date == null || date.isEmpty) return '';

    // Handle various date formats
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) {
      return date; // Already ISO format
    }
    if (RegExp(r'^\d{2}/\d{4}$').hasMatch(date)) {
      final parts = date.split('/');
      return '${parts[1]}-${parts[0].padLeft(2, '0')}-01';
    }
    if (RegExp(r'^\d{4}$').hasMatch(date)) {
      return '$date-01-01'; // Year only
    }

    // Try to extract year
    final yearMatch = RegExp(r'\d{4}').firstMatch(date);
    if (yearMatch != null) {
      return '${yearMatch.group(0)}-01-01';
    }

    return date;
  }

  static List<Map<String, String>> _buildAuthors(dynamic authors) {
    if (authors == null) {
      return [
        {'@type': 'Person', 'name': 'Arcangelo Massari'},
      ];
    }

    if (authors is List) {
      final authorList =
          authors
              .where((author) => author != null && author.toString().isNotEmpty)
              .map((author) => {'@type': 'Person', 'name': author.toString()})
              .toList();

      return authorList.isNotEmpty
          ? authorList
          : [
            {'@type': 'Person', 'name': 'Arcangelo Massari'},
          ];
    }

    return [
      {'@type': 'Person', 'name': 'Arcangelo Massari'},
    ];
  }

  static String _jsonEncode(Map<String, dynamic> data) {
    // Simple JSON encoding for web
    final buffer = StringBuffer();
    _encodeValue(data, buffer);
    return buffer.toString();
  }

  static void _encodeValue(dynamic value, StringBuffer buffer) {
    if (value == null) {
      buffer.write('null');
    } else if (value is String) {
      buffer.write(
        '"${value.replaceAll('"', '\\"').replaceAll('\n', '\\n').replaceAll('\r', '\\r')}"',
      );
    } else if (value is num) {
      buffer.write(value.toString());
    } else if (value is bool) {
      buffer.write(value.toString());
    } else if (value is List) {
      buffer.write('[');
      for (int i = 0; i < value.length; i++) {
        if (i > 0) buffer.write(',');
        _encodeValue(value[i], buffer);
      }
      buffer.write(']');
    } else if (value is Map) {
      buffer.write('{');
      bool first = true;
      for (final entry in value.entries) {
        if (!first) buffer.write(',');
        first = false;
        buffer.write('"${entry.key}":');
        _encodeValue(entry.value, buffer);
      }
      buffer.write('}');
    }
  }
}
