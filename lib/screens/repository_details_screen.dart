import 'package:flutter/material.dart';
import 'package:githubapp/models/github_search_response.dart';
import 'package:githubapp/services/favorites_db.dart';

class RepositoryDetailsScreen extends StatefulWidget {
  final Repository repository;

  const RepositoryDetailsScreen({super.key, required this.repository});

  @override
  State<RepositoryDetailsScreen> createState() => _RepositoryDetailsScreenState();
}

class _RepositoryDetailsScreenState extends State<RepositoryDetailsScreen> {
  late Future<bool> _isFavoriteFuture;



  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();

  }

  void _loadFavoriteStatus() {
    _isFavoriteFuture = FavoritesDatabase.instance.isFavorite(widget.repository.id);
  }

  Future<void> _toggleFavorite() async {
    final db = FavoritesDatabase.instance;
    final currentlyFavorite = await db.isFavorite(widget.repository.id);

    if (currentlyFavorite) {
      await db.removeFavorite(widget.repository.id);
    } else {
      await db.insertFavorite(widget.repository);
    }

    // Rebuild the UI
    setState(() {
      _loadFavoriteStatus();
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.repository.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          FutureBuilder<bool>(
            future: _isFavoriteFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                );
              }

              final isFavorite = snapshot.data ?? false;

              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite ? Colors.amber : Colors.white,
                ),
                onPressed: _toggleFavorite,
              );
            },
          ),
        ],
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
                  backgroundImage: NetworkImage(widget.repository.owner.avatarUrl),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.repository.owner.login,
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

            // Repository Full Name
            Text(
              widget.repository.fullName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Description
            if (widget.repository.description != null) ...[
              Text(
                widget.repository.description!,
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

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.star,
                  color: Colors.amber,
                  label: 'Stars',
                  value: widget.repository.stargazersCount.toString(),
                ),
                _buildStatItem(
                  icon: Icons.fork_left,
                  color: Colors.purple,
                  label: 'Forks',
                  value: widget.repository.forksCount.toString(),
                ),
                if (widget.repository.language != null)
                  _buildStatItem(
                    icon: Icons.code,
                    color: _getLanguageColor(widget.repository.language!),
                    label: widget.repository.language!,
                    value: '',
                  ),
              ],
            ),

            const SizedBox(height: 32),


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
        if (value.isNotEmpty)
          Text(
            label,
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
      'Swift': Color(0xFFFE7D37),
      'Ruby': Color(0xFFCC342D),
      'C++': Color(0xFF00599C),
    };
    return map[language] ?? Colors.grey;
  }
}