import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/submission.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/supabase_service.dart';

// Submission history provider
final submissionHistoryProvider =
    FutureProvider.family<List<Submission>, String>((ref, challengeId) async {
      final apiService = ref.watch(apiServiceProvider);
      return apiService.getSubmissions(challengeId: challengeId);
    });

// Latest submission provider for auto-restore
final latestSubmissionProvider = FutureProvider.family<Submission?, String>((
  ref,
  challengeId,
) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  final data = await supabaseService.getLatestSubmission(challengeId);

  if (data == null) return null;

  return Submission(
    id: data['id'],
    challengeId: data['challenge_id'],
    userId: data['user_id'],
    code: data['code'],
    status: SubmissionStatus.values.firstWhere(
      (status) => status.name == (data['result']?['status'] ?? 'pending'),
      orElse: () => SubmissionStatus.pending,
    ),
    output: data['result']?['output'],
    error: data['result']?['error'],
    executionTime: data['result']?['execution_time']?.toDouble(),
    createdAt: DateTime.parse(data['created_at']),
    updatedAt: DateTime.parse(data['created_at']),
  );
});

// User progress provider
final userProgressProvider = FutureProvider<UserProgress>((ref) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  final user = supabaseService.currentUser;

  if (user == null) {
    return const UserProgress(
      userId: '',
      totalChallengesSolved: 0,
      easyChallengesSolved: 0,
      mediumChallengesSolved: 0,
      hardChallengesSolved: 0,
      streakDays: 0,
    );
  }

  // Get user progress from API
  try {
    final apiService = ref.watch(apiServiceProvider);
    return await apiService.getUserProgress(user.id);
  } catch (e) {
    // Fallback to calculating from submissions
    return await _calculateProgressFromSubmissions(ref, user.id);
  }
});

// Progress persistence notifier
final progressPersistenceProvider =
    StateNotifierProvider<ProgressPersistenceNotifier, AsyncValue<void>>((ref) {
      return ProgressPersistenceNotifier(ref);
    });

class ProgressPersistenceNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  ProgressPersistenceNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> saveProgress(
    String challengeId,
    String code, {
    bool isSuccessful = false,
  }) async {
    state = const AsyncValue.loading();

    try {
      final supabaseService = _ref.read(supabaseServiceProvider);

      await supabaseService.saveSubmission(
        challengeId: challengeId,
        code: code,
        result: {
          'status': isSuccessful ? 'passed' : 'pending',
          'timestamp': DateTime.now().toIso8601String(),
        },
        isSuccessful: isSuccessful,
      );

      // Refresh related providers
      _ref.invalidate(latestSubmissionProvider(challengeId));
      _ref.invalidate(submissionHistoryProvider(challengeId));
      _ref.invalidate(userProgressProvider);

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> autoSaveProgress(String challengeId, String code) async {
    // Auto-save without showing loading state
    try {
      final supabaseService = _ref.read(supabaseServiceProvider);

      await supabaseService.saveSubmission(
        challengeId: challengeId,
        code: code,
        result: {
          'status': 'pending',
          'auto_saved': true,
          'timestamp': DateTime.now().toIso8601String(),
        },
        isSuccessful: false,
      );

      // Silently refresh latest submission
      _ref.invalidate(latestSubmissionProvider(challengeId));
    } catch (e) {
      // Silently fail for auto-save
      // ignore: avoid_print
      print('Auto-save failed: $e');
    }
  }
}

// Helper function to calculate progress from submissions
Future<UserProgress> _calculateProgressFromSubmissions(
  Ref ref,
  String userId,
) async {
  try {
    final apiService = ref.read(apiServiceProvider);
    final submissions = await apiService.getSubmissions(userId: userId);

    final successfulSubmissions = submissions.where(
      (s) => s.status == SubmissionStatus.passed,
    );
    final challengeIds = successfulSubmissions
        .map((s) => s.challengeId)
        .toSet();

    // For now, return basic stats - could be enhanced to calculate by difficulty
    return UserProgress(
      userId: userId,
      totalChallengesSolved: challengeIds.length,
      easyChallengesSolved: challengeIds.length, // Simplified for now
      mediumChallengesSolved: 0,
      hardChallengesSolved: 0,
      streakDays: _calculateStreak(submissions),
      lastSubmissionAt: submissions.isNotEmpty
          ? submissions.first.createdAt
          : null,
    );
  } catch (e) {
    return UserProgress(
      userId: userId,
      totalChallengesSolved: 0,
      easyChallengesSolved: 0,
      mediumChallengesSolved: 0,
      hardChallengesSolved: 0,
      streakDays: 0,
    );
  }
}

int _calculateStreak(List<Submission> submissions) {
  if (submissions.isEmpty) return 0;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  int streak = 0;

  // Group submissions by date
  final submissionsByDate = <DateTime, List<Submission>>{};
  for (final submission in submissions) {
    final date = DateTime(
      submission.createdAt.year,
      submission.createdAt.month,
      submission.createdAt.day,
    );
    submissionsByDate.putIfAbsent(date, () => []).add(submission);
  }

  // Calculate streak from today backwards
  var currentDate = today;
  while (submissionsByDate.containsKey(currentDate)) {
    streak++;
    currentDate = currentDate.subtract(const Duration(days: 1));
  }

  return streak;
}
