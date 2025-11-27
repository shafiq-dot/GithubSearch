import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/github_search_response.dart';

class GitHubService {
  static const String baseUrl = 'https://api.github.com';

  Future<GitHubSearchResponse> searchRepositories({
    required String query,
    int page = 1,
    int perPage = 30,
  }) async {
    final url = Uri.parse(
      '$baseUrl/search/repositories?q=$query&page=$page&per_page=$perPage',
    );

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/vnd.github.v3+json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      return GitHubSearchResponse.fromJson(jsonData);
    } else {
      throw Exception('Failed to load repositories: ${response.statusCode}');
    }
  }
}