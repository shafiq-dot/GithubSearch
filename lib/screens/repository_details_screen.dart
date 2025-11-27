
import 'package:flutter/material.dart';
import '../models/github_search_response.dart';

class RepositoryDetailsScreen extends StatelessWidget {
  final Repository repository;

  const RepositoryDetailsScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          repository.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Owner + Avatar Row
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage(repository.owner.avatarUrl),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        repository.owner.login,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Owner',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Repository Name
            Text(
              repository.fullName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Description
            if (repository.description != null) ...[
              Text(
                repository.description!,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 24),
            ] else ...[
              const Text(
                'No description provided.',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 24),
            ],

            // Stats Row: Stars, Forks, Language
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.star,
                  color: Colors.amber,
                  label: 'Stars',
                  value: repository.stargazersCount.toString(),
                ),
                _buildStatItem(
                  icon: Icons.fork_left,
                  color: Colors.purple,
                  label: 'Forks',
                  value: repository.forksCount.toString(),
                ),
                if (repository.language != null)
                  _buildStatItem(
                    icon: Icons.code,
                    color: _getLanguageColor(repository.language!),
                    label: repository.language!,
                    value: '',
                  ),
              ],
            ),

            const SizedBox(height: 32),

            // Optional: Open in Browser Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // launchUrlString(repository.htmlUrl);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening ${repository.htmlUrl}')),
                  );
                },
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Open in GitHub'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value.isEmpty ? label : value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          value.isNotEmpty ? label : '',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Color _getLanguageColor(String language) {
    const map = {
      'Dart': Color(0xFF0175C2),
      'TypeScript': Color(0xFF3178C6),
      'JavaScript': Color(0xFFF1E05A),
      'Python': Color(0xFF3572A5),
      'Rust': Color(0xFFDEA584),
      'Go': Color(0xFF00ADD8),
      'Kotlin': Color(0xFFA97BFF),
      'Java': Color(0xFFB07219),
    };
    return map[language] ?? Colors.grey;
  }
}