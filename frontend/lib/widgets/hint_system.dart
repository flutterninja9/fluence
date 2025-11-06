import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Hint data model
class ChallengeHint {
  final String id;
  final String content;
  final int order;
  final String? documentationUrl;

  const ChallengeHint({
    required this.id,
    required this.content,
    required this.order,
    this.documentationUrl,
  });
}

// Mock hints - in real app, these would come from the backend
final challengeHintsProvider = Provider.family<List<ChallengeHint>, String>((
  ref,
  challengeId,
) {
  // This would typically fetch from API based on challengeId
  return [
    const ChallengeHint(
      id: '1',
      content:
          'Start by understanding what the function should return. Look at the examples carefully.',
      order: 1,
    ),
    const ChallengeHint(
      id: '2',
      content:
          'Consider using a loop to iterate through the input. Think about what condition you need to check.',
      order: 2,
    ),
    const ChallengeHint(
      id: '3',
      content:
          'Remember to handle edge cases like empty inputs or null values.',
      order: 3,
      documentationUrl: 'https://dart.dev/guides/language/language-tour#lists',
    ),
  ];
});

// Hint state provider - tracks which hints have been revealed
final hintStateProvider =
    StateNotifierProvider.family<HintStateNotifier, List<bool>, String>((
      ref,
      challengeId,
    ) {
      final hints = ref.watch(challengeHintsProvider(challengeId));
      return HintStateNotifier(hints.length);
    });

class HintStateNotifier extends StateNotifier<List<bool>> {
  HintStateNotifier(int hintCount) : super(List.filled(hintCount, false));

  void revealHint(int index) {
    if (index < state.length) {
      final newState = [...state];
      newState[index] = true;
      state = newState;
    }
  }

  void revealNextHint() {
    final nextIndex = state.indexWhere((revealed) => !revealed);
    if (nextIndex != -1) {
      revealHint(nextIndex);
    }
  }

  void resetHints() {
    state = List.filled(state.length, false);
  }

  int get revealedCount => state.where((revealed) => revealed).length;
  int get totalCount => state.length;
  bool get hasMoreHints => revealedCount < totalCount;
}

// Hint system widget
class HintSystem extends ConsumerWidget {
  final String challengeId;
  final int failedAttempts;

  const HintSystem({
    super.key,
    required this.challengeId,
    required this.failedAttempts,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hints = ref.watch(challengeHintsProvider(challengeId));
    final hintState = ref.watch(hintStateProvider(challengeId));
    final hintNotifier = ref.read(hintStateProvider(challengeId).notifier);

    if (hints.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.lightbulb_outlined, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Hints',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (hintNotifier.revealedCount > 0)
                Text(
                  '${hintNotifier.revealedCount}/${hintNotifier.totalCount}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Hints list
          ...List.generate(hints.length, (index) {
            final hint = hints[index];
            final isRevealed = index < hintState.length
                ? hintState[index]
                : false;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index < hints.length - 1 ? 12 : 0,
              ),
              child: _buildHintCard(context, hint, index, isRevealed),
            );
          }),

          // Show hint button
          if (hintNotifier.hasMoreHints) ...[
            const SizedBox(height: 16),
            _buildShowHintButton(context, ref, hintNotifier),
          ],

          // Encouragement message
          if (failedAttempts > 0 && hintNotifier.revealedCount == 0) ...[
            const SizedBox(height: 12),
            _buildEncouragementMessage(context, failedAttempts),
          ],
        ],
      ),
    );
  }

  Widget _buildHintCard(
    BuildContext context,
    ChallengeHint hint,
    int index,
    bool isRevealed,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isRevealed
            ? Theme.of(context).primaryColor.withAlpha(5)
            : Theme.of(context).disabledColor.withAlpha(10),
        border: Border.all(
          color: isRevealed
              ? Theme.of(context).primaryColor.withAlpha(50)
              : Theme.of(context).disabledColor.withAlpha(50),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isRevealed
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).disabledColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isRevealed ? hint.content : 'Hint ${index + 1}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isRevealed ? null : Theme.of(context).disabledColor,
                    fontStyle: isRevealed ? null : FontStyle.italic,
                  ),
                ),
              ),
              if (isRevealed && hint.documentationUrl != null)
                IconButton(
                  icon: const Icon(Icons.open_in_new, size: 16),
                  onPressed: () => _openDocumentation(hint.documentationUrl!),
                  tooltip: 'View Documentation',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShowHintButton(
    BuildContext context,
    WidgetRef ref,
    HintStateNotifier hintNotifier,
  ) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: () => hintNotifier.revealNextHint(),
        icon: const Icon(Icons.lightbulb, size: 16),
        label: Text(
          'Show Next Hint (${hintNotifier.revealedCount + 1}/${hintNotifier.totalCount})',
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.amber[700],
          side: BorderSide(color: Colors.amber[300]!),
        ),
      ),
    );
  }

  Widget _buildEncouragementMessage(BuildContext context, int attempts) {
    String message;
    if (attempts == 1) {
      message = "Don't worry! Every programmer faces challenges. Try again! 💪";
    } else if (attempts <= 3) {
      message =
          "You're making progress! Consider using a hint if you're stuck. 🤔";
    } else {
      message =
          "Persistence is key in programming! Hints are here to help you learn. 🧠";
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(5),
        border: Border.all(color: Colors.blue.withAlpha(50)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(Icons.psychology, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.blue[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openDocumentation(String url) {
    // In a real app, you would use url_launcher package
    // ignore: avoid_print
    print('Opening documentation: $url');
  }
}

// Simple hint button for quick access
class HintButton extends ConsumerWidget {
  final String challengeId;
  final int failedAttempts;

  const HintButton({
    super.key,
    required this.challengeId,
    required this.failedAttempts,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hintNotifier = ref.read(hintStateProvider(challengeId).notifier);

    if (!hintNotifier.hasMoreHints) {
      return const SizedBox.shrink();
    }

    return OutlinedButton.icon(
      onPressed: () => hintNotifier.revealNextHint(),
      icon: Icon(
        Icons.lightbulb_outlined,
        size: 16,
        color: failedAttempts > 0
            ? Colors.amber[700]
            : Theme.of(context).disabledColor,
      ),
      label: Text(
        'Hint',
        style: TextStyle(
          color: failedAttempts > 0
              ? Colors.amber[700]
              : Theme.of(context).disabledColor,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: failedAttempts > 0
              ? Colors.amber[300]!
              : Theme.of(context).disabledColor,
        ),
      ),
    );
  }
}
