import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/challenge.dart';
import '../providers/challenge_providers.dart';
import '../services/api_service.dart';
import '../widgets/code_editor.dart';

class ChallengeDetailScreen extends ConsumerStatefulWidget {
  final String challengeId;

  const ChallengeDetailScreen({super.key, required this.challengeId});

  @override
  ConsumerState<ChallengeDetailScreen> createState() =>
      _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends ConsumerState<ChallengeDetailScreen> {
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    final challengeAsync = ref.watch(challengeProvider(widget.challengeId));

    return Scaffold(
      appBar: AppBar(
        title: challengeAsync.when(
          data: (challenge) => Text(challenge.title),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Error'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(challengeProvider(widget.challengeId));
            },
          ),
        ],
      ),
      body: challengeAsync.when(
        data: (challenge) => _buildChallengeContent(challenge),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.refresh(challengeProvider(widget.challengeId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeContent(Challenge challenge) {
    return Row(
      children: [
        // Left panel - Challenge description
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Challenge header
                Row(
                  children: [
                    _buildDifficultyBadge(challenge.difficulty),
                    const SizedBox(width: 8),
                    _buildCategoryBadge(challenge.category),
                    const Spacer(),
                    if (challenge.isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PREMIUM',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Challenge title
                Text(
                  challenge.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Challenge description
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      challenge.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right panel - Code editor and execution
        Expanded(
          flex: 1,
          child: Column(
            children: [
              // Code editor
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: CodeEditor(
                    initialCode: challenge.starterCode,
                    language: 'dart',
                    onCodeChanged: (code) {
                      ref
                          .read(codeEditorProvider(widget.challengeId).notifier)
                          .updateCode(code);
                    },
                    height: null, // Take available space
                    showLineNumbers: true,
                    autoSave: true,
                  ),
                ),
              ),

              // Control buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isRunning ? null : () => _runCode(challenge),
                      icon: _isRunning
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.play_arrow),
                      label: Text(_isRunning ? 'Running...' : 'Run Code'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => _submitCode(challenge),
                      icon: const Icon(Icons.send),
                      label: const Text('Submit'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => _resetCode(challenge),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () => _formatCode(),
                      icon: const Icon(Icons.auto_fix_high),
                      label: const Text('Format'),
                    ),
                  ],
                ),
              ),

              // Output panel
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    color: Theme.of(context).cardColor.withAlpha(50),
                  ),
                  child: _buildOutputPanel(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyBadge(DifficultyLevel difficulty) {
    Color color;
    switch (difficulty) {
      case DifficultyLevel.easy:
        color = Colors.green;
        break;
      case DifficultyLevel.medium:
        color = Colors.orange;
        break;
      case DifficultyLevel.hard:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        difficulty.name.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(ChallengeCategory category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withAlpha(20),
        border: Border.all(color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        category.name.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildOutputPanel() {
    final executionState = ref.watch(codeExecutionProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.terminal,
              size: 16,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            const SizedBox(width: 8),
            Text(
              'Output',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (executionState.hasResult)
              IconButton(
                icon: const Icon(Icons.clear, size: 16),
                onPressed: () {
                  ref.read(codeExecutionProvider.notifier).clearResult();
                },
                tooltip: 'Clear Output',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(4),
            ),
            child: executionState.when(
              data: (result) {
                if (result == null) {
                  return Text(
                    'Run your code to see the output here.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (result.success)
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Success',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (result.executionTime != null) ...[
                              const Spacer(),
                              Text(
                                '${result.executionTime!.toStringAsFixed(2)}ms',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        )
                      else
                        Row(
                          children: [
                            Icon(Icons.error, color: Colors.red, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Error',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),

                      if (result.output != null) ...[
                        Text(
                          'Output:',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor.withAlpha(50),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            result.output!,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      if (result.error != null) ...[
                        Text(
                          'Error:',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(10),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            result.error!,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],

                      if (result.testResults != null &&
                          result.testResults!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Test Results:',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        ...result.testResults!.map(
                          (test) => Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: test.passed
                                  ? Colors.green.withAlpha(10)
                                  : Colors.red.withAlpha(10),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  test.passed ? Icons.check : Icons.close,
                                  color: test.passed
                                      ? Colors.green
                                      : Colors.red,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    test.name,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Executing code...'),
                  ],
                ),
              ),
              error: (error, _) => Text(
                'Execution failed: $error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _runCode(Challenge challenge) async {
    setState(() => _isRunning = true);

    try {
      final code = ref.read(codeEditorProvider(widget.challengeId));
      await ref
          .read(codeExecutionProvider.notifier)
          .executeCode(challenge.id, code);
    } finally {
      setState(() => _isRunning = false);
    }
  }

  Future<void> _submitCode(Challenge challenge) async {
    final code = ref.read(codeEditorProvider(widget.challengeId));

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Solution'),
        content: const Text('Are you sure you want to submit this solution?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Submit the code using API service
        final apiService = ref.read(apiServiceProvider);
        await apiService.createSubmission(challenge.id, code);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Solution submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to submit: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _resetCode(Challenge challenge) {
    ref
        .read(codeEditorProvider(widget.challengeId).notifier)
        .resetCode(challenge.starterCode);
    ref.read(codeExecutionProvider.notifier).clearResult();
  }

  void _formatCode() {
    ref.read(codeEditorProvider(widget.challengeId).notifier).formatCode();
  }
}
