import '../l10n/app_localizations.dart';

import 'seo_service_stub.dart'
    if (dart.library.js_interop) 'seo_service_web.dart' as platform;

class SEOService {
  static void updateMetaTags(AppLocalizations l10n, String languageCode) {
    platform.SEOService.updateMetaTags(l10n, languageCode);
  }

  static void addStructuredDataForPublications(
    List<Map<String, dynamic>> publications,
  ) {
    platform.SEOService.addStructuredDataForPublications(publications);
  }

  static void addFAQStructuredData(
    List<Map<String, String>> faqs,
    AppLocalizations l10n,
  ) {
    platform.SEOService.addFAQStructuredData(faqs, l10n);
  }
}
