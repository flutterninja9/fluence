import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:highlight/languages/dart.dart';

import '../services/api_service.dart';
import '../services/supabase_service.dart';

class ChallengeDetailScreen extends ConsumerStatefulWidget {
  final String challengeId;

  const ChallengeDetailScreen({super.key, required this.challengeId});

  @override
  ConsumerState<ChallengeDetailScreen> createState() =>
      _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends ConsumerState<ChallengeDetailScreen> {
  CodeController? _codeController;
  Map<String, dynamic>? _challenge;
  String _output = '';
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _loadChallenge();
  }

  @override
  void dispose() {
    _codeController?.dispose();
    super.dispose();
  }

  Future<void> _loadChallenge() async {
    final supabaseService = ref.read(supabaseServiceProvider);

    try {
      final challenge = await supabaseService.getChallenge(widget.challengeId);

      if (challenge != null) {
        setState(() {
          _challenge = challenge;
          _codeController = CodeController(
            text: challenge['starter_code'] ?? '',
            language: dart,
          );
        });

        // Load previous submission if exists
        _loadPreviousSubmission();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading challenge: $e')));
    }
  }

  Future<void> _loadPreviousSubmission() async {
    final supabaseService = ref.read(supabaseServiceProvider);

    try {
      final submission = await supabaseService.getLatestSubmission(
        widget.challengeId,
      );

      if (submission != null && _codeController != null) {
        _codeController!.text = submission['code'] ?? '';
      }
    } catch (e) {
      // Silently fail if no previous submission
    }
  }

  Future<void> _runCode() async {
    if (_codeController == null || _challenge == null) return;

    setState(() {
      _isRunning = true;
      _output = 'Running code...';
    });

    final apiService = ref.read(apiServiceProvider);

    try {
      final result = await apiService.executeCode(
        code: _codeController!.text,
        testScript: _challenge!['test_script'],
      );

      setState(() {
        _output = result['output'] ?? '';
        if (result['errors'] != null) {
          _output += '\n\nErrors:\n${result['errors']}';
        }
      });

      // Save submission
      final supabaseService = ref.read(supabaseServiceProvider);
      await supabaseService.saveSubmission(
        challengeId: widget.challengeId,
        code: _codeController!.text,
        result: result,
        isSuccessful: result['success'] ?? false,
      );
    } catch (e) {
      setState(() {
        _output = 'Error running code: $e';
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_challenge == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_challenge!['title'] ?? 'Challenge'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          // Description panel
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Markdown(
                      data: _challenge!['description'] ?? '',
                      selectable: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isRunning ? null : _runCode,
                    child: _isRunning
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Run Code'),
                  ),
                ],
              ),
            ),
          ),
          // Code editor panel
          Expanded(
            flex: 1,
            child: Container(
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: Colors.grey)),
              ),
              child: Column(
                children: [
                  // Code editor
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: _codeController != null
                          ? CodeField(
                              controller: _codeController!,
                              textStyle: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 14,
                              ),
                            )
                          : const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  // Output panel
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black87,
                        border: Border(top: BorderSide(color: Colors.grey)),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _output.isEmpty
                              ? 'Output will appear here...'
                              : _output,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
