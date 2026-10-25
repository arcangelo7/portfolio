// SPDX-FileCopyrightText: 2025-2026 Arcangelo Massari <info@arcangelomassari.com>
//
// SPDX-License-Identifier: ISC

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
    _updateMetaTag('property', 'og:description', l10n.professionalTitle);
    _updateMetaTag('property', 'twitter:title', l10n.appTitle);
    _updateMetaTag('property', 'twitter:description', l10n.professionalTitle);

    _updateMetaTag('property', 'og:locale', _getLocaleCode(languageCode));

    // Canonical and share URLs (self-referencing canonicals for i18n variants)
    final origin = window.location.origin;
    final canonicalUrl = languageCode == 'en'
        ? '$origin/'
        : '$origin/?lang=$languageCode';
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
    style.textContent = '.visually-hidden{position:absolute!important;width:1px!important;height:1px!important;padding:0!important;margin:-1px!important;overflow:hidden!important;clip:rect(0,0,0,0)!important;white-space:nowrap!important;border:0!important;}';
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
    addHeading('h2', 'h2-contact', l10n.getInTouch);
  }
}
