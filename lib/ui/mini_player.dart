part of 'app_ui.dart';

// ==============================================================================
// ミニプレイヤー
// ==============================================================================
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerViewModelProvider);
    final song = playerState.currentSong;

    if (song == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        _tapFeedback(context);
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (_) => const FullPlayerScreen(),
        );
      },
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor == Colors.transparent
              ? Theme.of(context).colorScheme.surface.withAlpha((0.65 * 255).round())
              : Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.onSurface.withAlpha((0.1 * 255).round()),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: song.artworkUrl != null
                  ? (song.artworkUrl!.startsWith('http')
                      ? Image.network(song.artworkUrl!, fit: BoxFit.cover, filterQuality: FilterQuality.high)
                      : Image.file(File(song.artworkUrl!), fit: BoxFit.cover, filterQuality: FilterQuality.high))
                  : const Icon(Icons.music_note),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 18,
                    child: ClipRect(
                      child: _AnimatedMarquee(
                        text: song.title,
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        initialDelayMs: 2000,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 14,
                    child: ClipRect(
                      child: song.artist.length > 20
                          ? _AnimatedMarquee(
                              text: song.artist,
                              fontSize: 12,
                              color: Colors.grey[400],
                              initialDelayMs: 2000,
                            )
                          : Text(
                              song.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                iconSize: 28,
                onPressed: () {
                  _tapFeedback(context);
                  ref.read(playerViewModelProvider.notifier).togglePlayPause();
                },
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.skip_next),
                color: Theme.of(context).iconTheme.color,
                iconSize: 20,
                onPressed: () {
                  _tapFeedback(context);
                  ref.read(playerViewModelProvider.notifier).skipToNext();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
