import 'web_utils_stub.dart'
    if (dart.library.js_interop) 'web_utils_web.dart' as platform;

class WebUtils {
  static String getCurrentUrl() => platform.WebUtils.getCurrentUrl();
  
  static String getLanguageFromUrl() => platform.WebUtils.getLanguageFromUrl();
  
  static String getFragmentFromUrl() => platform.WebUtils.getFragmentFromUrl();
  
  static void updateUrl(String url, {bool replaceState = false}) =>
      platform.WebUtils.updateUrl(url, replaceState: replaceState);
  
  static void updateUrlWithLanguageAndSection(String languageCode, String section) =>
      platform.WebUtils.updateUrlWithLanguageAndSection(languageCode, section);
}