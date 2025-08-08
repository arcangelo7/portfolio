import 'package:web/web.dart';
import 'package:flutter/foundation.dart';
import '../l10n/app_localizations.dart';

class SEOService {
  static void updateMetaTags(AppLocalizations l10n, String languageCode) {
    if (!kIsWeb) return;
    // Avoid DOM mutations during development/hot-reload to reduce engine view churn
    if (!kReleaseMode) return;

    document.title = l10n.appTitle;

    document.documentElement?.setAttribute('lang', languageCode);

    _updateMetaTag('name', 'description', l10n.seoDescription);
    _updateMetaTag('property', 'og:title', l10n.appTitle);
    _updateMetaTag('property', 'og:description', l10n.seoDescription);
    _updateMetaTag('property', 'twitter:title', l10n.appTitle);
    _updateMetaTag('property', 'twitter:description', l10n.seoDescription);

    _updateMetaTag('property', 'og:locale', _getLocaleCode(languageCode));

    // Canonical and share URLs (self-referencing canonicals for i18n variants)
    final origin = window.location.origin;
    final canonicalUrl =
        languageCode == 'en' ? '$origin/' : '$origin/?lang=$languageCode';
    _updateCanonicalLink(canonicalUrl);
    _updateMetaTag('property', 'og:url', canonicalUrl);
    _updateMetaTag('property', 'twitter:url', canonicalUrl);

    _updateHrefLangLinks(languageCode);

    // Ensure semantic headings exist for SEO (visually hidden, localized)
    _ensureVisuallyHiddenCss();
    _updateSemanticHeadings(l10n);
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

  static void _updateCanonicalLink(String href) {
    final existing = document.querySelector('link[rel="canonical"]');
    if (existing != null) {
      existing.setAttribute('href', href);
    } else {
      final link = HTMLLinkElement();
      link.rel = 'canonical';
      link.href = href;
      document.head?.appendChild(link);
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

  /// Adds a small CSS utility to hide elements visually while keeping them
  /// available to assistive technologies and crawlers.
  static void _ensureVisuallyHiddenCss() {
    final existingStyle = document.getElementById('semantic-headings-style');
    if (existingStyle != null) return;

    final style = HTMLStyleElement();
    style.id = 'semantic-headings-style';
    style.textContent =
        '.visually-hidden{position:absolute!important;width:1px!important;height:1px!important;padding:0!important;margin:-1px!important;overflow:hidden!important;clip:rect(0,0,0,0)!important;white-space:nowrap!important;border:0!important;}';
    document.head?.appendChild(style);
  }

  /// Creates or updates a container with semantic headings (h1/h2/h3) that
  /// reflect the visible sections of the app. These headings are visually
  /// hidden to avoid layout changes but improve SEO and document outline.
  static void _updateSemanticHeadings(AppLocalizations l10n) {
    // Ensure a single container instance
    HTMLDivElement container;
    final existing = document.getElementById('semantic-headings');
    if (existing != null) {
      container = existing as HTMLDivElement;
      // Clear previous content to avoid duplicates on language change
      while (container.firstChild != null) {
        container.removeChild(container.firstChild!);
      }
    } else {
      container = HTMLDivElement();
      container.id = 'semantic-headings';
      container.className = 'visually-hidden';
      document.body?.appendChild(container);
    }

    // Helper to create and append a heading
    void addHeading(String tag, String id, String text) {
      final element = document.createElement(tag) as HTMLElement;
      element.id = id;
      element.textContent = text;
      container.appendChild(element);
    }

    // h1: Page title
    addHeading('h1', 'h1-title', l10n.appTitle);

    // h2: Top sections
    addHeading('h2', 'h2-about', l10n.aboutMe);
    addHeading('h2', 'h2-work', l10n.workExperience);
    addHeading('h2', 'h2-education', l10n.education);
    addHeading('h2', 'h2-conferences', l10n.conferencesAndSeminars);
    addHeading('h2', 'h2-skills', l10n.skills);
    addHeading('h2', 'h2-publications', l10n.publications);
    addHeading('h2', 'h2-astrogods', l10n.astroGodsTitle);
    addHeading('h2', 'h2-faq', l10n.frequentlyAskedQuestions);
    addHeading('h2', 'h2-contact', l10n.getInTouch);
  }

  static void addStructuredDataForPublications(
    List<Map<String, dynamic>> publications,
  ) {
    if (!kIsWeb) return;
    if (!kReleaseMode) return;

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

  static void addFAQStructuredData(
    List<Map<String, String>> faqs,
    AppLocalizations l10n,
  ) {
    if (!kIsWeb) return;
    if (!kReleaseMode) return;

    // Remove existing FAQ structured data
    final existingScripts = document.querySelectorAll(
      'script[type="application/ld+json"][data-type="faq"]',
    );
    for (var i = 0; i < existingScripts.length; i++) {
      final element = existingScripts.item(i);
      if (element != null) {
        element.parentNode?.removeChild(element);
      }
    }

    if (faqs.isEmpty) return;

    // Create structured data for FAQ
    final faqData = {
      '@context': 'https://schema.org',
      '@type': 'FAQPage',
      'mainEntity':
          faqs
              .map(
                (faq) => {
                  '@type': 'Question',
                  'name': faq['question'],
                  'acceptedAnswer': {'@type': 'Answer', 'text': faq['answer']},
                },
              )
              .toList(),
    };

    final script = HTMLScriptElement();
    script.type = 'application/ld+json';
    script.setAttribute('data-type', 'faq');
    script.text = _jsonEncode(faqData);
    document.head?.appendChild(script);
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
