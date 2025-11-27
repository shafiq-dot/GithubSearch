// lib/screens/home_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../components/repository_search_body.dart';
import '../models/github_search_response.dart';
import '../services/github_service.dart';

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
        _hasMore = response.items.length == 30;
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: TextField(
          controller: _controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search repositories...',
            hintStyle: const TextStyle(color: Colors.white70),
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Colors.white),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                _controller.clear();
                setState(() {
                  _currentQuery = '';
                  _repositories.clear();
                });
              },
            )
                : null,
          ),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 300 &&
              !_isLoadingMore &&
              _hasMore) {
            _search(loadMore: true);
          }
          return false;
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
    );
  }
}