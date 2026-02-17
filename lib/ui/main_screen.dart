part of 'app_ui.dart';

/// メイン画面：タブナビゲーションとミニプレイヤーのレイアウト管理
/// 仕様: README参照
/// タブ構成：
/// 1. ライブラリ（ユーザーの楽曲管理）
/// 2. 検索（複合検索：曲名／アーティスト／アルバム／プレイリスト）
/// 3. 設定（アプリ全体設定・ローカル読込機能管理）
/// UI: 下部ミニプレイヤー、タブバー固定
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;
  List<LibraryCategory> _bottomCategories = LibraryCategory.values;

  // ライブラリの State にアクセスするための GlobalKey
  final GlobalKey<_LibraryTabState> _libraryKey = GlobalKey<_LibraryTabState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasBackgroundImage = Theme.of(context).scaffoldBackgroundColor == Colors.transparent;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: _LibraryTab(
              key: _libraryKey,
              useBottomTabs: true,
              onVisibleCategoriesChanged: (categories) {
                if (!mounted) return;
                setState(() {
                  _bottomCategories = categories.isEmpty ? [LibraryCategory.songs] : categories;
                  if (_currentIndex >= _bottomCategories.length) {
                    _currentIndex = 0;
                    _libraryKey.currentState?.selectCategoryByIndex(0);
                  }
                });
              },
            ),
          ),
          // ミニプレイヤー（コンテンツの下に常駐）
          const MiniPlayer(),
          BottomNavigationBar(
            currentIndex: _currentIndex,
            backgroundColor: hasBackgroundImage
                ? Theme.of(context).colorScheme.surface.withAlpha((0.65 * 255).round())
                : null,
            onTap: (index) {
              setState(() => _currentIndex = index);
              _libraryKey.currentState?.selectCategoryByIndex(index);
            },
            type: BottomNavigationBarType.fixed,
            items: _bottomCategories.map((category) {
              switch (category) {
                case LibraryCategory.songs:
                  return BottomNavigationBarItem(
                    icon: const Icon(Icons.music_note),
                    label: l10n.tabSongs,
                  );
                case LibraryCategory.artists:
                  return BottomNavigationBarItem(
                    icon: const Icon(Icons.person),
                    label: l10n.tabArtists,
                  );
                case LibraryCategory.albums:
                  return BottomNavigationBarItem(
                    icon: const Icon(Icons.album),
                    label: l10n.tabAlbums,
                  );
                case LibraryCategory.playlists:
                  return BottomNavigationBarItem(
                    icon: const Icon(Icons.queue_music),
                    label: l10n.tabPlaylists,
                  );
              }
            }).toList(),
          ),
        ],
      ),
    );
  }
}
