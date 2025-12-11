import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/services/github_service.dart';

void main() {
  group('GitHubService', () {
    group('parseGitHubUrl', () {
      test('parses standard GitHub URL', () {
        final result = GitHubService.parseGitHubUrl(
          'https://github.com/arcangelo7/oc_meta',
        );

        expect(result, ('arcangelo7', 'oc_meta'));
      });

      test('parses GitHub URL with trailing slash', () {
        final result = GitHubService.parseGitHubUrl(
          'https://github.com/owner/repo/',
        );

        expect(result, ('owner', 'repo'));
      });

      test('parses GitHub URL with .git extension', () {
        final result = GitHubService.parseGitHubUrl(
          'https://github.com/owner/repo.git',
        );

        expect(result, ('owner', 'repo'));
      });

      test('parses GitHub URL without https', () {
        final result = GitHubService.parseGitHubUrl(
          'http://github.com/owner/repo',
        );

        expect(result, ('owner', 'repo'));
      });

      test('parses GitHub URL with www prefix', () {
        final result = GitHubService.parseGitHubUrl(
          'https://www.github.com/owner/repo',
        );

        expect(result, ('owner', 'repo'));
      });

      test('returns null for null URL', () {
        final result = GitHubService.parseGitHubUrl(null);

        expect(result, isNull);
      });

      test('returns null for empty URL', () {
        final result = GitHubService.parseGitHubUrl('');

        expect(result, isNull);
      });

      test('returns null for non-GitHub URL', () {
        final result = GitHubService.parseGitHubUrl(
          'https://gitlab.com/owner/repo',
        );

        expect(result, isNull);
      });

      test('returns null for Zenodo DOI URL', () {
        final result = GitHubService.parseGitHubUrl(
          'https://doi.org/10.5281/zenodo.12345',
        );

        expect(result, isNull);
      });

      test('parses URL with subpath', () {
        final result = GitHubService.parseGitHubUrl(
          'https://github.com/owner/repo/tree/main',
        );

        expect(result, ('owner', 'repo'));
      });
    });
  });
}
