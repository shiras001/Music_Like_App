part of '../app_ui.dart';

class _QueueView extends ConsumerWidget {
  final ScrollController scrollController;

  const _QueueView({required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerViewModelProvider);
    final queue = playerState.queue;
    final currentIndex = playerState.currentQueueIndex;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                    Text(
                      AppLocalizations.of(context)!.queueUpNext,
                  style: (Theme.of(context).textTheme.titleLarge ?? const TextStyle()).copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                        AppLocalizations.of(context)!.commonClose,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Theme.of(context).dividerColor),
          Expanded(
            child: queue.isEmpty
                ? Center(
                    child: Text(
                          AppLocalizations.of(context)!.queueEmpty,
                      style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
                      ),
                    ),
                  )
                : ReorderableListView.builder(
                    scrollController: scrollController,
                    buildDefaultDragHandles: false,
                    itemCount: queue.length,
                    onReorder: (oldIndex, newIndex) {
                      ref.read(playerViewModelProvider.notifier).reorderQueue(oldIndex, newIndex);
                    },
                    itemBuilder: (context, index) {
                      final song = queue[index];
                      final isCurrentSong = index == currentIndex;

                      return Container(
                        key: ValueKey(song.id),
                        color: isCurrentSong
                            ? Theme.of(context).dividerColor.withAlpha((0.2 * 255).round())
                            : Colors.transparent,
                        child: ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ReorderableDragStartListener(
                                index: index,
                                child: const Icon(Icons.drag_handle, color: Colors.grey),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: song.artworkUrl != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: song.artworkUrl!.startsWith('http')
                                                ? Image.network(song.artworkUrl!, fit: BoxFit.cover, filterQuality: FilterQuality.high)
                                                : Image.file(File(song.artworkUrl!), fit: BoxFit.cover, filterQuality: FilterQuality.high),
                                      )
                                    : const Icon(Icons.music_note),
                              ),
                            ],
                          ),
                          title: Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isCurrentSong ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium?.color,
                              fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isCurrentSong
                                  ? Theme.of(context).colorScheme.primary.withAlpha((0.7 * 255).round())
                                  : Colors.grey,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: Theme.of(context).colorScheme.error,
                                onPressed: () {
                                  _warningFeedback();
                                  ref.read(playerViewModelProvider.notifier).removeFromQueue(index);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                              AppLocalizations.of(context)!.removedFromQueue(song.title),
                                        ),
                                    ),
                                  );
                                },
                              ),
                              if (isCurrentSong)
                                IconButton(
                                  icon: Icon(
                                    playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                                  ),
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                  onPressed: () {
                                    _tapFeedback(context);
                                    ref.read(playerViewModelProvider.notifier).togglePlayPause();
                                  },
                                ),
                            ],
                          ),
                          onTap: () {
                            _tapFeedback(context);
                            if (isCurrentSong) {
                              ref.read(playerViewModelProvider.notifier).togglePlayPause();
                              return;
                            }
                            ref.read(playerViewModelProvider.notifier).skipToQueueItem(index);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
