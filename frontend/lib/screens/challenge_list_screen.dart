import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/supabase_service.dart';

class ChallengeListScreen extends ConsumerWidget {
  const ChallengeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabaseService = ref.watch(supabaseServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenges'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: supabaseService.getChallenges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final challenges = snapshot.data ?? [];

          return ListView.builder(
            itemCount: challenges.length,
            itemBuilder: (context, index) {
              final challenge = challenges[index];
              final isPremium = challenge['is_premium'] ?? false;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(
                    challenge['title'] ?? 'Untitled',
                    style: TextStyle(
                      color: isPremium ? Colors.orange : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    'Difficulty: ${challenge['difficulty'] ?? 'unknown'}',
                  ),
                  trailing: isPremium
                      ? const Icon(Icons.lock, color: Colors.orange)
                      : const Icon(Icons.arrow_forward),
                  onTap: () {
                    context.go('/challenge/${challenge['id']}');
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
