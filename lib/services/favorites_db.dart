import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/github_search_response.dart';


class FavoritesDatabase {
  static final FavoritesDatabase instance = FavoritesDatabase._init();
  static Database? _database;

  FavoritesDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('favorites.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        fullName TEXT NOT NULL,
        ownerLogin TEXT NOT NULL,
        ownerAvatarUrl TEXT NOT NULL,
        htmlUrl TEXT NOT NULL,
        description TEXT,
        stargazersCount INTEGER NOT NULL,
        forksCount INTEGER NOT NULL,
        language TEXT,
        licenseName TEXT
      )
    ''');
  }

  // Save favorite
  Future<void> insertFavorite(Repository repo) async {
    final db = await instance.database;
    await db.insert(
      'favorites',
      _repoToMap(repo),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Remove favorite
  Future<void> removeFavorite(int id) async {
    final db = await instance.database;
    await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  // Get all favorites
  Future<List<Repository>> getFavorites() async {
    final db = await instance.database;
    final maps = await db.query('favorites', orderBy: 'name ASC');

    return maps.map((map) => _mapToRepo(map)).toList();
  }

  // Check if favorite
  Future<bool> isFavorite(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // Convert Repository → Map (for DB)
  Map<String, dynamic> _repoToMap(Repository repo) {
    return {
      'id': repo.id,
      'name': repo.name,
      'fullName': repo.fullName,
      'ownerLogin': repo.owner.login,
      'ownerAvatarUrl': repo.owner.avatarUrl,
      'htmlUrl': repo.htmlUrl,
      'description': repo.description,
      'stargazersCount': repo.stargazersCount,
      'forksCount': repo.forksCount,
      'language': repo.language,
      'licenseName': repo.license?.name,
    };
  }

  // Convert Map → Repository (for UI)
  Repository _mapToRepo(Map<String, dynamic> map) {
    return Repository(
      id: map['id'] as int,
      name: map['name'] as String,
      fullName: map['fullName'] as String,
      private: false, // not stored
      owner: Owner(
        login: map['ownerLogin'] as String,
        id: 0,
        avatarUrl: map['ownerAvatarUrl'] as String,
        htmlUrl: '',
        type: 'User',
      ),
      htmlUrl: map['htmlUrl'] as String,
      description: map['description'] as String?,
      fork: false,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      pushedAt: DateTime.now().toIso8601String(),
      homepage: null,
      size: 0,
      stargazersCount: map['stargazersCount'] as int,
      watchersCount: 0,
      language: map['language'] as String?,
      forksCount: map['forksCount'] as int,
      openIssuesCount: 0,
      defaultBranch: 'main',
      score: 0.0,
      license: map['licenseName'] != null
          ? License(key: '', name: map['licenseName'], spdxId: '', url: null)
          : null,
      topics: const [],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}