import 'dart:convert';
import 'package:http/http.dart' as http;

class GitHubReleaseService {
  static const String _owner = 'arcangelo7';
  static const String _repo = 'portfolio';
  static const String _baseUrl = 'https://api.github.com';

  static Future<Map<String, String>> getLatestReleaseDownloadUrls() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/repos/$_owner/$_repo/releases/latest'),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'Portfolio-App',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final assets = data['assets'] as List;
        
        final downloadUrls = <String, String>{};
        
        for (final asset in assets) {
          final name = asset['name'] as String;
          final downloadUrl = asset['browser_download_url'] as String;
          
          if (name.contains('android')) {
            downloadUrls['android'] = downloadUrl;
          } else if (name.contains('ios')) {
            downloadUrls['ios'] = downloadUrl;
          } else if (name.contains('windows')) {
            downloadUrls['windows'] = downloadUrl;
          } else if (name.contains('macos')) {
            downloadUrls['macos'] = downloadUrl;
          } else if (name.contains('linux')) {
            downloadUrls['linux'] = downloadUrl;
          }
        }
        
        return downloadUrls;
      } else {
        throw Exception('Failed to load release data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching release data: $e');
    }
  }
}