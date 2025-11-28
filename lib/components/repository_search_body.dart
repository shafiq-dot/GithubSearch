import 'package:flutter/material.dart';
import 'package:githubapp/models/github_search_response.dart';
import 'package:githubapp/screens/repository_details_screen.dart';



class RepositorySearchBody extends StatelessWidget {
  final String currentQuery;
  final List<Repository> repositories;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasMore;
  final VoidCallback? onRetry;

  const RepositorySearchBody({
    super.key,
    required this.currentQuery,
    required this.repositories,
    required this.isLoading,
    required this.isLoadingMore,
    this.error,
    this.hasMore = true,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (currentQuery.isEmpty) {
      return const Center(
        child: Text('Start searching...', style: TextStyle(fontSize: 18, color: Colors.grey)),
      );
    }

    if (isLoading && repositories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (repositories.isEmpty) {
      return const Center(child: Text('No repositories found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: repositories.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == repositories.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final repo = repositories[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child:ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(repo.owner.avatarUrl),
            ),
            title: Text(
              repo.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(repo.owner.login),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text('${repo.stargazersCount}', style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RepositoryDetailsScreen(repository: repo),
                ),
              );
            },
          ),
        );
      },
    );
  }
}