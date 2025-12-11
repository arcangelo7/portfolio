import 'dart:convert';
import 'package:http/http.dart' as http;

class GitHubService {
  static const String _baseUrl = 'https://api.github.com';
  static final Map<String, String?> _descriptionCache = {};

  static (String, String)? parseGitHubUrl(String? url) {
    if (url == null || url.isEmpty) return null;

    final regex = RegExp(r'github\.com/([^/]+)/([^/]+)/?');
    final match = regex.firstMatch(url);

    if (match == null) return null;

    final owner = match.group(1)!;
    var repo = match.group(2)!;

    if (repo.endsWith('.git')) {
      repo = repo.substring(0, repo.length - 4);
    }

    return (owner, repo);
  }

  static Future<String?> getRepositoryDescription(
    String owner,
    String repo,
  ) async {
    final cacheKey = '$owner/$repo';

    if (_descriptionCache.containsKey(cacheKey)) {
      return _descriptionCache[cacheKey];
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/repos/$owner/$repo'),
        headers: {
          'Accept': 'application/vnd.github+json',
          'User-Agent': 'Portfolio-App',
          'X-GitHub-Api-Version': '2022-11-28',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final description = data['description'] as String?;
        _descriptionCache[cacheKey] = description;
        return description;
      }

      _descriptionCache[cacheKey] = null;
      return null;
    } catch (e) {
      _descriptionCache[cacheKey] = null;
      return null;
    }
  }

  static Future<String?> getDescriptionFromUrl(String? url) async {
    final parsed = parseGitHubUrl(url);
    if (parsed == null) return null;

    final (owner, repo) = parsed;
    return getRepositoryDescription(owner, repo);
  }
}
