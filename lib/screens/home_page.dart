import 'dart:async';
import 'package:flutter/material.dart';
import 'package:githubapp/components/repository_search_body.dart';
import 'package:githubapp/models/github_search_response.dart';
import 'package:githubapp/screens/repository_details_screen.dart';
import 'package:githubapp/services/favorites_db.dart';
import 'package:githubapp/services/github_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final GitHubService _service = GitHubService();

  Timer? _debounce;
  String _currentQuery = '';
  List<Repository> _repositories = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _page = 1;
  bool _hasMore = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      final query = _controller.text.trim();
      if (query != _currentQuery) {
        setState(() {
          _currentQuery = query;
          _page = 1;
          _repositories.clear();
          _hasMore = true;
          _error = null;
          if (query.isEmpty) return;
          _search();
        });
      }
    });
  }

  Future<void> _search({bool loadMore = false}) async {
    if (loadMore && !_hasMore) return;

    setState(() {
      loadMore ? _isLoadingMore = true : _isLoading = true;
      _error = null;
    });

    try {
      final response = await _service.searchRepositories(
        query: _currentQuery,
        page: _page,
        perPage: 30,
      );

      setState(() {
        if (!loadMore) {
          _repositories = response.items;
        } else {
          _repositories.addAll(response.items);
          _page++;
        }
        _hasMore = response.items.length >= 30;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Widget _buildSearchTab() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: TextField(
          controller: _controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search repositories...',
            hintStyle: const TextStyle(color: Colors.white70),
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Colors.white),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, _) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: () {
                    _controller.clear();
                    setState(() {
                      _currentQuery = '';
                      _repositories.clear();
                      _page = 1;
                      _hasMore = true;
                      _error = null;
                    });
                  },
                );
              },
            ),
          ),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 300 &&
              !_isLoadingMore &&
              _hasMore &&
              _selectedIndex == 0) {
            _search(loadMore: true);
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: () async {
            if (_currentQuery.isNotEmpty) {
              setState(() {
                _page = 1;
                _repositories.clear();
                _hasMore = true;
              });
              await _search();
            }
          },
          child: RepositorySearchBody(
            currentQuery: _currentQuery,
            repositories: _repositories,
            isLoading: _isLoading,
            isLoadingMore: _isLoadingMore,
            error: _error,
            hasMore: _hasMore,
            onRetry: () => _search(),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Repositories',style: TextStyle(fontSize: 16),),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Repository>>(
        future: FavoritesDatabase.instance.getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final repos = snapshot.data ?? [];

          if (repos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_border, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Star some repositories to see them here',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: repos.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final repo = repos[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(repo.owner.avatarUrl),
                    radius: 20,
                  ),
                  title: Text(
                    repo.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(repo.owner.login),
                  trailing: IconButton(
                    icon: const Icon(Icons.star, color: Colors.amber),
                    onPressed: () async {
                      await FavoritesDatabase.instance.removeFavorite(repo.id);
                      setState(() {});
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RepositoryDetailsScreen(repository: repo),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildSearchTab(),
          _buildFavoritesTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favorites'),
        ],
      ),
    );
  }
}