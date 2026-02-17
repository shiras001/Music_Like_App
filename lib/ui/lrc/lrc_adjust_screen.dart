part of '../app_ui.dart';

// ==============================================================================
// LRC調整画面
// ==============================================================================

class _LrcAdjustScreen extends ConsumerStatefulWidget {
  const _LrcAdjustScreen();

  @override
  ConsumerState<_LrcAdjustScreen> createState() => _LrcAdjustScreenState();
}

class _LrcAdjustScreenState extends ConsumerState<_LrcAdjustScreen> {
  Song? _selectedSong;
  List<String> _previewLines = const [];
  List<LrcLine> _baseLines = const [];
  int _offsetMs = 0;
  bool _loading = false;
  String? _error;
  bool _hasApplied = false;

  Future<File?> _getLrcFile() async {
    final path = _selectedSong?.lyricsPath;
    if (path == null || path.isEmpty) return null;
    final file = File(path);
    return file.existsSync() ? file : null;
  }

  Future<void> _loadPreview() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final file = await _getLrcFile();
      if (file == null) {
        setState(() {
          _previewLines = const [];
          _baseLines = const [];
          _error = 'LRCファイルが見つかりません';
        });
        return;
      }
      final lines = await LrcParseService.parseLrcFile(file.path);
      final preview = _buildPreviewLines(lines, _offsetMs);
      setState(() {
        _baseLines = lines;
        _previewLines = preview;
      });
    } catch (e) {
      setState(() {
        _error = '読み込みエラー: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _applyOffset(int deltaMs) async {
    if (_selectedSong == null) return;
    if (_baseLines.isEmpty) {
      await _loadPreview();
    }
    setState(() {
      _offsetMs += deltaMs;
      _previewLines = _buildPreviewLines(_baseLines, _offsetMs);
    });
  }

  Future<void> _applyChanges() async {
    final file = await _getLrcFile();
    if (file == null || _offsetMs == 0) return;

    // Ensure storage permission before writing
    final ok = await ensureStorageAndAudioPermissions(context);
    if (!ok) {
      setState(() {
        _error = 'ストレージ権限が必要です';
      });
      return;
    }

    final backupPath = '${file.path}.bak';
    final backupFile = File(backupPath);
    if (!backupFile.existsSync()) {
      await backupFile.writeAsString(await file.readAsString());
    }

    final content = await file.readAsString();
    final lines = content.split('\n');
    final timePattern = RegExp(r'^\[(\d{2}):(\d{2})\.(\d{2})\](.*)$');

    final adjusted = lines.map((line) {
      final match = timePattern.firstMatch(line.trim());
      if (match == null) return line;
      final minutes = int.parse(match.group(1)!);
      final seconds = int.parse(match.group(2)!);
      final centiseconds = int.parse(match.group(3)!);
      final lyric = match.group(4) ?? '';
      final currentMs = (minutes * 60000) + (seconds * 1000) + (centiseconds * 10);
      final nextMs = math.max(0, currentMs + _offsetMs);
      return '${_formatTimestamp(nextMs)}${lyric}';
    }).join('\n');

    await file.writeAsString(adjusted);
    setState(() {
      _hasApplied = true;
      _offsetMs = 0;
    });
    await _loadPreview();
  }

  Future<void> _restoreBackup() async {
    final file = await _getLrcFile();
    if (file == null) return;
    final backupPath = '${file.path}.bak';
    final backupFile = File(backupPath);
    if (!backupFile.existsSync()) return;
    // Ensure permission before restoring
    final ok = await ensureStorageAndAudioPermissions(context);
    if (!ok) return;
    await file.writeAsString(await backupFile.readAsString());
    setState(() {
      _offsetMs = 0;
      _hasApplied = false;
    });
    await _loadPreview();
  }

  List<String> _buildPreviewLines(List<LrcLine> lines, int offsetMs) {
    return lines.take(30).map((l) {
      final nextMs = math.max(0, l.timeMilliseconds + offsetMs);
      return '${_formatTimestamp(nextMs)} ${l.lyrics}';
    }).toList();
  }

  void _playPreview() {
    final song = _selectedSong;
    if (song == null) return;
    ref.read(playerViewModelProvider.notifier).setQueue([song], startIndex: 0, autoPlay: true);
  }

  String _formatTimestamp(int ms) {
    final totalSeconds = (ms / 1000).floor();
    final minutes = (totalSeconds / 60).floor();
    final seconds = totalSeconds % 60;
    final centiseconds = ((ms % 1000) / 10).floor();
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    final cs = centiseconds.toString().padLeft(2, '0');
    return '[$mm:$ss.$cs]';
  }

  String _formatOffset(int ms) {
    final sign = ms >= 0 ? '+' : '-';
    final absMs = ms.abs();
    return '$sign${(absMs / 1000).toStringAsFixed(2)}s';
  }

  @override
  Widget build(BuildContext context) {
    final songs = ref.watch(libraryViewModelProvider).songs;

    return WillPopScope(
      onWillPop: () async {
        if (_hasApplied) {
          await _restoreBackup();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.lrcAdjustTitle),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedSong?.id,
                items: songs
                    .map((song) => DropdownMenuItem(
                          value: song.id,
                          child: Text('${song.title} - ${song.artist}'),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSong = songs.firstWhere((song) => song.id == value);
                    _previewLines = const [];
                    _baseLines = const [];
                    _offsetMs = 0;
                    _hasApplied = false;
                    _error = null;
                  });
                  _loadPreview();
                },
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.selectSong,
                ),
              ),
              const SizedBox(height: 12),
              if (_selectedSong != null)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.offsetLabel(_formatOffset(_offsetMs)),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _playPreview,
                      icon: const Icon(Icons.play_arrow),
                      label: Text(AppLocalizations.of(context)!.commonPlay),
                    ),
                  ],
                ),
              if (_selectedSong != null) const SizedBox(height: 12),
              const SizedBox(height: 12),
              if (_loading) const LinearProgressIndicator(),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 8),
              Text(AppLocalizations.of(context)!.previewTitle),
              const SizedBox(height: 6),
              Expanded(
                child: ListView.builder(
                  itemCount: _previewLines.length,
                  itemBuilder: (context, index) {
                    return Text(_previewLines[index]);
                  },
                ),
              ),

              // Bottom fixed controls: responsive layout that adapts to width,
              // orientation and system text scale factor to avoid overflow.
              SafeArea(
                top: false,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final textScale = MediaQuery.of(context).textScaleFactor;
                    final buttonTextColor = Theme.of(context).textTheme.bodyMedium?.color;
                    final isNarrow = constraints.maxWidth < 420 || textScale > 1.2;
                    // If narrow or large text, stack controls vertically to avoid overflow.
                    if (isNarrow) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(foregroundColor: buttonTextColor),
                                    onPressed: _selectedSong == null ? null : _applyChanges,
                                    child: FittedBox(fit: BoxFit.scaleDown, child: Text(AppLocalizations.of(context)!.applyChanges)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(foregroundColor: buttonTextColor),
                                    onPressed: _selectedSong == null ? null : _restoreBackup,
                                    child: FittedBox(fit: BoxFit.scaleDown, child: Text(AppLocalizations.of(context)!.restore)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Column(
                              children: [
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    _offsetButton('-1.00s', -1000),
                                    _offsetButton('-0.10s', -100),
                                    _offsetButton('-0.01s', -10),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    _offsetButton('+1.00s', 1000),
                                    _offsetButton('+0.10s', 100),
                                    _offsetButton('+0.01s', 10),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }

                    // Wide layout: keep compact two-row controls with wider buttons.
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(foregroundColor: buttonTextColor),
                                  onPressed: _selectedSong == null ? null : _applyChanges,
                                  child: Text(AppLocalizations.of(context)!.applyChanges),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(foregroundColor: buttonTextColor),
                                  onPressed: _selectedSong == null ? null : _restoreBackup,
                                  child: Text(AppLocalizations.of(context)!.restore),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Column(
                            children: [
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  _offsetButton('-1.00s', -1000),
                                  _offsetButton('-0.10s', -100),
                                  _offsetButton('-0.01s', -10),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  _offsetButton('+1.00s', 1000),
                                  _offsetButton('+0.10s', 100),
                                  _offsetButton('+0.01s', 10),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _offsetButton(String label, int deltaMs) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 48),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 34),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: _selectedSong == null ? null : () => _applyOffset(deltaMs),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label),
        ),
      ),
    );
  }
}
