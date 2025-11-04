import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/challenge.dart';
import '../models/submission.dart';
import '../services/api_service.dart';

// Challenge providers
final challengeListProvider =
    StateNotifierProvider<ChallengeListNotifier, AsyncValue<ChallengeList>>((
      ref,
    ) {
      final apiService = ref.watch(apiServiceProvider);
      return ChallengeListNotifier(apiService);
    });

final challengeFiltersProvider = StateProvider<ChallengeFilters>((ref) {
  return const ChallengeFilters();
});

final challengeProvider = FutureProvider.family<Challenge, String>((
  ref,
  challengeId,
) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getChallenge(challengeId);
});

// Code editor state
final codeEditorProvider =
    StateNotifierProvider.family<CodeEditorNotifier, String, String>((
      ref,
      challengeId,
    ) {
      return CodeEditorNotifier(challengeId);
    });

// Code execution provider
final codeExecutionProvider =
    StateNotifierProvider<
      CodeExecutionNotifier,
      AsyncValue<CodeExecutionResponse?>
    >((ref) {
      final apiService = ref.watch(apiServiceProvider);
      return CodeExecutionNotifier(apiService);
    });

// Submission providers
final submissionsProvider = FutureProvider.family<List<Submission>, String>((
  ref,
  challengeId,
) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getSubmissions(challengeId: challengeId);
});

class ChallengeListNotifier extends StateNotifier<AsyncValue<ChallengeList>> {
  final ApiService _apiService;

  ChallengeListNotifier(this._apiService) : super(const AsyncValue.loading());

  Future<void> loadChallenges(ChallengeFilters filters) async {
    state = const AsyncValue.loading();

    try {
      final challenges = await _apiService.getChallenges(
        difficulty: filters.difficulty,
        category: filters.category,
        isPremium: filters.isPremium,
        search: filters.search,
        page: filters.page,
        perPage: filters.perPage,
      );
      state = AsyncValue.data(challenges);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh(ChallengeFilters filters) async {
    await loadChallenges(filters);
  }
}

class CodeEditorNotifier extends StateNotifier<String> {
  final String challengeId;

  CodeEditorNotifier(this.challengeId) : super('');

  void updateCode(String code) {
    state = code;
  }

  void resetCode(String initialCode) {
    state = initialCode;
  }

  void formatCode() {
    // Basic Dart formatting
    state = _formatDartCode(state);
  }

  String _formatDartCode(String code) {
    final lines = code.split('\n');
    final formatted = <String>[];
    int indentLevel = 0;

    for (final line in lines) {
      final trimmed = line.trim();

      if (trimmed.startsWith('}')) {
        indentLevel = (indentLevel - 1).clamp(0, 10);
      }

      if (trimmed.isNotEmpty) {
        formatted.add('  ' * indentLevel + trimmed);
      } else {
        formatted.add('');
      }

      if (trimmed.endsWith('{')) {
        indentLevel++;
      }
    }

    return formatted.join('\n');
  }
}

class CodeExecutionNotifier
    extends StateNotifier<AsyncValue<CodeExecutionResponse?>> {
  final ApiService _apiService;

  CodeExecutionNotifier(this._apiService) : super(const AsyncValue.data(null));

  Future<void> executeCode(String challengeId, String code) async {
    state = const AsyncValue.loading();

    try {
      final result = await _apiService.executeCode(challengeId, code);
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearResult() {
    state = const AsyncValue.data(null);
  }
}

// Extension methods for easier state handling
extension ChallengeListX on AsyncValue<ChallengeList> {
  bool get isLoading => this is AsyncLoading;
  bool get hasError => this is AsyncError;
  bool get hasData => this is AsyncData;

  ChallengeList? get data => asData?.value;
  Object? get error => asError?.error;
}

extension CodeExecutionX on AsyncValue<CodeExecutionResponse?> {
  bool get isExecuting => this is AsyncLoading;
  bool get hasExecutionError => this is AsyncError;
  bool get hasResult => this is AsyncData && asData?.value != null;

  CodeExecutionResponse? get result => asData?.value;
  Object? get executionError => asError?.error;
}
