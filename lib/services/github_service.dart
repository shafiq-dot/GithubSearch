
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/github_search_response.dart';

class GitHubService {
  static const String _baseUrl = 'api.github.com';

  Future<GitHubSearchResponse> searchRepositories({
    required String query,
    int page = 1,
    int perPage = 30,
  }) async {
    // Safely encode query parameters (fixes spaces, special characters)
    final uri = Uri.https(_baseUrl, '/search/repositories', {
      'q': query,
      'page': page.toString(),
      'per_page': perPage.toString(),
    });

    try {
      final response = await http
          .get(
        uri,
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'GitHubApp-Flutter', // Required by GitHub
        },
      )
          .timeout(
        const Duration(seconds: 12),
        onTimeout: () => throw TimeoutException('Request timed out'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return GitHubSearchResponse.fromJson(jsonData);
      }

      // Friendly GitHub error messages
      final errorBody = response.body.isNotEmpty
          ? json.decode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      final message = errorBody['message'] ?? 'Unknown error';

      switch (response.statusCode) {
        case 403:
          throw Exception(
            'GitHub rate limit reached.\nWait 1 minute or try again later.',
          );
        case 422:
          throw Exception('Invalid search query. Try something like "flutter"');
        case 503:
          throw Exception('GitHub is temporarily unavailable. Try again soon.');
        default:
          throw Exception('Search failed: $message');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Slow or no internet connection');
    } on FormatException {
      throw Exception('Received invalid data from GitHub');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error occurred');
    }
  }
}