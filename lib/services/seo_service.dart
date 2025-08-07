import 'package:web/web.dart';
import 'package:flutter/foundation.dart';
import '../l10n/app_localizations.dart';

class SEOService {
  static void updateMetaTags(AppLocalizations l10n, String languageCode) {
    if (!kIsWeb) return;

    // Update title
    document.title = l10n.appTitle;

    // Update meta description
    _updateMetaTag('name', 'description', l10n.seoDescription);
    _updateMetaTag('property', 'og:title', l10n.appTitle);
    _updateMetaTag('property', 'og:description', l10n.seoDescription);
    _updateMetaTag('property', 'twitter:title', l10n.appTitle);
    _updateMetaTag('property', 'twitter:description', l10n.seoDescription);

    // Update language-specific meta tags
    _updateMetaTag('property', 'og:locale', _getLocaleCode(languageCode));

    // Add hreflang links
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

  static void addStructuredDataForPublications(List<Map<String, dynamic>> publications) {
    if (!kIsWeb) return;

    // Remove existing publication structured data
    final existingScripts = document.querySelectorAll('script[type="application/ld+json"][data-type="publications"]');
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
      'publisherOf': publications.map((pub) => {
        '@type': _getPublicationType(pub['type']),
        'name': pub['title'],
        'author': {'@type': 'Person', 'name': 'Arcangelo Massari'},
        if (pub['doi'] != null) 'identifier': {
          '@type': 'PropertyValue',
          'propertyID': 'DOI',
          'value': pub['doi']
        },
        if (pub['datePublished'] != null) 'datePublished': pub['datePublished'],
        if (pub['venue'] != null) 'publisher': {'@type': 'Organization', 'name': pub['venue']},
      }).toList(),
    };

    final script = HTMLScriptElement();
    script.type = 'application/ld+json';
    script.setAttribute('data-type', 'publications');
    script.text = _jsonEncode(publicationsData);
    document.head?.appendChild(script);
  }

  static String _getPublicationType(String? type) {
    switch (type?.toLowerCase()) {
      case 'journal-article':
        return 'ScholarlyArticle';
      case 'book':
        return 'Book';
      case 'chapter':
      case 'book-section':
        return 'Chapter';
      case 'conference-paper':
        return 'ScholarlyArticle';
      case 'thesis':
        return 'Thesis';
      case 'report':
        return 'Report';
      default:
        return 'CreativeWork';
    }
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
      buffer.write('"${value.replaceAll('"', '\\"').replaceAll('\n', '\\n').replaceAll('\r', '\\r')}"');
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