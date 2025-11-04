import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

class SupabaseService {
  final SupabaseClient _client;

  SupabaseService(this._client);

  // Auth methods
  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> signInWithProvider(OAuthProvider provider) async {
    await _client.auth.signInWithOAuth(
      provider,
      redirectTo: 'http://localhost:3000', // Update for production
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Database methods
  Future<List<Map<String, dynamic>>> getChallenges() async {
    final response = await _client
        .from('challenges')
        .select()
        .order('sort_order');
    return response;
  }

  Future<Map<String, dynamic>?> getChallenge(String id) async {
    final response = await _client
        .from('challenges')
        .select()
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  Future<void> saveSubmission({
    required String challengeId,
    required String code,
    required Map<String, dynamic> result,
    required bool isSuccessful,
  }) async {
    await _client.from('submissions').insert({
      'challenge_id': challengeId,
      'code': code,
      'result': result,
      'is_successful': isSuccessful,
    });
  }

  Future<Map<String, dynamic>?> getLatestSubmission(String challengeId) async {
    if (currentUser == null) return null;

    final response = await _client
        .from('submissions')
        .select()
        .eq('challenge_id', challengeId)
        .eq('user_id', currentUser!.id)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    return response;
  }

  Future<void> submitFeedback({
    required String challengeId,
    required int rating,
    String? message,
  }) async {
    await _client.from('feedback').insert({
      'challenge_id': challengeId,
      'rating': rating,
      'message': message,
    });
  }
}

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  final client = ref.watch(supabaseProvider);
  return SupabaseService(client);
});
