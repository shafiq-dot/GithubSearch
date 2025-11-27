// models/github_search_response.dart
class GitHubSearchResponse {
  final int totalCount;
  final bool incompleteResults;
  final List<Repository> items;

  GitHubSearchResponse({
    required this.totalCount,
    required this.incompleteResults,
    required this.items,
  });

  factory GitHubSearchResponse.fromJson(Map<String, dynamic> json) {
    return GitHubSearchResponse(
      totalCount: json['total_count'] as int,
      incompleteResults: json['incomplete_results'] as bool,
      items: (json['items'] as List)
          .map((item) => Repository.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Repository {
  final int id;
  final String name;
  final String fullName;
  final bool private;
  final Owner owner;
  final String htmlUrl;
  final String? description;
  final bool fork;
  final String createdAt;
  final String updatedAt;
  final String pushedAt;
  final String? homepage;
  final int size;
  final int stargazersCount;
  final int watchersCount;
  final String? language;
  final int forksCount;
  final int openIssuesCount;
  final String defaultBranch;
  final double score;
  final License? license;
  final List<String> topics;

  Repository({
    required this.id,
    required this.name,
    required this.fullName,
    required this.private,
    required this.owner,
    required this.htmlUrl,
    this.description,
    required this.fork,
    required this.createdAt,
    required this.updatedAt,
    required this.pushedAt,
    this.homepage,
    required this.size,
    required this.stargazersCount,
    required this.watchersCount,
    this.language,
    required this.forksCount,
    required this.openIssuesCount,
    required this.defaultBranch,
    required this.score,
    this.license,
    required this.topics,
  });

  factory Repository.fromJson(Map<String, dynamic> json) {
    return Repository(
      id: json['id'] as int,
      name: json['name'] as String,
      fullName: json['full_name'] as String,
      private: json['private'] as bool,
      owner: Owner.fromJson(json['owner'] as Map<String, dynamic>),
      htmlUrl: json['html_url'] as String,
      description: json['description'] as String?,
      fork: json['fork'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      pushedAt: json['pushed_at'] as String,
      homepage: json['homepage'] as String?,
      size: json['size'] as int,
      stargazersCount: json['stargazers_count'] as int,
      watchersCount: json['watchers_count'] as int,
      language: json['language'] as String?,
      forksCount: json['forks'] as int,
      openIssuesCount: json['open_issues'] as int,
      defaultBranch: json['default_branch'] as String,
      score: (json['score'] as num).toDouble(),
      license: json['license'] != null
          ? License.fromJson(json['license'] as Map<String, dynamic>)
          : null,
      topics: List<String>.from(json['topics'] ?? []),
    );
  }
}

class Owner {
  final String login;
  final int id;
  final String avatarUrl;
  final String htmlUrl;
  final String type;

  Owner({
    required this.login,
    required this.id,
    required this.avatarUrl,
    required this.htmlUrl,
    required this.type,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      login: json['login'] as String,
      id: json['id'] as int,
      avatarUrl: json['avatar_url'] as String,
      htmlUrl: json['html_url'] as String,
      type: json['type'] as String,
    );
  }
}

class License {
  final String key;
  final String name;
  final String spdxId;
  final String? url;

  License({
    required this.key,
    required this.name,
    required this.spdxId,
    this.url,
  });

  factory License.fromJson(Map<String, dynamic> json) {
    return License(
      key: json['key'] as String,
      name: json['name'] as String,
      spdxId: json['spdx_id'] as String,
      url: json['url'] as String?,
    );
  }
}