import 'package:web/web.dart' as web;

class WebUtils {
  static String getCurrentUrl() {
    return web.window.location.href;
  }
  
  static String getLanguageFromUrl() {
    final uri = Uri.parse(web.window.location.href);
    return uri.queryParameters['lang'] ?? 'en';
  }
  
  static String getFragmentFromUrl() {
    final uri = Uri.parse(web.window.location.href);
    return uri.fragment;
  }
  
  static void updateUrl(String url, {bool replaceState = false}) {
    if (replaceState) {
      web.window.history.replaceState(null, '', url);
    } else {
      web.window.history.pushState(null, '', url);
    }
  }
  
  static void updateUrlWithLanguageAndSection(String languageCode, String section) {
    final uri = Uri.parse(web.window.location.href);
    final newUri = uri.replace(
      queryParameters: {'lang': languageCode},
      fragment: section,
    );
    web.window.history.pushState(null, '', newUri.toString());
  }
}