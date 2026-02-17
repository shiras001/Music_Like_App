part of '../app_ui.dart';

// ==============================================================================
// ライブラリタブ（検索機能統合 + カテゴリ表示）
// ==============================================================================

enum LibraryCategory { songs, artists, albums, playlists }

class _LibraryTab extends ConsumerStatefulWidget {
  final bool useBottomTabs;
  final ValueChanged<List<LibraryCategory>>? onVisibleCategoriesChanged;

  const _LibraryTab({Key? key, this.useBottomTabs = false, this.onVisibleCategoriesChanged}) : super(key: key);

  @override
  ConsumerState<_LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends ConsumerState<_LibraryTab> with TickerProviderStateMixin, _LibraryTabHelpers {
  bool _isSearching = false;
  late TextEditingController _searchController;
  Timer? _debounceTimer;
  late TabController _tabController;
  String _sortBy = 'title_asc'; // デフォルトはタイトル昇順

  // カテゴリの表示設定
  Map<LibraryCategory, bool> _categoryVisibility = {
    LibraryCategory.songs: true,
    LibraryCategory.artists: true,
    LibraryCategory.albums: true,
    LibraryCategory.playlists: true,
  };

  List<LibraryCategory> _visibleCategories = [];

  @override
  TickerProvider get vsync => this;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadCategoryPreferences();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final libraryState = ref.watch(libraryViewModelProvider);
    final searchState = ref.watch(searchViewModelProvider);
    final songs = libraryState.songs;

    if (libraryState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (libraryState.error != null) {
      final err = libraryState.error!;
      debugPrint('Library load error: $err');
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.libraryLoadFailed,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  err,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => ref.read(libraryViewModelProvider.notifier).refreshLibrary(),
                      child: Text(l10n.libraryReload),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(l10n.errorDetailsTitle),
                            content: SingleChildScrollView(child: Text(err)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(l10n.commonClose),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text(l10n.commonDetails),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      drawer: _buildAppDrawer(context),
      appBar: AppBar(
        toolbarHeight: _isSearching ? kToolbarHeight : kToolbarHeight,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                onChanged: _performSearch,
              )
            : Text(l10n.appTitle),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: l10n.commonSort,
            onPressed: () => showSortSelectionDialog(context),
          ),
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            tooltip: l10n.commonSearch,
            onPressed: toggleSearch,
          ),
        ],
        bottom: (!widget.useBottomTabs && !_isSearching && _visibleCategories.isNotEmpty)
            ? PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  isScrollable: _visibleCategories.length > 3,
                  tabs: _visibleCategories.map((category) {
                    switch (category) {
                      case LibraryCategory.songs:
                        return Tab(text: l10n.tabSongs);
                      case LibraryCategory.artists:
                        return Tab(text: l10n.tabArtists);
                      case LibraryCategory.albums:
                        return Tab(text: l10n.tabAlbums);
                      case LibraryCategory.playlists:
                        return Tab(text: l10n.tabPlaylists);
                    }
                  }).toList(),
                ),
              )
            : null,
      ),
      body: _isSearching
          ? _buildSearchResults(searchState)
          : _visibleCategories.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: _visibleCategories.map((category) {
                    switch (category) {
                      case LibraryCategory.songs:
                        return _buildSongsList(_sortSongs(songs));
                      case LibraryCategory.artists:
                        return _buildArtistsList(_sortSongs(songs));
                      case LibraryCategory.albums:
                        return _buildAlbumsList(_sortSongs(songs));
                      case LibraryCategory.playlists:
                        return _buildPlaylistsList();
                    }
                  }).toList(),
                ),
    );
  }
}
