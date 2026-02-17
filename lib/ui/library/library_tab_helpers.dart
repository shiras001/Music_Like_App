part of '../app_ui.dart';

mixin _LibraryTabHelpers on ConsumerState<_LibraryTab> {
  TickerProvider get vsync;

  Map<LibraryCategory, bool> get _categoryVisibility;
  set _categoryVisibility(Map<LibraryCategory, bool> value);

  List<LibraryCategory> get _visibleCategories;
  set _visibleCategories(List<LibraryCategory> value);

  TabController get _tabController;
  set _tabController(TabController value);

  bool get _isSearching;
  set _isSearching(bool value);

  TextEditingController get _searchController;

  String get _sortBy;
  set _sortBy(String value);

  Timer? get _debounceTimer;
  set _debounceTimer(Timer? value);
  Future<void> _loadCategoryPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _categoryVisibility = {
        LibraryCategory.songs: prefs.getBool('show_songs') ?? true,
        LibraryCategory.artists: prefs.getBool('show_artists') ?? true,
        LibraryCategory.albums: prefs.getBool('show_albums') ?? true,
        LibraryCategory.playlists: prefs.getBool('show_playlists') ?? true,
      };
      _updateVisibleCategories();
      _tabController = TabController(length: _visibleCategories.length, vsync: vsync);
      _tabController.addListener(() {
        if (!_tabController.indexIsChanging) {
          setState(() {
            // カテゴリ変更時の処理
          });
        }
      });
    });
  }

  void _updateVisibleCategories() {
    _visibleCategories = LibraryCategory.values
        .where((category) => _categoryVisibility[category] == true)
        .toList();
    if (_visibleCategories.isEmpty) {
      _visibleCategories = [LibraryCategory.songs];
    }
    widget.onVisibleCategoriesChanged?.call(List<LibraryCategory>.from(_visibleCategories));
  }

  Future<void> _saveCategoryPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_songs', _categoryVisibility[LibraryCategory.songs]!);
    await prefs.setBool('show_artists', _categoryVisibility[LibraryCategory.artists]!);
    await prefs.setBool('show_albums', _categoryVisibility[LibraryCategory.albums]!);
    await prefs.setBool('show_playlists', _categoryVisibility[LibraryCategory.playlists]!);
  }

  void _showEditCategoriesDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final l10n = AppLocalizations.of(context)!;
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(l10n.categoryEditTitle, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  title: Text(l10n.categorySongs, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                  value: _categoryVisibility[LibraryCategory.songs],
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (value) {
                    setDialogState(() {
                      _categoryVisibility[LibraryCategory.songs] = value ?? true;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(l10n.categoryArtists, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                  value: _categoryVisibility[LibraryCategory.artists],
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (value) {
                    setDialogState(() {
                      _categoryVisibility[LibraryCategory.artists] = value ?? true;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(l10n.categoryAlbums, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                  value: _categoryVisibility[LibraryCategory.albums],
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (value) {
                    setDialogState(() {
                      _categoryVisibility[LibraryCategory.albums] = value ?? true;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(l10n.categoryPlaylists, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                  value: _categoryVisibility[LibraryCategory.playlists],
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (value) {
                    setDialogState(() {
                      _categoryVisibility[LibraryCategory.playlists] = value ?? true;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.commonCancel, style: const TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _updateVisibleCategories();
                    _saveCategoryPreferences();

                    // TabControllerを安全に再作成
                    try {
                      _tabController.dispose();
                    } catch (e) {
                      debugPrint('Error disposing TabController: $e');
                    }

                    _tabController = TabController(length: _visibleCategories.length, vsync: vsync);
                    _tabController.addListener(() {
                      if (!_tabController.indexIsChanging) {
                        setState(() {
                          // カテゴリ変更時の処理
                        });
                      }
                    });
                  });
                },
                child: Text(
                  l10n.commonSave,
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Exposed for parent AppBar buttons
  void openEditCategories() => _showEditCategoriesDialog();

  // Exposed for bottom navigation to switch category
  void selectCategoryByIndex(int index) {
    if (_tabController.length == 0) return;
    final target = index.clamp(0, _tabController.length - 1);
    if (_tabController.index != target) {
      setState(() {
        _tabController.index = target;
      });
    }
  }

  void toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        try {
          ref.read(searchViewModelProvider.notifier).clearSearch();
        } catch (e) {
          debugPrint('Error clearing search: $e');
        }
      }
    });
  }

  Future<void> showSortSelectionDialog(BuildContext context) async {
    final selected = await showDialog<String?>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return SimpleDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          children: [
            RadioListTile<String>(
              title: Text(l10n.sortTitleAsc, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
              value: 'title_asc',
              groupValue: _sortBy,
              onChanged: (v) => Navigator.pop(context, v),
            ),
            RadioListTile<String>(
              title: Text(l10n.sortTitleDesc, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
              value: 'title_desc',
              groupValue: _sortBy,
              onChanged: (v) => Navigator.pop(context, v),
            ),
            RadioListTile<String>(
              title: Text(l10n.sortArtistAsc, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
              value: 'artist_asc',
              groupValue: _sortBy,
              onChanged: (v) => Navigator.pop(context, v),
            ),
            RadioListTile<String>(
              title: Text(l10n.sortArtistDesc, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
              value: 'artist_desc',
              groupValue: _sortBy,
              onChanged: (v) => Navigator.pop(context, v),
            ),
            RadioListTile<String>(
              title: Text(l10n.sortDurationAsc, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
              value: 'duration_asc',
              groupValue: _sortBy,
              onChanged: (v) => Navigator.pop(context, v),
            ),
            RadioListTile<String>(
              title: Text(l10n.sortDurationDesc, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
              value: 'duration_desc',
              groupValue: _sortBy,
              onChanged: (v) => Navigator.pop(context, v),
            ),
          ],
        );
      },
    );

    if (selected != null) {
      setState(() {
        _sortBy = selected;
      });
    }
  }

  void _performSearch(String query) {
    _debounceTimer?.cancel();
    if (query.isEmpty) {
      try {
        ref.read(searchViewModelProvider.notifier).clearSearch();
      } catch (e) {
        debugPrint('Error clearing search in _performSearch: $e');
      }
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      try {
        ref.read(searchViewModelProvider.notifier).search(query);
      } catch (e) {
        debugPrint('Error performing search: $e');
      }
    });
  }

  List<Song> _sortSongs(List<Song> songs) {
    final sortedSongs = List<Song>.from(songs);

    switch (_sortBy) {
      case 'title_asc':
        sortedSongs.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'title_desc':
        sortedSongs.sort((a, b) => b.title.compareTo(a.title));
        break;
      case 'artist_asc':
        sortedSongs.sort((a, b) => a.artist.compareTo(b.artist));
        break;
      case 'artist_desc':
        sortedSongs.sort((a, b) => b.artist.compareTo(a.artist));
        break;
      case 'duration_asc':
        sortedSongs.sort((a, b) => a.duration.compareTo(b.duration));
        break;
      case 'duration_desc':
        sortedSongs.sort((a, b) => b.duration.compareTo(a.duration));
        break;
    }

    return sortedSongs;
  }

  Widget _buildAppDrawer(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(l10n.drawerSettings),
              onTap: () async {
                Navigator.pop(context);
                await AdService.instance.showSettingsInterstitialIfEligible();
                Navigator.push(
                  context,
                  _buildSmoothRoute(const _SettingsTab()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.drawerEditCategories),
              onTap: () {
                Navigator.pop(context);
                openEditCategories();
              },
            ),
            ListTile(
              leading: const Icon(Icons.sort),
              title: Text(l10n.drawerSort),
              onTap: () {
                Navigator.pop(context);
                showSortSelectionDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Route _buildSmoothRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(curve);
        return FadeTransition(
          opacity: curve,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }
}
