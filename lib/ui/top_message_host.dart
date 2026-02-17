part of 'app_ui.dart';

class _TopMessageHost extends StatelessWidget {
  final ValueNotifier<List<String>> notifier;

  const _TopMessageHost({required this.notifier});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ValueListenableBuilder<List<String>>(
          valueListenable: notifier,
          builder: (context, messages, _) {
            if (messages.isEmpty) return const SizedBox.shrink();
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: messages.asMap().entries.map((entry) {
                final idx = entry.key;
                final msg = entry.value;
                return Dismissible(
                  // Use the message text as the key so dismissal does not rely on
                  // the list index (which can change while items are displayed).
                  // If duplicate messages are possible, removal will remove the
                  // first matching entry.
                  key: ValueKey(msg),
                  direction: DismissDirection.up,
                  onDismissed: (_) {
                    final list = List<String>.from(notifier.value);
                    // Remove the first occurrence of this message text.
                    final removed = list.remove(msg);
                    if (removed) notifier.value = list;
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.2 * 255).round()),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(msg, style: Theme.of(context).textTheme.bodyMedium),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
