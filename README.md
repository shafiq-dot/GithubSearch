# GitHubApp - Flutter GitHub Browser

A clean, fast, and offline-capable GitHub repository browser built with Flutter.

Search repositories, star your favorites, and browse them even without internet!

## Features
- Real-time search with debounce & infinite scroll
- Star / Unstar repositories
- Favorites saved locally using SQLite (works offline)
- Pull-to-refresh
- Two tabs: Search & Favorites
- Beautiful Material 3 design


## Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.6.0
  sqflite: ^2.4.2
  path_provider: ^2.1.5
  path: ^1.9.1
```

## How to Run
```bash
# 1. Clone the project
git clone https://github.com/shafiq-dot/GithubSearch.git
cd githubapp

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

## Tested On
- Android 12 (OPPO A74)


Everything works perfectly.

## Architecture
- Pure Flutter + `setState` (no Riverpod/Bloc needed)
- `http` for networking
- `sqflite` for local favorites (offline support)
- `IndexedStack` + `BottomNavigationBar` to keep search state alive

Simple, fast, and easy to maintain.

## Known Issues / Limitations
- No GitHub login → uses public API (10 searches/minute limit)
- Rate limit message shown when searching too fast
- No dark mode yet
- No search history or README preview

## Future Ideas
- Add dark mode
- Enable "Open in GitHub" button
- Show repository README
- Add recent search history

## License
MIT License - feel free to use and modify!

Made with Flutter by **ShafiqDev**  
Enjoy!